package gl3d.parser.fbx 
{
	import gl3d.core.Node3D;
	/**
	 * ...
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
		public function FBXParser(txt:String) 
		{
			decoder = new FbxDecoder(txt);
			root = decoder.obj;
			for each(var obj:Object in root.childs) {
				init(obj);
			}
			makeObject();
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
		
		public function makeObject( ) :void {
			var scene:Node3D = new Node3D;
			var hgeom:Object = {}
			var hskins:Object = {};

			

			//autoMerge();

			var hier:Object = buildHierarchy();
			var objects = hier.objects;
			hier.root.obj = scene;

			// create all models
			for( o in objects ) {
				var name = o.model.getName();
				if( o.isMesh ) {
					if( o.isJoint )
						throw "Model " + getModelPath(o.model) + " was tagged as joint but is mesh";
					// load geometry
					var g = getChild(o.model, "Geometry");
					var prim = hgeom.get(g.getId());
					if( prim == null ) {
						prim = new h3d.prim.FBXModel(new Geometry(this, g));
						hgeom.set(g.getId(), prim);
					}
					// load materials
					var mats = getChilds(o.model, "Material");
					var tmats = [];
					var vcolor = prim.geom.getColors() != null;
					var lastAdded = 0;
					for( mat in mats ) {
						var tex = getChilds(mat, "Texture")[0];
						if( tex == null ) {
							tmats.push(null);
							continue;
						}
						var mat = textureLoader(tex.get("FileName").props[0].toString(),mat);
						if( vcolor && allowVertexColor )
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
					}
				} else if( o.isJoint ) {
					var j = new h3d.anim.Skin.Joint();
					getDefaultMatrixes(o.model); // store for later usage in animation
					j.index = o.model.getId();
					j.name = o.model.getName();
					o.joint = j;
					continue;
				} else {
					var hasJoint = false;
					for( c in o.childs )
						if( c.isJoint ) {
							hasJoint = true;
							break;
						}
					if( hasJoint )
						o.obj = new h3d.scene.Skin(null);
					else
						o.obj = new h3d.scene.Object();
				}
				o.obj.name = name;
				var m = getDefaultMatrixes(o.model);
				if( m.trans != null || m.rotate != null || m.scale != null || m.preRot != null )
					o.obj.defaultTransform = m.toMatrix(leftHand);
			}
			// rebuild scene hierarchy
			for( o in objects ) {
				if( o.isJoint ) {
					if( o.parent.isJoint ) {
						o.joint.parent = o.parent.joint;
						o.parent.joint.subs.push(o.joint);
					}
				} else {
					// put it into the first non-joint parent
					var p = o.parent;
					while( p.obj == null )
						p = p.parent;
					p.obj.addChild(o.obj);
				}
			}
			// build skins
			var hgeom = [for( k in hgeom.keys() ) k => (hgeom.get(k) : {function getVerticesCount():Int;function setSkin(s:h3d.anim.Skin):Void;})];
			for( o in objects ) {
				if( o.isJoint ) continue;


				// /!\ currently, childs of joints will work but will not cloned
				if( o.parent.isJoint )
					o.obj.follow = scene.getObjectByName(o.parent.joint.name);

				var skin = Std.instance(o.obj, h3d.scene.Skin);
				if( skin == null ) continue;
				var rootJoints = [];
				for( j in o.childs )
					if( j.isJoint )
						rootJoints.push(j.joint);
				var skinData = createSkin(hskins, hgeom, rootJoints, bonesPerVertex);
				// remove the corresponding Geometry-Model and copy its material
				for( o2 in objects ) {
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
				skin.setSkinData(skinData);
			}

			return scene.numChildren == 1 ? scene.getChildAt(0) : scene;
		}
		private function buildHierarchy():Object {
			// init objects
			var oroot:Object = {childs:[] };
			var objects:Array = [];
			var hobjects:Object = {};

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
					for( b in bones )
						b.isJoint = true;
					var parents:Array = [];
					for( b in bones ) {
						if( b.parent == oroot || b.parent.isMesh ) continue;
						parents.remove(b.parent);
						parents.push(b.parent);
					}
					bones = parents;
				}
			}

			// propagates joint flags
			var changed:Boolean = true;
			while( changed ) {
				changed = false;
				for each(o in objects ) {
					if( o.isJoint || o.isMesh ) continue;
					if( o.parent.isJoint ) {
						o.isJoint = true;
						changed = true;
						continue;
					}
					var hasJoint:Boolean = false;
					for each(var c:Object in o.childs )
						if( c.isJoint ) {
							hasJoint = true;
							break;
						}
					if( hasJoint )
						for each( c in o.parent.childs )
							if( c.isJoint ) {
								o.isJoint = true;
								changed = true;
								break;
							}
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
		public function getGeometry( name : String = "" ):Object {
			var geom:Object = null;
			for each(var g:Object in FbxTools.getAll(root,"Objects.Geometry") )
				if( FbxTools.hasProp( g,FbxProp.PString("Geometry::" + name)) ) {
					geom = g;
					break;
				}
			if( geom == null )
				throw "Geometry " + name + " not found";
			return [this, geom];
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
	}

}