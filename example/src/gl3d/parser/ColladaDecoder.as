package gl3d.parser 
{
	import flash.geom.Matrix3D;
	import gl3d.core.Drawable3D;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.skin.Skin;
	import gl3d.core.skin.SkinAnimation;
	import gl3d.core.skin.SkinFrame;
	import gl3d.core.skin.Track;
	import gl3d.core.skin.TrackFrame;
	import gl3d.core.VertexBufferSet;
	import gl3d.ctrl.Ctrl;
	import gl3d.meshs.Meshs;
	import gl3d.util.Converter;
	/**
	 * ...
	 * @author lizhi
	 */
	public class ColladaDecoder 
	{
		private var xml:XML;
		public var scenes:Vector.<Node3D> = new Vector.<Node3D>;
		private var animationIDs:Array = [];
		private var animations:Object;
		private var lights:Object;
		private var images:Object;
		private var materials:Object;
		private var effects:Object;
		private var geometries:Object;
		private var controllers:Object;
		private var visualScenes:Object;
		private var sid2node:Object = { };
		private var id2node:Object = { };
		private var skinNodes:Vector.<Node3D> = new Vector.<Node3D>;
		private var anim:SkinAnimation;
		private var converter:Converter;
		public function ColladaDecoder(txt:String) 
		{
			txt = txt.replace(/xmlns=[^"]*"[^"]*"/g,"");
			xml = new XML(txt);
			var asset:XMLList = xml.asset;
			var instanceScenesXML:XMLList = xml.scene.instance_visual_scene;
			
			
			animations = parserLibrary("library_animations","animation",animationIDs);
			lights = parserLibrary("library_lights","light");
			images = parserLibrary("library_images","image");
			materials =parserLibrary("library_materials","material");
			effects =parserLibrary("library_effects","effect");
			geometries =parserLibrary("library_geometries","geometry");
			controllers =parserLibrary("library_controllers","controller"); 
			visualScenes = parserLibrary("library_visual_scenes", "visual_scene"); 
			
			switch (xml.asset.up_axis.text().charAt(0)) {
				case 'X':
					converter = new Converter("XtoY");
					break;
				case 'Y':
					converter = new Converter(null);
					break;
				case 'Z':
					converter = new Converter("ZtoY");
					break;
			}
			
			for each(var sceneNodeXML:XML in instanceScenesXML) {
				var node:Node3D = new Node3D;
				scenes.push(node);
				buildNode(sceneNodeXML,node);
			}
			buildAnimation();
		}
		
		private function parserLibrary(libname:String, name:String,ids:Array=null):Object {
			var obj:Object = { };
			var list:XMLList = xml[libname][name];
			for each(var c:XML in list) {
				obj[c.@id] = c;
				if(ids)ids.push(c.@id + "");
			}
			return  obj;
		}
		
		private function getJointBySID(id:String):Node3D {
			if (sid2node[id]==null) {
				sid2node[id] = new Node3D;
			}
			return sid2node[id];
		}
		
		private function buildNode(nodeXML:XML, node:Node3D):void {
			//node.drawable = Meshs.cube(.4,.4,.4);
			//node.material = new Material;
			node.name = nodeXML.@name;
			id2node[nodeXML.@id] = node;
			node.type = nodeXML.@type;
			if (nodeXML.matrix.length()) {
				node.matrix = converter.getConvertedMat4(str2Matrixs(nodeXML.matrix[0])[0]);
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
				skinNodes.push(skinNode);
				node.addChild(skinNode);
				buildGeometry(geometries[(childXML.@source).substr(1)], skinNode);
				
				var bindShapeMatrix:Matrix3D = str2Matrixs(childXML.bind_shape_matrix)[0];
				var weightsXML:XML = childXML.vertex_weights[0];
				var vcount:Array = str2Floats(weightsXML.vcount.text());
				var v:Array = str2Floats(weightsXML.v.text());
				var weights:Array = str2Floats(childXML.source.(@id==((weightsXML.input.(@semantic == "WEIGHT").@source).toString().substr(1))).float_array.text());
				var invBindMatrixs:Array = str2Matrixs(childXML.source.(@id == ((childXML.joints.input.(@semantic == "INV_BIND_MATRIX").@source).toString().substr(1))).float_array.text());
				for each(var ibm:Matrix3D in invBindMatrixs) {
					converter.getConvertedMat4(ibm);
				}
				var jointNames:Array = str2Strs(childXML.source.(@id == ((weightsXML.input.(@semantic == "JOINT").@source).toString().substr(1))).Name_array.text());
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
						js.push(v[k++]);
						ws.push(weights[v[k++]]);
					}
					for (; i < maxWeight;i++ ) {
						js.push(0);
						ws.push(0);
					}
				}
				var skin:Skin = new Skin;
				skin.invBindMatrixs = Vector.<Matrix3D>(invBindMatrixs);
				skin.maxWeight = maxWeight;
				skin.joints = joints;
				for each(var childNode:Node3D in skinNode.children) {
					childNode.skin = skin;
					var drawable:Drawable3D = childNode.drawable;
					drawable.joints=new  VertexBufferSet(Vector.<Number>(js),maxWeight);
					drawable.weights=new  VertexBufferSet(Vector.<Number>(ws),maxWeight);
				}
			}
		}
		
		private function buildGeometry(nodeXML:XML, node:Node3D):void 
		{
			var vs:Array = str2Floats(getVerticesById((nodeXML.mesh.vertices.@id), nodeXML.mesh[0]).float_array.text());
			var vs2:Array = converter.convertedVec3s(vs) as Array;
			for each(var faceXML:XML in nodeXML.mesh.children()) {
				var name:String = faceXML.localName();
				if (name == "polylist" || name == "triangles") {
					var triangleXML:XML = faceXML;
					var inc:Vector.<uint> = new Vector.<uint>;
					var uvinc:Vector.<uint> = new Vector.<uint>;
					var parray:Array = str2Floats(triangleXML.p);
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
					if (name=="triangles") {
						var i:int = 0;
						var len:int = parray.length;
						while (i < len) {
							inc.push(parray[i+vertexOffset]);
							inc.push(parray[i  +vertexOffset +adder]);
							inc.push(parray[i +vertexOffset+ adder*2]);
							
							uvinc.push(parray[i + uvOffset]);
							uvinc.push(parray[i + uvOffset+adder]);
							uvinc.push(parray[i + uvOffset+adder*2]);
							i += adder*3;
						}
					}else {
						var vcount:Array = str2Floats(triangleXML.vcount);
						var start:int = 0;
						for (i = 0,len=vcount.length; i < len;i++ ) {
							var len2:int = vcount[i] - 2;
							for (var j:int = 0; j < len2;j++ ) {
								inc.push(parray[vertexOffset+adder*start]);
								inc.push(parray[vertexOffset+adder*(start+j+1)]);
								inc.push(parray[vertexOffset+adder*(start+j+2)]);
								uvinc.push(parray[uvOffset+adder*start]);
								uvinc.push(parray[uvOffset+adder*(start+j+1)]);
								uvinc.push(parray[uvOffset+adder*(start+j+2)]);
							}
							start += vcount[i];
						}
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
		}
		
		private function buildAnimation():void {
			anim = new SkinAnimation;
			for each(var animname:String in animationIDs) {
				var animXML:XML = animations[animname];
				var part:AnimationPart = new AnimationPart;
				var track:Track = new Track;
				anim.tracks.push(track);
				for each(var channelXML:XML in animXML.channel) {
					var can:Channel = new Channel;
					var samplerXML:XML = animXML.sampler.(@id == (channelXML.@source.substr(1)))[0];
					can.input= str2Floats(animXML.source.(@id==((samplerXML.input.(@semantic == "INPUT").@source).toString().substr(1))).float_array.text());
					can.output = str2Floats(animXML.source.(@id == ((samplerXML.input.(@semantic == "OUTPUT").@source).toString().substr(1))).float_array.text());
					var targetLine:String = channelXML.@target;
					var result:Object=null;
					if ((result = /(.+)\/(.+)\((\d+)\)\((\d+)\)/.exec(targetLine))) {
						if (result[2]=="transform") {
							can.index = parseInt(result[4]) + parseInt(result[3])*4;
							if (can.index != 15) {
								part.channels.push(can);
							}
						}
					}else if ((result = /(.+)\/(.+)/.exec(targetLine))) {
						if (result[2] == "transform") {
							can.outputMatrix3Ds = floats2Matrixs(can.output);
							can.index = -1;
							part.channels.push(can);
						}
					}
					if (result) {
						track.target = id2node[result[1]];
						for (var i:int = 0; i < can.input.length; i++ ) {
							if (anim.endTime < can.input[i]) {
								anim.endTime = can.input[i];
							}
						}
					}
				}
				var time:Number = 0;
				var matrix:Matrix3D = new Matrix3D;
				while(time<=anim.endTime){//缓存动画矩阵
					var frame:TrackFrame = new TrackFrame;
					part.doAnimation(time, anim.endTime, matrix);
					frame.time = time;
					frame.matrix = converter.getConvertedMat4(part.target.clone());
					track.frames.push(frame);
					time += 1 / 60;
				}
			}
			for each(var skinnode:Node3D in skinNodes) {
				skinnode.controllers = new Vector.<Ctrl>;
				skinnode.controllers.push(anim);
				anim.targets = skinnode.children;
			}
			//a.debugTrace();
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
		
		private function str2Matrixs(str:String,transpose:Boolean=true):Array{
			var vs:Array = str2Floats(str);
			return floats2Matrixs(vs,transpose);
		}
		
		private function floats2Matrixs(vs:Array,transpose:Boolean=true):Array {
			var ms:Array = [];
			var i:int = 0;
			var vs2:Vector.<Number> = Vector.<Number>(vs);
			while (i < vs2.length) {
				var m:Matrix3D = new Matrix3D();
				m.copyRawDataFrom(vs2, i, transpose);
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
import flash.geom.Matrix3D;

class AnimationPart
{
	public var target:Matrix3D;
	public var channels:Vector.<Channel>=new Vector.<Channel>;
	public function AnimationPart() 
	{
	}
	
	public function doAnimation(time:Number, maxTime:Number,target:Matrix3D):void {
		this.target = target;
		var rd:Vector.<Number> = target.rawData;
		for each(var channel:Channel in channels) {
			var i:int = 0;
			var len:int = channel.input.length;
			while (i < len) {
				if (channel.input[i] > time) {
					break;
				}
				i++;
			}
			var j:int = i - 1;
			var v:Number = 0;
			if (j < 0) {
				j = len - 1;
				v =(time-channel.input[j]+maxTime) / (channel.input[i] - channel.input[j]+maxTime);
			}else if (i>=len) {
				i = 0;
				v = (time-channel.input[j]) / (channel.input[i]+maxTime - channel.input[j]);
			}else {
				v = (time-channel.input[j]) / (channel.input[i] - channel.input[j]);
			}
			if (channel.index == -1) {
				var mj:Matrix3D = channel.outputMatrix3Ds[j];
				var mi:Matrix3D = channel.outputMatrix3Ds[i];
				var m:Matrix3D= Matrix3D.interpolate(mi,mj, v);
				m.copyRawDataTo(rd);
			}else {
				rd[channel.index] = channel.output[j] + (channel.output[i] - channel.output[j]) * v;
			}
		}
		target.copyRawDataFrom(rd); 
	}
}

class Channel
{
	public var index:int;
	public var input:Array
	public var output:Array;
	public var outputMatrix3Ds:Array;
	public function Channel() 
	{
		
	}
	
}