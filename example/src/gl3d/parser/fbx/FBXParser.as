package gl3d.parser.fbx 
{
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
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
	import gl3d.util.Converter;
	import gl3d.util.Utils;
	/**
	 * @author lizhi
	 */
	public class FbxParser 
	{
		public var decoder:Object;
		private var ids:Object = { };
		private var connect : Object = { };
		private var namedConnect : Object={};
		private var invConnect : Object={};
		public var skipObjects : Object={};
		private var root:Object;
		private var hobjects:Object;
		public var rootNode:Node3D
		public var skinNodes:Vector.<Node3D> = new Vector.<Node3D>;
		private var converter:Converter;
		public function FbxParser(data:Object) 
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
			
			converter = new Converter(null,new Vector3D(1,1,-1));
			
			root = { name : "Root", props : [FbxProp.PInt(0), FbxProp.PString("Root"), FbxProp.PString("Root")], childs :childs };
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
						if( c.name != "C" &&c.name!="Connect")
							continue;
						var child:String = c.props[1].params[0];
						var parent:String = c.props[2].params[0];

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
		
		private function getDefaultMatrixes( model : Object ):Object {
			var d:Object = { };
			for each(var p:Object in FbxTools.getAll(model, "Properties70.P").concat(FbxTools.getAll(model, "Properties60.Property")) ) {
				var name:String = FbxTools.toString(p.props[0]);
				switch( name) {
				case "GeometricTranslation":
				case "PreRotation":
				case "PostRotation":
				case "Lcl Rotation":
				case "Lcl Translation":
				case "Lcl Scaling":
					var l:int = p.props.length;
					d[name] = new Vector3D(FbxTools.toFloat(p.props[l-3]), FbxTools.toFloat(p.props[l-2]), FbxTools.toFloat(p.props[l-1]));
					break;
				}
			}
			var m:Matrix3D = new Matrix3D;
			m.identity();
			if ( d["Lcl Scaling"] != null ) {
				m.appendScale(d["Lcl Scaling"].x, d["Lcl Scaling"].y, d["Lcl Scaling"].z);
			}
			if ( d["Lcl Rotation"] != null ) {
				m.appendRotation(d["Lcl Rotation"].x, Vector3D.X_AXIS);
				m.appendRotation(d["Lcl Rotation"].y, Vector3D.Y_AXIS);
				m.appendRotation(d["Lcl Rotation"].z, Vector3D.Z_AXIS);
			}
			if ( d["PreRotation"] != null ) {
				m.appendRotation(d["PreRotation"].x, Vector3D.X_AXIS);
				m.appendRotation(d["PreRotation"].y, Vector3D.Y_AXIS);
				m.appendRotation(d["PreRotation"].z, Vector3D.Z_AXIS);
			}
			if ( d["Lcl Translation"] != null ) {
				m.appendTranslation(d["Lcl Translation"].x, d["Lcl Translation"].y, d["Lcl Translation"].z);
			}
			if ( d["PostRotation"] != null ) {
				m.appendRotation(d["PostRotation"].x, Vector3D.X_AXIS);
				m.appendRotation(d["PostRotation"].y, Vector3D.Y_AXIS);
				m.appendRotation(d["PostRotation"].z, Vector3D.Z_AXIS);
			}
			if ( d["GeometricTranslation"] != null ) {
				m.appendTranslation(d["GeometricTranslation"].x, d["GeometricTranslation"].y, d["GeometricTranslation"].z);
			}
			d.matrix = converter.getConvertedMat4(m);
			return d;
		}
		
		public function makeObject( ) :Node3D {
			var scene:Node3D = new Node3D;
			var hgeom:Object = {}
			var hskins:Object = {};
			var hier:Object = buildHierarchy();
			var objects:Array = hier.objects;
			hier.root.obj = scene;

			// create all models
			for each(var o:Object in objects ) {
				var name:String = FbxTools.getName(o.model);
				o.obj = new Node3D(name);
				if ( o.isMesh ) {
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
							var vertices:Array = FbxTools.props2array(verticesData);
							var polygonVertexIndex:Array = FbxTools.props2array(polygonVertexIndexData);
							prim = new FbxGeometry(null, vertices, polygonVertexIndex);
						}
					}
					if (prim) {
						if(prim.drawable==null){
							prim.drawable = Meshs.createDrawable(Vector.<uint>(prim.getIndexes()), Vector.<Number>(converter.convertedVec3s(prim.getVertices())), null, null);
						}
						prim.nodes.push(o.obj);
						(o.obj as Node3D).drawable = prim.drawable;
						(o.obj as Node3D).material = new Material;
						(o.obj as Node3D).material.color = Vector.<Number>([Math.random(),Math.random(),Math.random(),1]);
						(o.obj as Node3D).type = "MESH";
					}
				} else if( o.isJoint ) {
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
				o.m = getDefaultMatrixes(o.model);
				o.obj.matrix = o.m.matrix;
			}
			// rebuild scene hierarchy
			for each( o in objects ) {
				var p:Object = o.parent;
				if(o.obj)
				p.obj.addChild(o.obj);
			}
			// build skins
			for each( o in objects ) {
				if( o.isJoint ) continue;
				// /!\ currently, childs of joints will work but will not cloned
				//if( o.parent.isJoint )
					//o.obj.follow = scene.getObjectByName(o.parent.joint.name);
				var skin:Skin = (o.obj as Node3D).skin;
				if( skin == null ) continue;
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
							var joint:Node3D = o.obj as Node3D;
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
			
			for (i = 0; i < transPoss.length;i++ ) {
				var m:Matrix3D = new Matrix3D;
				m.copyRawDataFrom(Vector.<Number>(transPoss[i]));
				converter.getConvertedMat4(m);
				skin.invBindMatrixs.push(m);
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
				o.isJoint = (mtype == "LimbNode") || (mtype == "Limb");
				o.isMesh = mtype == "Mesh";
				hobjects[FbxTools.getId(model)]= o;
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
			//if( c.length > 1 )
			//	throw node.getName() + " has " + c.length + " " + nodeName + " childs ";
			//if( c.length == 0 && !opt )
			//	throw "Missing " + node.getName() + " " + nodeName + " child";
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
		
		public function loadAnimation() :void {
			var animDatas:Object = { };
			for each(var a:Object in FbxTools.getAll(root,"Objects.AnimationStack") ){
				var name:String = FbxTools.getName(a);
				var animData:Object = { };
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
					var mid:String = FbxTools.getId(model);
					var animDataBase:Object= animData[mid] = animData[mid] || { };
					animDataBase[cname] = [x, y, z];
					animDataBase.times = times;
					animDataBase.target = hobjects[FbxTools.getId(model)];// .obj;
				}
			}
			
			for each(animData in animDatas) {
				var anim3d:SkinAnimation = new SkinAnimation;
				anim3d.targets = skinNodes;
				for each(animDataBase in animData) {
					var track:Track = new Track;
					track.target = animDataBase.target.obj;
					var perRot:Vector3D = animDataBase.target.m.PreRotation;
					var postRot:Vector3D = animDataBase.target.m.PostRotation;
					anim3d.tracks.push(track);
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
						var m:Matrix3D = new Matrix3D;
						if(s){
							m.appendScale(s[0][i], s[1][i], s[2][i]);
						}
						if(r){
							m.appendRotation(r[0][i], Vector3D.X_AXIS);
							m.appendRotation(r[1][i], Vector3D.Y_AXIS);
							m.appendRotation(r[2][i], Vector3D.Z_AXIS);
						}
						if (perRot) {
							m.appendRotation(perRot.x, Vector3D.X_AXIS);
							m.appendRotation(perRot.y, Vector3D.Y_AXIS);
							m.appendRotation(perRot.z, Vector3D.Z_AXIS);
						}
						if(t){
							m.appendTranslation(t[0][i], t[1][i], t[2][i]);
						}
						if (postRot) {
							m.appendRotation(postRot.x, Vector3D.X_AXIS);
							m.appendRotation(postRot.y, Vector3D.Y_AXIS);
							m.appendRotation(postRot.z, Vector3D.Z_AXIS);
						}
						
						frame.matrix = converter.getConvertedMat4(m);
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