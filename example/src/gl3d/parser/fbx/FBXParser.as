package gl3d.parser.fbx 
{
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import gl3d.core.Drawable3D;
	import gl3d.core.Material;
	import gl3d.core.math.Quaternion;
	import gl3d.core.Node3D;
	import gl3d.core.skin.Skin;
	import gl3d.core.skin.SkinAnimation;
	import gl3d.core.skin.Track;
	import gl3d.core.skin.TrackFrame;
	import gl3d.core.VertexBufferSet;
	import gl3d.ctrl.Ctrl;
	import gl3d.meshs.Meshs;
	import gl3d.util.Utils;
	/**
	 * @author lizhi
	 */
	public class FBXParser 
	{
		public var decoder:FbxDecoder;
		private var ids:Object = { };
		private var connect : Object = { };
		private var namedConnect : Object={};
		private var invConnect : Object={};
		private var defaultModelMatrixes : Object = { };
		public var skipObjects : Object={};
		private var root:Object = { name : "Root", props : [], childs : [] };
		private var hobjects:Object;
		public var rootNode:Node3D
		public var skinNodes:Vector.<Node3D> = new Vector.<Node3D>;
		public function FBXParser(txt:String) 
		{
			decoder = new FbxDecoder(txt);
			root = decoder.obj;
			for each(var obj:Object in root.childs) {
				init(obj);
			}
			rootNode = makeObject();
			loadAnimation();
		}
		
		private function init(n:Object):void {
			switch( n.name ) {
				case "Connections":
					for each(var c:Object in n.childs ) {
						if( c.name != "C" )
							continue;
						var child:int =FbxTools.toInt(c.props[1]);
						var parent:int = FbxTools.toInt(c.props[2]);

						// Maya exports invalid references
						if( ids[child] == null || ids[parent] == null ) continue;

						var name:String = c.props[3];

						if( name != null ) {
							var nc:Object = namedConnect[parent];
							if( nc == null ) {
								nc = {};
								namedConnect[parent]= nc;
							}
							nc[name]= child;
							// don't register as a parent, since the target can also be the child of something else
							if( name == "LookAtProperty" ) continue;
						}

						var ca:Array = connect[parent];
						if( ca == null ) {
							ca = [];
							connect[parent]= ca;
						}
						ca.push(child);

						if( parent == 0 )
							continue;

						ca = invConnect[child];
						if( ca == null ) {
							ca = [];
							invConnect[child]= ca;
						}
						ca.push(parent);
					}
					break;
				case "Objects":
					for each(c in n.childs )
						ids[FbxTools.getId(c)]= c;
					break;
				default:
			}
		}
		private function getModelPath( model : Object ):String {
			var parent:Object = getParent(model, "Model", true);
			var name:String = FbxTools.getName(model);
			if( parent == null )
				return name;
			return getModelPath(parent) + "." + name;
		}
		
		private function getDefaultMatrixes( model : Object ):Object {
			var name:String = FbxTools.getName(model);
			var d:Object = defaultModelMatrixes[name];
			if( d != null )
				return d;
			d =  { };
			var F:Number = 1//Math.PI / 180;
			for each(var p:Object in FbxTools.getAll(model, "Properties70.P") ) {
				switch( FbxTools.toString(p.props[0])) {
				case "GeometricTranslation":
					// handle in Geometry directly
					break;
				case "PreRotation":
					d.preRot = new Vector3D(FbxTools.toFloat(p.props[4]) * F, FbxTools.toFloat(p.props[5]) * F, FbxTools.toFloat(p.props[6]) * F);
					if( d.preRot.x == 0 && d.preRot.y == 0 && d.preRot.z == 0 )
						d.preRot = null;
						break;
				case "Lcl Rotation":
					d.rotate = new Vector3D(FbxTools.toFloat(p.props[4]) * F, FbxTools.toFloat(p.props[5]) * F, FbxTools.toFloat(p.props[6]) * F);
					if( d.rotate.x == 0 && d.rotate.y == 0 && d.rotate.z == 0 )
						d.rotate = null;
						break;
				case "Lcl Translation":
					d.trans = new Vector3D(FbxTools.toFloat(p.props[4]), FbxTools.toFloat(p.props[5]), FbxTools.toFloat(p.props[6]));
					if( d.trans.x == 0 && d.trans.y == 0 && d.trans.z == 0 )
						d.trans = null;
						break;
				case "Lcl Scaling":
					d.scale = new Vector3D(FbxTools.toFloat(p.props[4]), FbxTools.toFloat(p.props[5]), FbxTools.toFloat(p.props[6]));
					if( d.scale.x == 1 && d.scale.y == 1 && d.scale.z == 1 )
						d.scale = null;
						break;
				default:
				}
			}
			defaultModelMatrixes[name] = d;
			var m:Matrix3D = new Matrix3D;
			m.identity();
			if( d.scale != null ) m.appendScale(d.scale.x, d.scale.y, d.scale.z);
			if ( d.rotate != null ) {
				m.appendRotation(d.rotate.x, Vector3D.X_AXIS);
				m.appendRotation(d.rotate.y, Vector3D.Y_AXIS);
				m.appendRotation(d.rotate.z, Vector3D.Z_AXIS);
			}
			if ( d.preRot != null ) {
				m.appendRotation(d.preRot.x, Vector3D.X_AXIS);
				m.appendRotation(d.preRot.y, Vector3D.Y_AXIS);
				m.appendRotation(d.preRot.z, Vector3D.Z_AXIS);
			}
			if ( d.trans != null ) m.appendTranslation(d.trans.x, d.trans.y, d.trans.z);
			d.matrix = m;
			return d;
		}
		
		public function makeObject( ) :Node3D {
			var scene:Node3D = new Node3D;
			var hgeom:Object = {}
			var hskins:Object = {};

			

			//autoMerge();

			var hier:Object = buildHierarchy();
			var objects:Array = hier.objects;
			hier.root.obj = scene;

			// create all models
			for each(var o:Object in objects ) {
				var name:String = FbxTools.getName(o.model);
				o.obj = new Node3D(name);
				if ( o.isMesh ) {
					if( o.isJoint )
						throw "Model " + getModelPath(o.model) + " was tagged as joint but is mesh";
					// load geometry
					var g:Object = getChild(o.model, "Geometry");
					var prim:FbxGeometry = hgeom[FbxTools.getId(g)];
					if( prim == null ) {
						prim = new FbxGeometry(this, g);
						hgeom[FbxTools.getId(g)] = prim;
						prim.drawable=Meshs.createDrawable(Vector.<uint>(prim.getIndexes().vidx), Vector.<Number>(prim.getVertices()), null, null);
					}
					prim.nodes.push(o.obj);
					// load materials
					/*var mats = getChilds(o.model, "Material");
					var tmats = [];
					var vcolor = prim.geom.getColors() != null;
					var lastAdded = 0;
					for( mat in mats ) {
						var tex = getChilds(mat, "Texture")[0];
						if( tex == null ) {
							tmats.push(null);
							continue;
						}
						//var mat = textureLoader(tex.get("FileName").props[0].toString(),mat);
						//if( vcolor && allowVertexColor )
							mat.mainPass.addShader(new h3d.shader.VertexColor());
						tmats.push(mat);
						lastAdded = tmats.length;
					}
					while( tmats.length > lastAdded )
						tmats.pop();
					if( tmats.length == 0 )
						tmats.push(new h3d.mat.MeshMaterial(h3d.mat.Texture.fromColor(0xFF00FF)));
					// create object
					if( tmats.length == 1 )
						o.obj = new h3d.scene.Mesh(prim, tmats[0], scene);
					else {
						prim.multiMaterial = true;
						o.obj = new h3d.scene.MultiMaterial(prim, tmats, scene);
					}*/
					(o.obj as Node3D).drawable = prim.drawable;
					(o.obj as Node3D).material = new Material;
					(o.obj as Node3D).material.color = Vector.<Number>([Math.random(),Math.random(),Math.random(),1]);
					(o.obj as Node3D).type = "MESH";
				} else if( o.isJoint ) {
					/*var j = new h3d.anim.Skin.Joint();
					getDefaultMatrixes(o.model); // store for later usage in animation
					j.index = o.model.getId();
					j.name = o.model.getName();
					o.joint = j;*/
					(o.obj as Node3D).type = "JOINT";
					(o.obj as Node3D).drawable = Meshs.cube(10,10,10);
					(o.obj as Node3D).material = new Material;
					//continue;
				} else {
					var hasJoint:Boolean = false;
					for each(var c:Object in o.childs ){
						if( c.isJoint ) {
							hasJoint = true;
							break;
						}
					}
					if( hasJoint ){
						(o.obj as Node3D).skin = new Skin;
						(o.obj as Node3D).type = "SKIN";
					}
				}
				//o.obj.name = name;
				var m:Object = getDefaultMatrixes(o.model);
				if( m.trans != null || m.rotate != null || m.scale != null || m.preRot != null )
					o.obj.matrix = m.matrix.clone();
			}
			// rebuild scene hierarchy
			for each( o in objects ) {
				//if( o.isJoint ) {
				//	if( o.parent.isJoint ) {
						//o.joint.parent = o.parent.joint;
						//o.parent.joint.subs.push(o.joint);
				//	}
				//} else {
					// put it into the first non-joint parent
					var p:Object = o.parent;
					while( p.obj == null )
						p = p.parent;
					if(o.obj)
					p.obj.addChild(o.obj);
				//}
			}
			// build skins
			for each( o in objects ) {
				if( o.isJoint ) continue;
				// /!\ currently, childs of joints will work but will not cloned
				//if( o.parent.isJoint )
					//o.obj.follow = scene.getObjectByName(o.parent.joint.name);
				var skin:Skin = (o.obj as Node3D).skin;
				if( skin == null ) continue;
				var rootJoints:Array = [];
				createSkin(o,hgeom);
				// remove the corresponding Geometry-Model and copy its material
				/*for( o2 in objects ) {
					if( o2.obj == null || o2 == o || !o2.obj.isMesh() ) continue;
					var m = o2.obj.toMesh();
					if( m.primitive != skinData.primitive ) continue;

					var mt = Std.instance(m, h3d.scene.MultiMaterial);
					skin.materials = mt == null ? [m.material] : mt.materials;
					skin.material = skin.materials[0];
					m.remove();
					// ignore key frames for this object
					defaultModelMatrixes.get(m.name).wasRemoved = o.model.getId();
				}
				// set skin after materials
				if( skinData.boundJoints.length > maxBonesPerSkin ) {
					var model = Std.instance(skinData.primitive, h3d.prim.FBXModel);
					var idx = model.geom.getIndexes();
					skinData.split(maxBonesPerSkin, [for( i in idx.idx) idx.vidx[i]], model.multiMaterial ? model.geom.getMaterialByTriangle() : null);
				}
				skin.setSkinData(skinData);*/
			}

			return scene.children.length == 1 ? scene.children[0] : scene;
		}
		
		private function createSkin(o:Object, hgeom:Object):void {
			var skin:Skin = (o.obj as Node3D).skin;
			var prim2skinData:Object = { };
			doobj(o,skin,skinNodes,prim2skinData);
			function doobj(o:Object,skin:Skin,skinNodes:Vector.<Node3D>,prim2skinData:Object):void {
				if (o.isJoint) {
					for each(var subDef:Object in getParents(o.model, "Deformer")) {
						var def:Object = getParent(subDef, "Deformer");
						var primID:int = FbxTools.getId(getParent(def, "Geometry"));
						var prim:FbxGeometry = hgeom[primID];
						var skinData:Object = prim2skinData[primID] ;
						if (skinData == null) {
							skinData = prim2skinData[primID] = { };
							skinData.wj = [];
						}
						var transPos:Array = FbxTools.getFloats(FbxTools.get(subDef, "Transform"));
						var weightss:Array = FbxTools.getAll(subDef, "Weights");
						if (weightss.length) {
							var weights:Array = FbxTools.getFloats(weightss[0]);
							var indexes:Array = FbxTools.getInts(FbxTools.get(subDef, "Indexes"));
							var joint:Node3D = o.obj as Node3D;
							var jid:int = skin.joints.indexOf(joint);
							if (jid == -1) {
								jid = skin.joints.length;
								skin.joints.push(joint);
							}
							for (var i:int = 0; i < indexes.length; i++) 
							{
								var index:int = indexes[i];
								var wjdata:Array = skinData.wj[index] = skinData.wj[index] || [];
								if(wjdata.length<4){
									wjdata.push([weights[i],jid]);
									if (skin.maxWeight<wjdata.length) {
										skin.maxWeight = wjdata.length;
									}
								}
							}
							
							for each(var skinNode:Node3D in prim.nodes) {
								if (skinNode.skin==null) {
									skinNode.skin = skin;
									skinNodes.push(skinNode);
								}
							}
						}
					}
				}
				for each(var c:Object in o.childs) {
					doobj(c,skin,skinNodes,prim2skinData);
				}
			}
			
			for (var primID:String in prim2skinData) {
				var drawable:Drawable3D = (hgeom[primID] as FbxGeometry).drawable;
				var skinData:Object = prim2skinData[primID];
				var weightVec:Vector.<Number> = new Vector.<Number>(drawable.pos.data.length / 3 * skin.maxWeight);
				var jointVec:Vector.<Number> = new Vector.<Number>(weightVec.length);
				for (var index:String in skinData.wj) {
					for (var i:int = 0; i < skinData.wj[index].length; i++ ) {
						for (var j:int = 0; j < skinData.wj[index].length;j++ ) {
							var ii:int = int(index) * skin.maxWeight + j;
							weightVec[ii] = skinData.wj[index][j][0];
							jointVec[ii] = skinData.wj[index][j][1];
						}
					}
				}
				drawable.weights = new VertexBufferSet(weightVec,skin.maxWeight);
				drawable.joints = new VertexBufferSet(jointVec,skin.maxWeight);
			}
			for each(var joint:Node3D in skin.joints) {
				var m:Matrix3D = joint.matrix.clone();
				m.invert();
				skin.invBindMatrixs.push(m);
			}
		}
		
		private function buildHierarchy():Object {
			// init objects
			var oroot:Object = {childs:[] };
			var objects:Array = [];
			hobjects = {};

			hobjects[0]= oroot;
			for each(var model:Object in FbxTools.getAll(root,"Objects.Model") ) {
				if( skipObjects[FbxTools.getName(model)] )
					continue;
				var mtype:String = FbxTools.getType(model);
				var isJoint:Boolean = mtype == "LimbNode" && ( !isNullJoint(model));
				var o:Object = {childs:[] };
				o.model = model;
				o.isJoint = isJoint;
				o.isMesh = mtype == "Mesh";
				hobjects[FbxTools.getId(model)]= o;
				objects.push(o);
			}

			// build hierarchy
			for each( o in objects ) {
				var p:Object = getParent(o.model, "Model", true);
				var pid:int =  p == null ? 0 : FbxTools.getId(p);
				var op:Object = hobjects[pid];
				if( op == null ) op = oroot; // if parent has been removed
				op.childs.push(o);
				o.parent = op;
			}

			function getDepth( o : Object ):int {
				var k:int = 0;
				while( o != oroot ) {
					o = o.parent;
					k++;
				}
				return k;
			}

			// look for common skin ancestor
			for each(o in objects ) {
				if( ! o.isMesh ) continue;
				var g:Object = getChild(o.model, "Geometry");
				var def:Object = getChild(g, "Deformer", true);
				if( def == null ) continue;
				var bones:Array = []
				for each(var dobj:Object in getChilds(def, "Deformer") ) {
					bones.push(hobjects[FbxTools.getId(getChild(dobj, "Model"))]);
				}
				if( bones.length == 0 ) continue;


				// first let's go the minimal depth for all bones
				var minDepth:int = getDepth(bones[0]);
				for (var i:int = 1; i < bones.length;i++ ) {
					var d:int = getDepth(bones[i]);
					if( d < minDepth ) minDepth = d;
				}
				var out:Array = [];
				for ( i = 0 ; i < bones.length;i++ ) {
					var b:Object = bones[i];
					var n:int = getDepth(b) - minDepth;
					for (var j:int = 0; j < n; j++ ) {
						b.isJoint = true;
						b = b.parent;
					}
					var idx:int = out.indexOf(b);
					if (idx != -1) out.splice(idx, 1);
					out.push(b);
				}
				bones = out;

				while( bones.length > 1 ) {
					for each( b in bones )
						b.isJoint = true;
					var parents:Array = [];
					for each( b in bones ) {
						if ( b.parent == oroot || b.parent.isMesh ) continue;
						idx = parents.indexOf(b.parent);
						if(idx!=-1)
						parents.splice(idx, 1);// .remove(b.parent);
						parents.push(b.parent);
					}
					bones = parents;
				}
			}

			return { root : oroot, objects : objects };
		}
		private function isNullJoint( model : Object ):Boolean {
			if( getParents(model, "Deformer").length > 0 )
				return false;
			var parent:Object = getParent(model, "Model", true);
			if( parent == null )
				return true;
			var t:String = FbxTools.getType(parent);
			if( t == "LimbNode" || t == "Root" )
				return false;
			return true;
		}
		public function getGeometry( name : String = "" ):FbxGeometry {
			var geom:Object = null;
			for each(var g:Object in FbxTools.getAll(root,"Objects.Geometry") )
				if( FbxTools.hasProp( g,FbxProp.PString("Geometry::" + name)) ) {
					geom = g;
					break;
				}
			if( geom == null )
				throw "Geometry " + name + " not found";
			return new FbxGeometry(this, geom);
		}

		public function getParent( node : Object, nodeName : String, opt : Boolean =false):Object {
			var p:Array = getParents(node, nodeName);
			if( p.length > 1 )
				throw node.getName() + " has " + p.length + " " + nodeName + " parents ";
			if( p.length == 0 && !opt )
				throw "Missing " + node.getName() + " " + nodeName + " parent";
			return p[0];
		}

		public function getChild( node : Object, nodeName : String, opt : Boolean=false ):Object {
			var c:Array = getChilds(node, nodeName);
			if( c.length > 1 )
				throw node.getName() + " has " + c.length + " " + nodeName + " childs ";
			if( c.length == 0 && !opt )
				throw "Missing " + node.getName() + " " + nodeName + " child";
			return c[0];
		}

		public function getSpecChild( node : Object, name : String ):Object {
			var nc:Object = namedConnect[FbxTools.getId(node)];
			if( nc == null )
				return null;
			var id:Object = nc[name];
			if( id == null )
				return null;
			return ids[id];
		}

		public function getChilds( node : Object, nodeName : String ):Array {
			var c:Object = connect[FbxTools.getId(node)];
			var subs:Array = [];
			if( c != null )
				for each(var id:String in c ) {
					var n:Object = ids[id];
					if( n == null ) throw id + " not found";
					if( nodeName != null && n.name != nodeName ) continue;
					subs.push(n);
				}
			return subs;
		}

		public function getParents( node : Object, nodeName : String ):Array {
			var c:Object = invConnect[FbxTools.getId(node)];
			var pl:Array = [];
			if( c != null )
				for each(var id:String in c ) {
					var n:Object = ids[id];
					if( n == null ) throw id + " not found";
					if( nodeName != null && n.name != nodeName ) continue;
					pl.push(n);
				}
			return pl;
		}
		
		public function loadAnimation() :void {
			var animDatas:Object = { };
			for each(var a:Object in FbxTools.getAll(root,"Objects.AnimationStack") ){
				var name:String = FbxTools.getName(a);
				var animData:Object = {}
				animDatas[name] = animData;
				var	animNode:Object = getChild(a, "AnimationLayer");
				for each(var cn:Object in getChilds(animNode,"AnimationCurveNode")) {
					var model:Object = getParent(cn, "Model", true);
					var cname:String = FbxTools.getName(cn);
					if( model == null ) continue;
					var data:Array = getChilds(cn, "AnimationCurve");
					if( data.length == 0 ) continue;
					var times:Array = FbxTools.getFloats(FbxTools.get(data[0], "KeyTime"));
					if (data.length != 3) {
						continue;
					}
					var x:Object = FbxTools.getFloats(FbxTools.get(data[0],"KeyValueFloat"));
					var y:Object = FbxTools.getFloats(FbxTools.get(data[1],"KeyValueFloat"));
					var z:Object = FbxTools.getFloats(FbxTools.get(data[2], "KeyValueFloat"));
					var mid:int = FbxTools.getId(model);
					var animDataBase:Object= animData[mid] = animData[mid] || { };
					animDataBase[cname] = [x, y, z];
					animDataBase.times = times;
					animDataBase.target = hobjects[FbxTools.getId(model)].obj;
				}
			}
			
			for each(animData in animDatas) {
				var anim3d:SkinAnimation = new SkinAnimation;
				anim3d.targets = skinNodes;
				for each(animDataBase in animData) {
					var track:Track = new Track;
					track.target = animDataBase.target;
					anim3d.tracks.push(track);
					for (var i:int = 0; i < animDataBase.times.length;i++ ) {
						var time:Number = animDataBase.times[i]/20000000000;
						var s:Array = animDataBase.S;
						var r:Array = animDataBase.R;
						var t:Array = animDataBase.T;
						var frame:TrackFrame = new TrackFrame;
						var m:Matrix3D = new Matrix3D;
						m.appendScale(s[0][i],s[1][i],s[2][i]);
						m.appendRotation(r[0][i], Vector3D.X_AXIS);
						m.appendRotation(r[1][i], Vector3D.Y_AXIS);
						m.appendRotation(r[2][i], Vector3D.Z_AXIS);
						m.appendTranslation(t[0][i], t[1][i], t[2][i]);
						
						frame.matrix = m;
						frame.time = time;
						track.frames.push(frame);
					}
					anim3d.maxTime = anim3d.maxTime>time?anim3d.maxTime:time;
				}
				rootNode.controllers = new Vector.<Ctrl>;
				rootNode.controllers.push(anim3d);
			}
		}
	}

}