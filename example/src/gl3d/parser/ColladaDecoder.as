package gl3d.parser 
{
	import flash.geom.Matrix3D;
	import gl3d.core.Drawable3D;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.skin.Skin;
	import gl3d.core.skin.SkinFrame;
	import gl3d.core.VertexBufferSet;
	import gl3d.meshs.Meshs;
	/**
	 * ...
	 * @author lizhi
	 */
	public class ColladaDecoder 
	{
		private var xml:XML;
		public var scenes:Vector.<Node3D> = new Vector.<Node3D>;
		private var animations:Object;
		private var lights:Object;
		private var images:Object;
		private var materials:Object;
		private var effects:Object;
		private var geometries:Object;
		private var controllers:Object;
		private var visualScenes:Object;
		private var jointmap:Object = { };
		public function ColladaDecoder(txt:String) 
		{
			txt = txt.replace(/xmlns=[^"]*"[^"]*"/g,"");
			xml = new XML(txt);
			var asset:XMLList = xml.asset;
			var instanceScenesXML:XMLList = xml.scene.instance_visual_scene;
			
			
			animations = parserLibrary("library_animations","animation");
			lights = parserLibrary("library_lights","light");
			images = parserLibrary("library_images","image");
			materials =parserLibrary("library_materials","material");
			effects =parserLibrary("library_effects","effect");
			geometries =parserLibrary("library_geometries","geometry");
			controllers =parserLibrary("library_controllers","controller"); 
			visualScenes = parserLibrary("library_visual_scenes", "visual_scene"); 
			
			for each(var sceneNodeXML:XML in instanceScenesXML) {
				var node:Node3D = new Node3D;
				scenes.push(node);
				buildNode(sceneNodeXML,node);
			}
			buildAnimation();
		}
		
		private function parserLibrary(libname:String, name:String):Object {
			var obj:Object = { };
			var list:XMLList = xml[libname][name];
			for each(var c:XML in list) {
				obj[c.@id] = c;
			}
			return  obj;
		}
		
		private function getJointBySID(id:String):Node3D {
			if (jointmap[id]==null) {
				jointmap[id] = new Node3D;
			}
			return jointmap[id];
		}
		
		private function buildNode(nodeXML:XML, node:Node3D):void {
			node.name = nodeXML.@name;
			node.type = nodeXML.@type;
			if (nodeXML.matrix.length()) {
				node.matrix = str2Matrixs(nodeXML.matrix[0])[0];
			}
			var url:String = nodeXML.@url;
			if (url) {
				buildNode(visualScenes[url.substr(1)],node);
			}else {
				for each(var childXML:XML in nodeXML.children()) {
					var name:String = childXML.localName();
					if (name=="instance_controller") {
						buildController(childXML,node);
					}else if (name=="instance_geometry") {
						buildGeometry(geometries[(childXML.@url).substr(1)], node);
					}else if (name=="node") {
						var childNode:Node3D
						if (childXML.@type=="JOINT") {
							childNode = getJointBySID(childXML.@sid);
						}else {
							childNode = new Node3D;
						}
						buildNode(childXML, childNode);
						node.addChild(childNode);
					}else {
						continue;
					}
				}
			}
		}
		
		private function buildController(nodeXML:XML, node:Node3D):void 
		{
			var controllerXML:XML = controllers[(nodeXML.@url).substr(1)];
			for each(var childXML:XML in controllerXML.skin) {
				var skinNode:Node3D = new Node3D;
				node.addChild(skinNode);
				buildGeometry(geometries[(childXML.@source).substr(1)], skinNode);
				
				var bindShapeMatrix:Matrix3D = str2Matrixs(childXML.bind_shape_matrix)[0];
				var weightsXML:XML = childXML.vertex_weights[0];
				var vcount:Array = str2Floats(weightsXML.vcount.text());
				var v:Array = str2Floats(weightsXML.v.text());
				var weights:Array = str2Floats(childXML.source.(@id=[(weightsXML.input.(@semantic = "WEIGHT").@source).toString().substr(1)]).float_array.text());
				var invBindMatrixs:Array = str2Matrixs(childXML.source.(@id = [(childXML.joints.input.(@semantic = "INV_BIND_MATRIX").@source).toString().substr(1)]).float_array.text());
				var jointNames:Array = str2Strs(childXML.source.(@id = [(weightsXML.input.(@semantic = "JOINT").@source).toString().substr(1)]).Name_array.text());
				var joints:Vector.<Node3D> = new Vector.<Node3D>;
				for each(var jointName:String in jointNames) {
					joints.push(getJointBySID(jointName));
				}
				
				var maxWeight:int = 0;
				for each(var count:int in vcount ) {
					if (maxWeight < count) maxWeight = count;
				}
				var js:Vector.<Number> = new Vector.<Number>;
				var ws:Vector.<Number> = new Vector.<Number>;
				var k:int = 0;
				for each(count in vcount ) {
					for (var i:int = 0; i < count; i++ ) {
						js.push(v[k]);
						ws.push(weights[k]);
						k++;
					}
					for (; i < maxWeight;i++ ) {
						js.push(0);
						ws.push(0);
					}
				}
				for each(var childNode:Node3D in skinNode.children) {
					var skin:Skin = new Skin;
					childNode.skin = skin;
					//childNode.material.gpuSkin = true;
					skin.invBindMatrixs =Vector.<Matrix3D>(invBindMatrixs);
					skin.maxWeight = maxWeight;
					skin.joints = joints;
			
					skin.skinFrame = new SkinFrame;
					skin.skinFrame.quaternions = new Vector.<Number>(jointNames.length*4*2);
					
					var drawable:Drawable3D = childNode.drawable;
					drawable.joints=new  VertexBufferSet(Vector.<Number>(js),maxWeight);
					drawable.weights=new  VertexBufferSet(Vector.<Number>(ws),maxWeight);
				}
			}
		}
		
		private function buildGeometry(nodeXML:XML, node:Node3D):void 
		{
			var vs:Array = str2Floats(getVerticesById((nodeXML.mesh.vertices.@id), nodeXML.mesh[0]).float_array.text());
			var vs2:Array = [];
			for (var x:int = 0, len:int = vs.length; x < len;x+=3 ) {
				vs2.push(vs[x]);
				vs2.push(vs[x+2]);
				vs2.push(vs[x+1]);
			}
			for each(var triangleXML:XML in nodeXML.mesh.triangles) {
				//var uv:Array = str2Floats(getVerticesById((triangleXML.input.(@semantic = "TEXCOORD").@source),nodeXML.mesh[0]).float_array);
				var inc:Vector.<uint> = new Vector.<uint>;
				var uvinc:Vector.<uint> = new Vector.<uint>;
				var parray:Array = str2Floats(triangleXML.p);
				var i:int = 0;
				len = parray.length;
				var maxOffset:int = 0;
				var vertexOffset:int = 0;
				var uvOffset:int = 0;
				for each(var childXML:XML in triangleXML.input) {
					var offset:int = parseInt(childXML.@offset);
					if (offset > maxOffset) maxOffset = offset;
					if (childXML.@semantic=="VERTEX") {
						vertexOffset = offset;
					}else if (childXML.@semantic=="TEXCOORD") {
						uvOffset = offset;
					}
				}
				var adder:int = maxOffset + 1;
				while (i < len) {
					inc.push(parray[i+vertexOffset]);
					inc.push(parray[i +vertexOffset+ adder]);
					inc.push(parray[i  +vertexOffset +adder*2]);
					
					uvinc.push(parray[i + uvOffset]);
					uvinc.push(parray[i + uvOffset+adder]);
					uvinc.push(parray[i + uvOffset+adder*2]);
					i += adder*3;
				}
				var childNode:Node3D = new Node3D;
				childNode.drawable = Meshs.createDrawable(Vector.<uint>(inc), Vector.<Number>(vs2), null, null);
				childNode.material = new Material;
				
				var materialName:String = triangleXML.@material;
				if (materials[materialName]) {
					var mxml:XML = materials[materialName];
					var effname:String = (mxml.instance_effect[0].@url).substr(1);
					var exml:XML = effects[effname];
					childNode.material.color = Vector.<Number>(str2Floats(exml.profile_COMMON.technique.phong.specular.color));
					childNode.material.ambient = Vector.<Number>(str2Floats(exml.profile_COMMON.technique.phong.ambient.color));
				}
				node.addChild(childNode);
			}
		}
		
		private function buildAnimation():void {
			for (var animname:String in animations) {
				var animXML:XML = animations[animname];
				for each(var channelXML:XML in animXML.channel) {
					var samplerXML:XML = animXML.sampler.(@id = [channelXML.@source.substr(1)])[0];
				}
			}
			trace(1);
			/*var areg = /(.+)\/(.+)\((\d+)\)\((\d+)\)/;
			var areg2 = /(.+)\/(.+)/;
			var item = new AnimationItem();
			var parts = new Vector();
			var maxTime = .0;
			for (child in dae.elements()) {
				if (child.nodeName == "library_animations") {
					for (xa in child.elements()) {
						if (xa.nodeName=="animation") {
							var anm = new AnimationPart();
							parts.push(anm);
							for (channel in xa.elements()) {
								if (channel.nodeName == "channel") {
									var sourceId = channel.get("source").substr(1);
									var sampler = XPath.xpathNode(xa, "sampler@id="+sourceId);
									var inputId =XPath.xpathNode(sampler,"input@semantic=INPUT").get("source").substr(1);
									var outputId = XPath.xpathNode(sampler, "input@semantic=OUTPUT").get("source").substr(1);
									var input = str2Floats(XPath.xpathNodeValue(xa, "source@id=" + inputId + "/float_array"));
									var output = str2Floats(XPath.xpathNodeValue(xa, "source@id=" + outputId + "/float_array"));
									for (tt in input) {
										if (maxTime < tt) maxTime = tt;
									}
									var target = channel.get("target");
									var can = new Channel();
									if (areg.match(target)) {
										var targetId = areg.matched(1);
										anm.target = id2node.get(targetId);
										var targetKey = areg.matched(2);
										if(targetKey=="transform"){
											var x = Std.parseInt(areg.matched(3));
											var y = Std.parseInt(areg.matched(4));
											can.input = input;
											can.output = output;
											can.index = y + x * 4;
											if (can.index != 15) {
												anm.channels.push(can);
											}
										}
										
									}else {
										if (areg2.match(target)) {
											var targetId = areg2.matched(1);
											anm.target = id2node.get(targetId);
											var targetKey = areg2.matched(2);
											if(targetKey=="transform"){
												can.input = input;
												can.outputMatrix3Ds = floats2Matrixs(output);
												can.index = -1;
												anm.channels.push(can);
											}
										}else {
											throw "error";
										}
									}
								}
							}
						}
					}
				}
			}
			
			var time = .0;
			while(time<=maxTime){//缓存动画矩阵
				for (anm in parts) {//cpu做动画
					anm.doAnimation(time,maxTime);
				}
				for (skin in skins) {//缓存所有动画矩阵
					var matrixs = [];
					item.frames.push(matrixs);
					for (i in 0...skin.joints.length) {
						var joint = skin.joints[i];
						matrixs.push(joint.matrix.clone());
					}
				}
				time += 1 / 60;
			}
			AnimationUtils.startCache(skins[0],wireframe);
			AnimationUtils.startCacheAnim(skins[0], item);*/
		}
		
		private function str2Strs(str:String):Array {
			var r:RegExp = /\s+/g;
			var arr:Array = str.split(r);
			while (arr[0]=="") {
				arr.shift();
			}
			if (arr[arr.length-1]=="") {
				arr.pop();
			}
			return arr;
		}
		
		private function str2Floats(str:String):Array {
			var arr:Array = str2Strs(str);
			var ret:Array = [];
			for each(var v:String in arr) {
				ret.push(parseFloat(v));
			}
			return ret;
		}
		
		private function str2Matrixs(str:String):Array{
			var vs:Array = str2Floats(str);
			return floats2Matrixs(vs);
		}
		
		private function floats2Matrixs(vs:Array):Array {
			var ms:Array = [];
			var i:int = 0;
			var vs2:Vector.<Number> = Vector.<Number>(vs);
			while (i < vs2.length) {
				var m:Matrix3D = new Matrix3D();
				m.copyRawDataFrom(vs2, i, true);
				ms.push(m);
				i += 16;
			}
			return ms;
		}
		
		private function getVerticesById(id:String, mesh:XML):XML
		{
			for each(var child:XML in mesh.children()) {
				var name:String = child.localName();
				if (name=="source"&&child.@id==id) {
					return child;
				}
				if (name=="vertices"&&child.@id==id) {
					return getVerticesById((child.input.@source).substr(1),mesh);
				}
			}
			return null;
		}
	}

}