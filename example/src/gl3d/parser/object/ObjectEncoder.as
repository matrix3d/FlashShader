package gl3d.parser.object 
{
	import flash.geom.Matrix3D;
	import flash.utils.Dictionary;
	import gl3d.core.Drawable;
	import gl3d.core.Material;
	import gl3d.core.math.Quaternion;
	import gl3d.core.Node3D;
	import gl3d.core.skin.Joint;
	import gl3d.core.skin.Skin;
	import gl3d.core.skin.SkinAnimation;
	import gl3d.core.skin.SkinAnimationCtrl;
	import gl3d.core.skin.Track;
	import gl3d.core.skin.TrackFrame;
	import gl3d.ctrl.Ctrl;
	/**
	 * ...
	 * @author lizhi
	 */
	public class ObjectEncoder 
	{
		private var geoms:Array = [];
		private var skins:Array = [];
		private var anims:Array = [];
		private var mats:Array = [];
		private var id:int = 0;
		private var node2id:Dictionary = new Dictionary;
		private var node2name:Dictionary = new Dictionary;
		private var useSource:Boolean;
		public function ObjectEncoder(useSource:Boolean=true) 
		{
			this.useSource = useSource;
			
		}
		
		public function exportNode(node:Node3D, isExpMesh:Boolean, isExpAnim:Boolean):Object {
			var hierarchy:Object = exportHierarchy(node);
			if(isExpMesh){	
				var geoms2:Array = [];
				for each(var d:Drawable in geoms) {
					if(d.source&&useSource){
						geoms2.push({source:d.source});
					}else {
						var dobj:Object = { };
						geoms2.push(dobj);
						dobj.index = vec2arr(d.index.data);
						dobj.pos = vec2arr(d.pos.data);
						dobj.uv = vec2arr(d.uv.data);
						if (d.joint) {
							dobj.joint = vec2arr(d.joint.data);
						}
						if (d.weight) {
							dobj.weight = vec2arr(d.weight.data);
						}
					}
				}
				var skins2:Array = [];
				for each(var skin:Skin in skins) {
					var joint:Array = [];
					for each(var j:Node3D in skin.joints) {
						joint.push(node2name[j]);
					}
					skins2.push({joint:joint});
				}
				var mats2:Array = [];
				for each(var mat:Material in mats) {
					var matobj:Object = { };
					mats2.push(matobj);
					matobj.d = [mat.color.x, mat.color.y, mat.color.z];
					matobj.a = [mat.ambient.x, mat.ambient.y, mat.ambient.z];
					if(mat.diffTexture){
						matobj.dmap = mat.diffTexture.name;
					}
				}
			}
			if(isExpAnim){
				var anims2:Array = [];
				for each(var animc:SkinAnimationCtrl in anims) {
					var animarr:Array = [];
					anims2.push(animarr);
					for each(var anim:SkinAnimation in animc.anims){
						var animObj:Object = { };
						animObj.name = anim.name;
						animarr.push(animObj);
						animObj.target = [];
						for each(var tg:Node3D in anim.targets) {
							animObj.target.push(node2name[tg]);
						}
						animObj.track = [];
						for each(var t:Track in anim.tracks) {
							var tObj:Object = { };
							tObj.target = node2name[t.target];
							tObj.frame = [];
							for each(var f:TrackFrame in t.frames) {
								tObj.frame.push({matrix:vec2arr(f.matrix.rawData),time:f.time});
							}
							animObj.track.push(tObj);
						}
					}
				}
			}
			var out:Object = { "magic":"m5"};
			if (isExpMesh) {
				out.geom = geoms2;
				out.skin = skins2;
				out.mat = mats2;
				out.hierarchy = hierarchy;
			}
			if (isExpAnim) {
				out.anim = anims2;
			}
			return out;
		}
		
		private function exportHierarchy(node:Node3D):Object {
			var nodeObj:Object = { };
			nodeObj.id = id++;
			node2id[node] = nodeObj.id;
			node2name[node] = getNameDepth(node);
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
			if (node.material) {
				i = mats.indexOf(node.material);
				if (i==-1) {
					i = mats.length;
					mats.push(node.material);
				}
				nodeObj.mat = i;
			}
			if (node.controllers) {
				for each(var controller:Ctrl in node.controllers) {
					if (controller is SkinAnimationCtrl) {
						var animc:SkinAnimationCtrl = controller as SkinAnimationCtrl;
						i = anims.indexOf(animc);
						if (i==-1) {
							i = anims.length;
							anims.push(animc);
						}
						nodeObj.anim = i;
					}
				}
			}
			nodeObj.name = getNameDepth(node);
			
			if (node is Joint) {
				nodeObj.isJoint = true;
				nodeObj.invBindMatrix = vec2arr((node as Joint).invBindMatrix.rawData);
			}
			//else{
				nodeObj.matrix = vec2arr(node.matrix.rawData);
			//}
			if (node.children.length) {
				nodeObj.children = [];
				for each(var child:Node3D in node.children) {
					nodeObj.children.push(exportHierarchy(child));
				}
			}
			return nodeObj;
		}
		
		private function getNameDepth(node:Node3D,addname:String=""):String {
			if (node.name) {
				return node.name+addname;
			}
			if (node.parent) {
				return getNameDepth(node.parent,"."+ node.parent.children.indexOf(node)+addname);
			}
			return "root"+addname;
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