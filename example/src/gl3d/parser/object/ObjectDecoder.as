package gl3d.parser.object 
{
	import flash.geom.Matrix3D;
	import gl3d.core.Drawable;
	import gl3d.core.DrawableSource;
	import gl3d.core.IndexBufferSet;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.skin.Joint;
	import gl3d.core.skin.Skin;
	import gl3d.core.skin.SkinAnimation;
	import gl3d.core.skin.SkinAnimationCtrl;
	import gl3d.core.skin.Track;
	import gl3d.core.skin.TrackFrame;
	import gl3d.core.VertexBufferSet;
	import gl3d.ctrl.Ctrl;
	import gl3d.meshs.Meshs;
	import gl3d.util.MatLoadMsg;
	/**
	 * ...
	 * @author lizhi
	 */
	public class ObjectDecoder 
	{
		public var target:Node3D;
		private var name2node:Object = { };
		private var geoms:Array = [];
		public var anims:Array = [];
		private var skins:Array = [];
		private var mats:Array = [];
		private var obj:Object;
		public function ObjectDecoder(obj:Object) 
		{
			this.obj = obj;
			var magic:String = obj.magic;
			if (magic=="m5") {
				parserM5(obj);
			}
		}
		
		private function parserM5(obj:Object):void 
		{
			for each(var geom:Object in obj.geom) {
				var drawable:Drawable = new Drawable;
				var source:Object = geom.source;
				if(source){
					drawable.source = new DrawableSource;
					drawable.source.alpha = source.alpha;
					drawable.source.color = source.color;
					drawable.source.index = source.index;
					drawable.source.joint = source.joint;
					drawable.source.pos = source.pos;
					drawable.source.uv = source.uv;
					drawable.source.uv2 = source.uv2;
					drawable.source.uvIndex = source.uvIndex;
					drawable.source.weight = source.weight;
				}else{
					if (geom.index) {
						drawable.index = new IndexBufferSet(Vector.<uint>(geom.index));
					}
					if (geom.pos) {
						drawable.pos = new VertexBufferSet(Vector.<Number>(geom.pos), 3);
					}
					if (geom.uv) {
						drawable.uv = new VertexBufferSet(Vector.<Number>(geom.uv), 2);
					}
					if (geom.joint) {
						drawable.joint = new VertexBufferSet(Vector.<Number>(geom.joint), 3*geom.joint.length/geom.pos.length);
					}
					if (geom.weight) {
						drawable.weight = new VertexBufferSet(Vector.<Number>(geom.weight), 3*geom.weight.length/geom.pos.length);
					}
				}
				geoms.push(drawable);
			}
			for each(var skin:Object in obj.skin) {
				var nskin:Skin = new Skin;
				skins.push(nskin);
			}
			for each(var mat:Object in obj.mat) {
				var nmat:Material = new Material;
				nmat.color.x = mat.d[0];
				nmat.color.y = mat.d[1];
				nmat.color.z = mat.d[2];
				nmat.ambient.x = mat.a[0];
				nmat.ambient.y = mat.a[1];
				nmat.ambient.z = mat.a[2];
				if (mat.dmap!=null) {
					new MatLoadMsg(mat.dmap, nmat);
				}
				mats.push(nmat);
			}
			for each(var anim:Object in obj.anim) {
				var nanimc:SkinAnimationCtrl = new SkinAnimationCtrl;
				anims.push(nanimc);
			}
			var hierarchy:Object = obj.hierarchy;
			if (hierarchy) {
				target = importHierarchy(hierarchy);
			}
			
			if(obj.skin){
				for (var i:int = 0; i < obj.skin.length; i++ ) {
					skin = obj.skin[i];
					nskin = skins[i];
					for each(var jname:String in skin.joint) {
						nskin.joints.push(name2node[jname]);
					}
				}
			}
			
			if (obj.anim) {
				bindAnim(this);
			}
		}
		
		private function importHierarchy(obj:Object):Node3D {
			if (obj.isJoint) {
				var node:Node3D = new Joint;
				var joint:Joint = node as Joint;
			}else {
				node = new Node3D;
			}
			if (obj.geom!=null) {
				node.drawable = geoms[obj.geom];
			}
			if (obj.mat!=null) {
				node.material = mats[obj.mat]
			}
			if (obj.skin!=null) {
				node.skin = skins[obj.skin];
				if(node.drawable&&node.drawable.source){
					node.skin.maxWeight = node.drawable.source.joint.length * 3 / node.drawable.source.pos.length;
				}else if (node.drawable) {
					node.skin.maxWeight = node.drawable.joint.data.length * 3 / node.drawable.pos.data.length;
				}
			}
			if (obj.anim!=null) {
				node.controllers = new Vector.<Ctrl>;
				var animc:SkinAnimationCtrl = anims[obj.anim];
				if (animc==null) {
					animc = anims[obj.anim] = new SkinAnimationCtrl;
				}
				node.controllers.push(animc);
			}
			var matrix:Array = obj.matrix as Array;
			if(matrix){
				node.matrix.rawData = Vector.<Number>(matrix);
			}
			if(joint){
				var invBindMatrix:Array = obj.invBindMatrix as Array;
				if (invBindMatrix) {
					joint.invBindMatrix.rawData = Vector.<Number>(invBindMatrix);
					//joint.matrix.copyFrom(joint.invBindMatrix);
					//joint.matrix.invert();
				}
			}
			node.name = obj.name;
			name2node[node.name] = node;
			for each(var c:Object in obj.children) {
				node.addChild(importHierarchy(c));
			}
			return node;
		}
		
		public function bindAnim(objd:ObjectDecoder):void {
			for (var i:int = 0; i < objd.obj.anim.length; i++ ) {
				var nanimc:SkinAnimationCtrl = anims[i];
				for (var j:int = 0; j < objd.obj.anim[i].length;j++ ) {
					var nanim:SkinAnimation = new SkinAnimation;
					nanimc.add(nanim);
					var anim:Object = objd.obj.anim[i][j];
					var mtime:Number = 0;
					nanim.targets = new Vector.<Node3D>;
					for each(var nname:String in anim.target) {
						nanim.targets.push(name2node[nname]);
					}
					for each(var tobj:Object in anim.track) {
						var track:Track = new Track;
						nanim.tracks.push(track);
						track.target = name2node[tobj.target];
						for each(var fObj:Object in tobj.frame) {
							var f:TrackFrame = new TrackFrame;
							track.frames.push(f);
							f.matrix = new Matrix3D;
							f.matrix.rawData = Vector.<Number>(fObj.matrix);
							f.time = fObj.time;
							if (mtime < f.time) {
								mtime = f.time;
							}
						}
					}
					nanim.maxTime = mtime;
				}
			}
		}
	}

}