package gl3d.parser.fbx 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import gl3d.core.Drawable;
	import gl3d.core.DrawableSource;
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
	import gl3d.util.Converter;
	import gl3d.util.MatLoadMsg;
	/**
	 * @author lizhi
	 */
	public class FbxParser 
	{
		public var decoder:Object;
		private var ids:Object = { };
		private var connect : Object = { };
		private var invConnect : Object={};
		public var skipObjects : Object = { };
		public var name2object:Object = { };
		public var root:Object;
		public var hobjects:Object;
		public var rootNode:Node3D
		public var skinNodes:Vector.<Node3D> = new Vector.<Node3D>;
		public var converter:Converter;
		public var animc:SkinAnimationCtrl;
		public function FbxParser(data:Object,parserMesh:Boolean=true,parserAnim:Boolean=true) 
		{
			if (data is ByteArray) {
				decoder = new FbxBinDecoder(data as ByteArray);
				if(decoder.isBin){
					var childs:Array = decoder.childs;
				}
			}
			if(childs==null){
				decoder = new FbxTextDecoder(String(data));
				childs = decoder.childs;
			}
			root = { name : "Root", props : [0, "Root", "Root"], childs :childs };
			for each(var obj:Object in root.childs) {
				init(obj);
			}
			if(parserMesh){
				converter = new Converter(null, new Vector3D(1, 1, -1));
				rootNode = makeObject();
			}
			if(parserAnim){
				loadAnimation(this);
			}
		}
		
		private function init(n:Object):void {
			switch( n.name ) {
				case "Connections":
					for each(var c:Object in n.childs ) {
						if( c.name != "C" &&c.name!="Connect")
							continue;
						var child:String = String(c.props[1]);// .params[0];
						var parent:String = String(c.props[2]);// .params[0];

						// Maya exports invalid references
						if( ids[child] == null || ids[parent] == null ) continue;

						var ca:Array = connect[parent];
						if( ca == null ) {
							ca = [];
							connect[parent]= ca;
						}
						ca.push(child);

						if( parent == null )
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
		
		private function getFbxMatrixes( model : Object ):Object {
			var d:Object = { };
			for each(var p:Object in FbxTools.getAll(model, "Properties70.P").concat(FbxTools.getAll(model, "Properties60.Property")) ) {
				var name:String = String(p.props[0]);
				switch( name) {
				case "GeometricTranslation":
				case "GeometricRotation":
				case "GeometricScaling":
				case "PreRotation":
				case "PostRotation":
				case "Lcl Rotation":
				case "Lcl Translation":
				case "Lcl Scaling":
					var l:int = p.props.length;
					d[name] = new Vector3D(p.props[l-3], p.props[l-2], p.props[l-1]);
					break;
				}
			}
			return d;
		}
		
		private function getMatrix(d:Object,s:Vector3D=null,r:Vector3D=null,t:Vector3D=null):Matrix3D {
			var m:Matrix3D = new Matrix3D;
			var sv:Vector3D = s||d["Lcl Scaling"];
			var rv:Vector3D = r||d["Lcl Rotation"];
			var tv:Vector3D = t||d["Lcl Translation"];
			if ( sv != null ) {
				m.appendScale(sv.x, sv.y, sv.z);
			}
			if (rv != null ) {
				m.appendRotation(rv.x, Vector3D.X_AXIS);
				m.appendRotation(rv.y, Vector3D.Y_AXIS);
				m.appendRotation(rv.z, Vector3D.Z_AXIS);
			}
			if ( d["PreRotation"] != null ) {
				m.appendRotation(d["PreRotation"].x, Vector3D.X_AXIS);
				m.appendRotation(d["PreRotation"].y, Vector3D.Y_AXIS);
				m.appendRotation(d["PreRotation"].z, Vector3D.Z_AXIS);
			}
			if ( tv != null ) {
				m.appendTranslation(tv.x, tv.y, tv.z);
			}
			if ( d["PostRotation"] != null ) {
				m.appendRotation(d["PostRotation"].x, Vector3D.X_AXIS);
				m.appendRotation(d["PostRotation"].y, Vector3D.Y_AXIS);
				m.appendRotation(d["PostRotation"].z, Vector3D.Z_AXIS);
			}
			//if ( d["GeometricTranslation"] != null ) {
				//m.appendTranslation(d["GeometricTranslation"].x, d["GeometricTranslation"].y, d["GeometricTranslation"].z);
			//}
			return converter.getConvertedMat4(m);
		}
		
		private function isHasJoint(o:Object):Boolean {
			for each(var c:Object in o.childs ){
				if( c.isJoint ) {
					return true;
				}
			}
			return false;
		}
		
		public function makeObject( ) :Node3D {
			var scene:Node3D = new Node3D("scene");
			var hgeom:Object = {}
			var hskins:Object = {};
			var hier:Object = buildHierarchy();
			var objects:Array = hier.objects;
			hier.root.obj = scene;

			// create all models
			for each(var o:Object in objects ) {
				var name:String = FbxTools.getName(o.model);
				if ( o.isMesh ) {
					o.obj = new Node3D(name);
					// load geometry
					var g:Object = getChild(o.model, "Geometry");
					if(g){
						var prim:FbxGeometry = hgeom[FbxTools.getId(g)];
						if( prim == null ) {
							prim = new FbxGeometry(g);
							hgeom[FbxTools.getId(g)] = prim;
						}
					}else {
						var verticesData:Object = FbxTools.get(o.model, "Vertices");
						var polygonVertexIndexData:Object = FbxTools.get(o.model, "PolygonVertexIndex");
						if(verticesData&&polygonVertexIndexData){
							var vertices:Array = /*FbxTools.props2array(*/verticesData.props;
							var polygonVertexIndex:Array = /*FbxTools.props2array(*/polygonVertexIndexData.props;
							prim = new FbxGeometry(null, vertices, polygonVertexIndex);
						}
					}
					if (prim) {
						if (prim.drawables == null) {
							prim.drawables = [];
							var posData:Array = null;
							for (var i:int = 0; i < prim.objs.length; i++ ) {
								if (prim.objs[i] == null) continue;
								var drawable:Drawable = new Drawable;
								prim.drawables.push(drawable);
								drawable.source = new DrawableSource;
								drawable.source.index = prim.objs[i][0];
								if (posData==null) {
									posData = converter.convertedVec3s(prim.vertices) as Array;
								}
								drawable.source.pos = posData;
								if (prim.objs[i][1]) {
									drawable.source.uv = prim.uv;
									drawable.source.uvIndex = prim.objs[i][1];
								}
								var submesh:Node3D = new Node3D;// o.obj as Node3D;
								submesh.name = (o.obj as Node3D).name+"."+i;
								(o.obj as Node3D).addChild(submesh);
								prim.nodes.push(submesh);
								submesh.drawable = drawable;
								submesh.material = new Material;
								var material:Object = getChilds(o.model, "Material")[i];
								
								if(material){
									var materialObj:Object = { };
									for each(var p:Object in FbxTools.getAll(material, "Properties70.P").concat(FbxTools.getAll(material, "Properties60.Property"))) {
										name = String(p.props[0]);
										//trace(name);
										switch( name) {
										case "AmbientColor":
										case "DiffuseColor":
											var l:int = p.props.length;
											materialObj[name] = new Vector3D(p.props[l-3], p.props[l-2], p.props[l-1]);
											break;
										}
									}
									if (materialObj.DiffuseColor) {
										submesh.material.color.setTo(materialObj.DiffuseColor.x,materialObj.DiffuseColor.y,materialObj.DiffuseColor.z);
									}
									if (materialObj.AmbientColor) {
										submesh.material.ambient.setTo(materialObj.AmbientColor.x,materialObj.AmbientColor.y,materialObj.AmbientColor.z);
									}
									
									var tex:Object = getChild(material, "Texture") ;
									if (tex) {
										var texPath:String = String(FbxTools.get(tex, "FileName").props[0]);
										var video:Object = getChild(tex, "Video");
										if (video){
											var videoObj:Object = FbxTools.get(video, "Content", true);
											if (videoObj&&videoObj.props){
												var videoByte:ByteArray = videoObj.props[0] as ByteArray;
											}
										}
										new MatLoadMsg(texPath,videoByte, submesh.material);
									}
								}
								//break;
							}
							
						}
						
						
						
					}
				} else if ( o.isJoint ) {
					o.obj = new Joint(name);
					//(o.obj as Node3D).drawable = Meshs.cube(10,10,10);
					//(o.obj as Node3D).material = new Material;
					//continue;
				} else {
					o.obj = new Node3D(name);
					var hasJoint:Boolean = isHasJoint(o);
					if( hasJoint ){
						(o.obj as Node3D).skin = new Skin;
					}
				}
				o.m = getFbxMatrixes(o.model);
				o.obj.matrix = getMatrix(o.m);
				if (o.isMesh && (o.m.GeometricTranslation || o.m.GeometricRotation || o.m.GeometricScaling)) {
					var m:Matrix3D = new Matrix3D;
					var s:Vector3D = o.m.GeometricScaling;
					var r:Vector3D = o.m.GeometricRotation;
					var t:Vector3D = o.m.GeometricTranslation;
					if (s) {
						m.appendScale(s.x, s.y, s.z);
					}
					if (r) {
						m.appendRotation(r.x, Vector3D.X_AXIS);
						m.appendRotation(r.y, Vector3D.Y_AXIS);
						m.appendRotation(r.z, Vector3D.Z_AXIS);
					}
					if (t) {
						m.appendTranslation(t.x, t.y, t.z);
					}
					m = converter.getConvertedMat4(m);
					for each(submesh in (o.obj as Node3D).children) {
						submesh.matrix.copyFrom(m);
					}
				}
			}
			// rebuild scene hierarchy
			for each( o in objects ) {
				p = o.parent;
				if(o.obj){
					p.obj.addChild(o.obj);
				}
			}
			// build skins
			for each( o in objects ) {
				if( o.isJoint ) continue;
				var skin:Skin = (o.obj as Node3D).skin;
				if( skin == null ) continue;
				createSkin(o, hgeom);
				if (!o.isMesh) {
					o.obj.skin = null;
				}
			}
			if (isHasJoint(hier.root)) {
				(hier.root.obj as Node3D).skin = new Skin;
				createSkin(hier.root, hgeom);
				hier.root.obj.skin = null;
			}

			return scene.children.length == 1 ? scene.children[0] : scene;
		}
		
		private function createSkin(o:Object, hgeom:Object):void {
			var skin:Skin = (o.obj as Node3D).skin;
			var prim2skinData:Object = { };
			var transPoss:Array = [];
			doobj(o,skin,skinNodes,prim2skinData,transPoss);
			function doobj(o:Object,skin:Skin,skinNodes:Vector.<Node3D>,prim2skinData:Object,transPoss:Array):void {
				if (o.isJoint) {
					for each(var subDef:Object in getParents(o.model, "Deformer")) {
						var def:Object = getParent(subDef, "Deformer");
						var primID:String = FbxTools.getId(getParent(def, "Geometry"));
						var prim:FbxGeometry = hgeom[primID];
						var skinData:Object = prim2skinData[primID] ;
						if (skinData == null) {
							skinData = prim2skinData[primID] = { };
							skinData.wj = [];
						}
						var weightss:Array = FbxTools.getAll(subDef, "Weights");
						if (weightss.length) {
							var weights:Array = FbxTools.getFloats(weightss[0]);
							var indexes:Array = FbxTools.getInts(FbxTools.get(subDef, "Indexes"));
							var joint:Joint = o.obj as Joint;
							var jid:int = skin.joints.indexOf(joint);
							if (jid == -1) {
								jid = skin.joints.length;
								skin.joints.push(joint);
								var transPos:Array = FbxTools.getFloats(FbxTools.get(subDef, "Transform"));
								transPoss.push(transPos);
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
					doobj(c,skin,skinNodes,prim2skinData,transPoss);
				}
			}
			
			for (var primID:String in prim2skinData) {
				var drawables:Array = (hgeom[primID] as FbxGeometry).drawables;
				var weightVec:Array = null;// new Vector.<Number>(drawable.pos.data.length / 3 * skin.maxWeight);
				var jointVec:Array = null;// Vector.<Number> = new Vector.<Number>(weightVec.length);
				for each(var drawable:Drawable in drawables) {
					if (weightVec == null) {
						weightVec = [];
						jointVec = [];
						var skinData:Object = prim2skinData[primID];
						for (var index:String in skinData.wj) {
							for (var i:int = 0; i < skinData.wj[index].length; i++ ) {
								for (var j:int = 0; j < skinData.wj[index].length;j++ ) {
									var ii:int = int(index) * skin.maxWeight + j;
									weightVec[ii] = skinData.wj[index][j][0];
									jointVec[ii] = skinData.wj[index][j][1];
								}
								for (; j < skin.maxWeight;j++ ) {
									ii = int(index) * skin.maxWeight + j;
									weightVec[ii] = jointVec[ii] = 0;
								}
							}
						}
					}
					drawable.source.weight = weightVec;//new VertexBufferSet(weightVec,skin.maxWeight);
					drawable.source.joint = jointVec;//new VertexBufferSet(jointVec,skin.maxWeight);
					Drawable.optimizeSource(drawable.source);
				}
			}
			
			for (i = 0; i < transPoss.length;i++ ) {
				var m:Matrix3D = new Matrix3D;
				m.copyRawDataFrom(Vector.<Number>(transPoss[i]));
				converter.getConvertedMat4(m);
				skin.joints[i].invBindMatrix.copyFrom(m);
			}
			
			for each(var skinNode:Node3D in skinNodes) {
				Skin.optimize(skinNode);
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
				var o:Object = {childs:[] };
				o.model = model;
				var mtype:String = FbxTools.getType(model);
				o.isJoint = mtype != "Mesh"//(mtype == "LimbNode") || (mtype == "Limb");
				o.isMesh = mtype == "Mesh";
				hobjects[FbxTools.getId(model)] = o;
				name2object[FbxTools.getName(model)] = o;
				objects.push(o);
			}

			// build hierarchy
			for each( o in objects ) {
				var p:Object = getParent(o.model, "Model", true);
				var pid:String =  p == null ? "" : FbxTools.getId(p);
				var op:Object = hobjects[pid];
				if( op == null ) op = oroot; // if parent has been removed
				op.childs.push(o);
				o.parent = op;
			}
			return { root : oroot, objects : objects };
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
			return c[0];
		}

		public function getChilds( node : Object, nodeName : String ):Array {
			var c:Object = connect[FbxTools.getId(node)];
			var subs:Array = [];
			if( c != null ){
				for each(var id:String in c ) {
					var n:Object = ids[id];
					if( n == null ) throw id + " not found";
					if( nodeName != null && n.name != nodeName ) continue;
					subs.push(n);
				}
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
		
		public function loadAnimation(afbx:FbxParser) :void {
			var animDatas:Object = { };
			for each(var a:Object in FbxTools.getAll(afbx.root,"Objects.AnimationStack") ){
				var name:String = FbxTools.getName(a);
				var animData:Object = { };
				animDatas[name] = animData;
				var	animNode:Object = afbx.getChild(a, "AnimationLayer");
				for each(var cn:Object in afbx.getChilds(animNode,"AnimationCurveNode")) {
					var model:Object = afbx.getParent(cn, "Model", true);
					var cname:String = FbxTools.getName(cn);
					if( model == null ) continue;
					var data:Array = afbx.getChilds(cn, "AnimationCurve");
					if( data.length == 0 ) continue;
					var times:Array = FbxTools.getFloats(FbxTools.get(data[0], "KeyTime"));
					if (data.length != 3) {
						continue;
					}
					var x:Object = FbxTools.getFloats(FbxTools.get(data[0],"KeyValueFloat"));
					var y:Object = FbxTools.getFloats(FbxTools.get(data[1],"KeyValueFloat"));
					var z:Object = FbxTools.getFloats(FbxTools.get(data[2], "KeyValueFloat"));
					var mid:String = FbxTools.getId(model);
					var animDataBase:Object= animData[mid] = animData[mid] || { };
					animDataBase[cname] = [x, y, z];
					animDataBase.times = times;
					var targetName:String = FbxTools.getName(model);
					animDataBase.target = name2object[targetName];
					if (animDataBase.target==null){
						trace("can not find anim target name", targetName);
						animData[mid] = null;
						delete animData[mid];
					}
				}
			}
			
			for (name in animDatas) {
				animData in animDatas[name];
				if (animc==null) {
					rootNode.controllers = new Vector.<Ctrl>;
					animc = new SkinAnimationCtrl;
					rootNode.controllers.push(animc);
				}
				var anim:SkinAnimation = new SkinAnimation;
				anim.name = name;
				animc.add(anim);
				anim.targets = skinNodes;
				for each(animDataBase in animData) {
					var track:Track = new Track;
					track.target = animDataBase.target.obj;
					anim.tracks.push(track);
					for (var i:int = 0; i < animDataBase.times.length; i++ ) {
						if (animDataBase.times[i] is Array) {
							var timeValue:Number = animDataBase.times[i][0]+0x100000000*animDataBase.times[i][1];
						}else {
							timeValue = animDataBase.times[i];
						}
						var time:Number = timeValue / 46186158000;
						var s:Array = animDataBase.S;
						var r:Array = animDataBase.R;
						var t:Array = animDataBase.T;
						var frame:TrackFrame = new TrackFrame;
						var sv:Vector3D=null;
						var rv:Vector3D=null;
						var tv:Vector3D=null;
						if (s&&s[0][i]!=null&&s[1][i]!=null&&s[2][i]!=null) {
							sv=new Vector3D(s[0][i], s[1][i], s[2][i]);
						}
						if (r&&r[0][i]!=null&& r[1][i]!=null&& r[2][i]!=null) {
							rv=new Vector3D(r[0][i], r[1][i], r[2][i]);
						}
						if(t&&t[0][i]!=null&& t[1][i]!=null&& t[2][i]!=null){
							tv=new Vector3D(t[0][i], t[1][i], t[2][i]);
						}
						
						frame.matrix = getMatrix(animDataBase.target.m, sv, rv, tv);
						frame.time = time;
						track.frames.push(frame);
					}
					anim.maxTime = anim.maxTime>time?anim.maxTime:time;
				}
			}
		}
	}

}