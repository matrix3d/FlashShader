package gl3d.parser.dae 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import gl3d.core.Drawable;
	import gl3d.core.DrawableSource;
	import gl3d.core.skin.Joint;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.skin.Skin;
	import gl3d.core.skin.SkinAnimation;
	import gl3d.core.skin.SkinAnimationCtrl;
	import gl3d.core.skin.SkinFrame;
	import gl3d.core.skin.Track;
	import gl3d.core.skin.TrackFrame;
	import gl3d.core.VertexBufferSet;
	import gl3d.ctrl.Ctrl;
	import gl3d.meshs.Meshs;
	import gl3d.util.Converter;
	import gl3d.util.MatLoadMsg;
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
		public var animc:SkinAnimationCtrl;
		private var converter:Converter;
		private var controllerTasks:Array = [];
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
			
			var up_axistext:String = xml.asset.up_axis.text();
			if (up_axistext.length>0){
				up_axistext = up_axistext.charAt(0);
			}
			
			switch (up_axistext) {
				case 'X':
					converter = new Converter(Converter.XtoY);
					break;
				case 'Y':
					converter = new Converter(0);
					break;
				case 'Z':
					converter = new Converter(Converter.ZtoY);
					break;
				default:
					converter = new Converter(0,new Vector3D(1,1,-1));
			}
			
			for each(var sceneNodeXML:XML in instanceScenesXML) {
				var node:Node3D = new Node3D;
				scenes.push(node);
				buildNode(sceneNodeXML,node);
			}
			for each(var ct:Array in controllerTasks) {
				buildController(ct[0],ct[1]);
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
				throw "not have joint " + id;
				//sid2node[id] = new Node3D;
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
						controllerTasks.push([childXML,node]);
						//buildController(childXML,node);
					}else if (name=="instance_geometry") {
						buildGeometry(geometries[(childXML.@url).substr(1)], node);
					}else if (name=="node") {
						var childNode:Node3D
						if (childXML.@type=="JOINT") {
							childNode = new Joint;
							sid2node[childXML.@sid] = childNode;
							//getJointBySID(childXML.@sid);
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
				
				/**********asc2 bug******/
				(weightsXML.input.(@semantic == "WEIGHT").@source)
				/*****************/
				
				var weights:Array = str2Floats(childXML.source.(@id==((weightsXML.input.(@semantic == "WEIGHT").@source).toString().substr(1))).float_array.text());
				var invBindMatrixs:Array = str2Matrixs(childXML.source.(@id == ((childXML.joints.input.(@semantic == "INV_BIND_MATRIX").@source).toString().substr(1))).float_array.text());
				for each(var ibm:Matrix3D in invBindMatrixs) {
					converter.getConvertedMat4(ibm);
				}
				var jointNames:Array = str2Strs(childXML.source.(@id == ((weightsXML.input.(@semantic == "JOINT").@source).toString().substr(1))).Name_array.text());
				if (jointNames.length != invBindMatrixs.length) {
					var jointNames2:Array = [];
					var names:Array = [];
					for (var i:int = jointNames.length - 1; i >= 0;i-- ) {
						names.unshift(jointNames[i]);
						jointName = names.join(" ");
						if (sid2node[jointName]) {
							jointNames2.unshift(jointName);
							names = [];
						}
					}
					jointNames = jointNames2;
					if (jointNames.length!=invBindMatrixs.length) {
						throw "error"
					}
				}
				var joints:Vector.<Joint> = new Vector.<Joint>;
				for (i = 0; i < jointNames.length ;i++ ) {
					var jointName:String = jointNames[i];
					var joint:Joint = getJointBySID(jointName) as Joint;
					joint.invBindMatrix = invBindMatrixs[i];
					joints.push(joint);
				}
				
				var maxWeight:int = 0;
				for each(var count:int in vcount ) {
					if (maxWeight < count) maxWeight = count;
				}
				var js:Array = [];// new Vector.<Number>;
				var ws:Array = [];//new Vector.<Number>;
				var k:int = 0;
				for each(count in vcount ) {
					for (i = 0; i < count; i++ ) {
						if(i<Skin.MAX_WEIGHT){
							js.push(v[k++]);
							ws.push(weights[v[k++]]);
						}else{
							k += 2;
						}
					}
					for (; i < maxWeight; i++ ) {
						if(i<Skin.MAX_WEIGHT){
						js.push(0);
						ws.push(0);
						}
					}
				}
				if (maxWeight > Skin.MAX_WEIGHT) {
					trace("error:maxWeight=",maxWeight);
					maxWeight = Skin.MAX_WEIGHT;
				}
				if (maxWeight <= Skin.MAX_WEIGHT) {
					skinNodes.push(skinNode);	
					var skin:Skin = new Skin;
					//skin.invBindMatrixs = Vector.<Matrix3D>(invBindMatrixs);
					skin.maxWeight = maxWeight;
					skin.joints = joints;
					for each(var childNode:Node3D in skinNode.children) {
						childNode.skin = skin;
						var drawable:Drawable = childNode.drawable;
						drawable.source.joint = js;
						drawable.source.weight = ws;
						//drawable.joint=new  VertexBufferSet(Vector.<Number>(js),maxWeight);
						//drawable.weight=new  VertexBufferSet(Vector.<Number>(ws),maxWeight);
					}
				}else {
					trace("error:maxWeight=",maxWeight);
				}
			}
		}
		
		private function buildGeometry(nodeXML:XML, node:Node3D):void 
		{
			var vs:Array = str2Floats(getVerticesById((nodeXML.mesh.vertices.@id), nodeXML.mesh[0]).float_array.text());
			var vs2:Array = converter.convertedVec3s(vs) as Array;
			
			var vmap:Object = {};
			
			for each(var faceXML:XML in nodeXML.mesh.children()) {
				var name:String = faceXML.localName();
				if (name == "polylist" || name == "triangles") {
					var triangleXML:XML = faceXML;
					var inc:Array = [];//new Vector.<uint>;
					var uvinc:Array = [];// new Vector.<uint>;
					var parray:Array = str2Floats(triangleXML.p);
					var maxOffset:int = 0;
					var vertexOffset:int = 0;
					var uvOffset:int = 0;
					var vertexID:String;
					var uvID:String;
					for each(var childXML:XML in triangleXML.input) {
						var offset:int = parseInt(childXML.@offset);
						if (offset > maxOffset) maxOffset = offset;
						var vid:String = childXML.@source;
						if (childXML.@semantic=="VERTEX") {
							vertexOffset = offset;
							vertexID = vid;
						}else if (childXML.@semantic=="TEXCOORD") {
							uvOffset = offset;
							uvID = vid;
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
					childNode.drawable = new Drawable;//Meshs.createDrawable(Vector.<uint>(inc), Vector.<Number>(vs2),null, null);
					childNode.drawable.source = new DrawableSource;
					childNode.drawable.source.index = DrawableSource.getIndex(inc);
					childNode.drawable.source.pos = vs2;
					if(uvID){
						var uvarr:Array = vmap[uvID];
						if (uvarr == null){
							var vsxml:XML = getVerticesById(uvID.substr(1), nodeXML.mesh[0]);
							var suvarr = str2Floats(vsxml.float_array.text());
							var stride:int=parseInt(vsxml.technique_common.accessor.@stride)
							uvarr = [];
							vmap[uvID] = uvarr;
							for (var i:int = 0; i < suvarr.length/stride;i++ ){
								uvarr[2*i] =suvarr[stride*i];
								uvarr[2*i + 1] =-suvarr[stride*i+1]; 
							}
						}
						if(uvarr){
							childNode.drawable.source.uv = uvarr;
							childNode.drawable.source.uvIndex = DrawableSource.getIndex(uvinc);
						}
					}
					childNode.material = new Material;
					
					var materialName:String = triangleXML.@material;
					if (materials[materialName]) {
						var mxml:XML = materials[materialName];
						var effname:String = (mxml.instance_effect[0].@url).substr(1);
						var exml:XML = effects[effname];
						//var color:Array = str2Floats(exml.profile_COMMON.technique.phong.specular.color);
						var ambient:Array = str2Floats(exml.profile_COMMON.technique.phong.ambient.color);
						//childNode.material.color.setTo(color[0],color[1],color[2]);
						if(ambient&&ambient.length>=3)childNode.material.ambient.setTo(ambient[0],ambient[1],ambient[2]);
						var technique:XMLList = exml.profile_COMMON.technique;
						var phong:XMLList = technique.phong;
						if (phong.length()==0){
							phong = technique.blinn;
						}
						var tname:String = phong.diffuse.texture.@texture;
						
						//animXML.sampler.(@id == (channelXML.@source.substr(1)))[0];
						if (tname){
							var sampler:String= exml.profile_COMMON.newparam.(@sid == tname).sampler2D.source[0];
							if (sampler){
								var surface:String = exml.profile_COMMON.newparam.(@sid == sampler).surface.init_from[0];
								if (surface){
									var img:Object = images[surface];
									if (img){
										var url:String = img.init_from;
										if(url){
											new MatLoadMsg(url,null, childNode.material);
										}
									}
								}
							}
						}
					}
					node.addChild(childNode);
				}
				
			}
		}
		
		private function buildAnimation():void {
			var anim:SkinAnimation = new SkinAnimation;
			for each(var animname:String in animationIDs) {
				var animXML:XML = animations[animname];
				if (animXML.animation.length()) {
					animXML = animXML.animation[0];
				}
				var part:AnimationPart = new AnimationPart;
				var track:Track = new Track;
				for each(var channelXML:XML in animXML.channel) {
					var can:Channel = new Channel;
					var samplerXML:XML = animXML.sampler.(@id == (channelXML.@source.substr(1)))[0];
					can.input= str2Floats(animXML.source.(@id==((samplerXML.input.(@semantic == "INPUT").@source).toString().substr(1))).float_array.text());
					can.output = str2Floats(animXML.source.(@id == ((samplerXML.input.(@semantic == "OUTPUT").@source).toString().substr(1))).float_array.text());
					var targetLine:String = channelXML.@target;
					var result:Object=null;
					if ((result = /(.+)\/(.+)\((\d+)\)\((\d+)\)/.exec(targetLine))!=null) {
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
						anim.tracks[result[1]] = track;
						//track.targetName = result[1];
						for (var i:int = 0; i < can.input.length; i++ ) {
							if (anim.maxTime < can.input[i]) {
								anim.maxTime = can.input[i];
							}
						}
					}
				}
				var time:Number = 0;
				var matrix:Matrix3D = new Matrix3D;
				while(time<=anim.maxTime){//缓存动画矩阵
					var frame:TrackFrame = new TrackFrame;
					part.doAnimation(time, anim.maxTime, matrix);
					frame.time = time;
					frame.matrix = converter.getConvertedMat4(part.target.clone());
					track.frames.push(frame);
					time += 1 / 60;
				}
			}
			for each(var skinnode:Node3D in skinNodes) {
				skinnode.controllers = new Vector.<Ctrl>;
				animc = new SkinAnimationCtrl;
				skinnode.controllers.push(animc);
				animc.add(anim);
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
					return getVerticesById((child.input.(@semantic == "POSITION").@source).substr(1),mesh);
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