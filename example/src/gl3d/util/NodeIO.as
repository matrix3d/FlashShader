package gl3d.util 
{
	import flash.geom.Matrix3D;
	import flash.utils.Dictionary;
	import gl3d.core.Drawable;
	import gl3d.core.math.Quaternion;
	import gl3d.core.Node3D;
	import gl3d.core.skin.Joint;
	import gl3d.core.skin.Skin;
	import gl3d.core.skin.SkinAnimation;
	import gl3d.core.skin.Track;
	import gl3d.core.skin.TrackFrame;
	import gl3d.ctrl.Ctrl;
	/**
	 * ...
	 * @author lizhi
	 */
	public class NodeIO 
	{
		private var geoms:Array = [];
		private var skins:Array = [];
		private var anims:Array = [];
		private var id:int = 0;
		private var node2id:Dictionary = new Dictionary;
		public function NodeIO() 
		{
			
		}
		
		public function exportNode(node:Node3D):Object {
			
			var hierarchy:Object = exportHierarchy(node);
			var geoms2:Array = [];
			for each(var d:Drawable in geoms) {
				if(d.source){
					geoms2.push({source:d.source});
				}else {
					var dobj:Object = { };
					geoms2.push(dobj);
					dobj.index = vec2arr(d.index.data);
					dobj.pos = vec2arr(d.pos.data);
					dobj.uv = vec2arr(d.uv.data);
				}
			}
			var skins2:Array = [];
			for each(var skin:Skin in skins) {
				var joint:Array = [];
				for each(var j:Node3D in skin.joints) {
					joint.push(node2id[j]);
				}
				skins2.push({joint:joint});
			}
			var anims2:Array = [];
			for each(var anim:SkinAnimation in anims) {
				var animObj:Object = { };
				anims2.push(animObj);
				animObj.target = [];
				for each(var tg:Node3D in anim.targets) {
					animObj.target.push(node2id[tg]);
				}
				animObj.track = [];
				for each(var t:Track in anim.tracks) {
					var tObj:Object = { };
					tObj.target = node2id[t.target];
					tObj.frame = [];
					for each(var f:TrackFrame in t.frames) {
						tObj.frame.push({matrix:f.matrix.rawData,time:f.time});
					}
					animObj.track.push(tObj);
				}
			}
			return {"magic":"m4",geom:geoms2,skin:skins2,anim:anims2,hierarchy:hierarchy};
		}
		
		public function exportHierarchy(node:Node3D):Object {
			var nodeObj:Object = { };
			nodeObj.id = id++;
			node2id[node] = nodeObj.id;
			if (node.drawable) {
				var i:int = geoms.indexOf(node.drawable);
				if (i==-1) {
					i = geoms.length;
					geoms.push(node.drawable);
				}
				nodeObj.geom = i;
			}
			if (node.skin) {
				i = skins.indexOf(node.skin);
				if (i==-1) {
					i = skins.length;
					skins.push(node.skin);
				}
				nodeObj.skin = i;
			}
			if (node.controllers) {
				for each(var controller:Ctrl in node.controllers) {
					if (controller is SkinAnimation) {
						var anim:SkinAnimation = controller as SkinAnimation;
						i = anims.indexOf(anim);
						if (i==-1) {
							i = anims.length;
							anims.push(anim);
						}
						nodeObj.anim = i;
					}
				}
			}
			if (node.name) {
				nodeObj.name = node.name;
				if (node is Joint) {
					nodeObj.isJoint = true;
					nodeObj.invBindMatrix = (node as Joint).invBindMatrix.rawData;
				}
			}
			nodeObj.matrix = node.matrix.rawData;
			if (node.children.length) {
				nodeObj.children = [];
				for each(var child:Node3D in node.children) {
					nodeObj.children.push(exportHierarchy(child));
				}
			}
			return nodeObj;
		}
		
		private function vec2arr(vec:Object):Array {
			var arr:Array = [];
			for each(var v:Object in vec) {
				arr.push(v);
			}
			return arr;
		}
	}

}