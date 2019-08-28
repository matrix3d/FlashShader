package gl3d.parser.smd 
{
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display3D.Context3DCompareMode;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import gl3d.core.Drawable;
	import gl3d.core.DrawableSource;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.TextureSet;
	import gl3d.core.VertexBufferSet;
	import gl3d.core.skin.Joint;
	import gl3d.core.skin.Skin;
	import gl3d.core.skin.SkinAnimation;
	import gl3d.core.skin.SkinAnimationCtrl;
	import gl3d.core.skin.Track;
	import gl3d.core.skin.TrackFrame;
	import gl3d.ctrl.Ctrl;
	import gl3d.meshs.Meshs;
	/**
	 * ...
	 * @author lizhi
	 */
	public class SMDParser 
	{
		public var joints:Array;
		public var jointMap:Object = {};
		public var target:Node3D=new Node3D;
		public function SMDParser(txt:String,mesh:SMDParser=null) 
		{
			var decoder:SMDDecoder = new SMDDecoder(txt);
			var skin:Skin = new Skin;
			skin.maxWeight = 1;
			var jroot:Node3D = new Node3D;
			joints = [];
			var drawable:Drawable = Meshs.cube();
			var m:Material = new Material;
			m.passCompareMode = Context3DCompareMode.ALWAYS;
			for each(var arr:Array in decoder.nodes){
				var n:Joint = new Joint(arr[1]);
				n.type = "JOINT";
				jointMap[arr[1]] = n;
				n.drawable = drawable;
				n.material = m;
				joints[arr[0]] = n;
				if (arr[2]==-1){
					jroot.addChild(n);
				}else{
					joints[arr[2]].addChild(n);
				}
			}
			skin.joints = Vector.<Joint>(joints);
			
			for each(var tarr:Array in decoder.skeletons[0]){
				var cn:Joint = joints[tarr[0]];
				/*cn.setPosition(tarr[1], tarr[2], tarr[3]);
				cn.setRotation(tarr[4] * 180 / Math.PI, tarr[5] * 180 / Math.PI, tarr[6] * 180 / Math.PI);*/
				var ma:Matrix3D = new Matrix3D;
				ma.appendRotation(tarr[4]* 180 / Math.PI,Vector3D.X_AXIS);
				ma.appendRotation(tarr[5]* 180 / Math.PI,Vector3D.Y_AXIS);
				ma.appendRotation(tarr[6]* 180 / Math.PI, Vector3D.Z_AXIS);
				ma.appendTranslation(tarr[1], tarr[2], tarr[3]);
				cn.matrix = ma;
				cn.invBindMatrix.copyFrom(cn.world);
				cn.invBindMatrix.invert();
			}
			
			var indexs:Vector.<uint> = new Vector.<uint>();
			var poss:Vector.<Number> = new Vector.<Number>;
			var uvs:Vector.<Number> = new Vector.<Number>();
			var norms:Vector.<Number> = new Vector.<Number>;
			var js:Vector.<Number> = new Vector.<Number>;
			var ws:Vector.<Number> = new Vector.<Number>;
			for (var i:int = 0; i < decoder.triangless.length;i++ ){
				var v0:Array = decoder.triangless[i][1];
				var v1:Array = decoder.triangless[i][2];
				var v2:Array = decoder.triangless[i][3];
				js.push(v0[0], v1[0], v2[0]);
				ws.push(1, 1, 1);
				poss.push(
					v0[1], v0[2], v0[3],
					v1[1], v1[2], v1[3],
					v2[1], v2[2], v2[3]
				);
				norms.push(
					v0[4], v0[5], v0[6],
					v1[4], v1[5], v1[6],
					v2[4], v2[5], v2[6]
				);
				uvs.push(
					v0[7], 1-v0[8],
					v1[7], 1-v1[8],
					v2[7], 1-v2[8]
				);
				indexs.push(i*3,i*3+2,i*3+1);
			}
			if(indexs.length>0){
				var node:Node3D = new Node3D;
				node.skin = skin;
				node.material = new Material;
				[Embed(source = "../../../assets/smd/ARTIC_Working1.png")]var c:Class;
				node.material.diffTexture = new TextureSet((new c as Bitmap).bitmapData);
				node.drawable = Meshs.createDrawable(indexs, poss, uvs, norms);
				node.drawable.joint = new VertexBufferSet(js,1);
				node.drawable.weight = new VertexBufferSet(ws,1);
				target.addChild(node);
			}
			
			target.addChild(jroot);
			
			if (mesh){
				mesh.target.controllers = new Vector.<Ctrl>();
				var animc:SkinAnimationCtrl = new SkinAnimationCtrl;
				mesh.target.controllers.push(animc);
				var anim:SkinAnimation = new SkinAnimation;
				anim.isCache = false;
				animc.add(anim);
				anim.maxTime = decoder.skeletons.length/1000*60;
				anim.targets = Vector.<Node3D>([mesh.target.children[0]]);
				for (var i:int = 0; i < decoder.skeletons.length;i++ ){
					var darr:Array = decoder.skeletons[i];
					for each( tarr in darr){
						if (anim.tracks[tarr[0]]==null){
							var track:Track = new Track;
							anim.tracks[tarr[0]] = track;
							track.target = mesh.joints[tarr[0]];
						}
						track = anim.tracks[tarr[0]];
						var frame:TrackFrame = new TrackFrame;
						ma=new Matrix3D;
						frame.matrix = ma;
						ma.appendRotation(tarr[4]* 180 / Math.PI,Vector3D.X_AXIS);
						ma.appendRotation(tarr[5]* 180 / Math.PI,Vector3D.Y_AXIS);
						ma.appendRotation(tarr[6]* 180 / Math.PI, Vector3D.Z_AXIS);
						ma.appendTranslation(tarr[1], tarr[2], tarr[3]);
						frame.time = i/1000*60;
						track.frames.push(frame);
					}
				}
			}
		}
		
	}

}