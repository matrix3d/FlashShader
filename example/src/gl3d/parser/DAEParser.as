package gl3d.parser 
{
	import flash.display.BitmapData;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import gl3d.core.Drawable3D;
	import gl3d.core.IndexBufferSet;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.skin.Skin;
	import gl3d.core.skin.SkinAnimation;
	import gl3d.core.skin.SkinFrame;
	import gl3d.core.skin.Track;
	import gl3d.core.skin.TrackFrame;
	import gl3d.core.TextureSet;
	import gl3d.core.VertexBufferSet;
	import gl3d.ctrl.Ctrl;
	import gl3d.meshs.Meshs;
	import gl3d.shaders.PhongGLShader;
	
	import org.ascollada.core.*;
	import org.ascollada.fx.*;

	/**
	 * @author Tim Knip / Floorplanner.com
	 */
	public class DAEParser extends EventDispatcher 
	{
		
		/**
		 * Default frame duration, used when #bakeAnimations is set to true. @see #bakeAnimations
		 */
		public static var DEFAULT_FRAME_DURATION : Number = 0.333;
		
		/** */
		public var document :DaeDocument;
		
		/** */
		public var target :Node3D;
		
		private var _objectToNode :Dictionary;
		private var _nodeToObject :Dictionary;
		private var _nodeToMesh :Dictionary;
		private var _numVertices :uint;
		private var _numTriangles :uint;
		private var _parseStartTime :int;
		private var _fileSearchPaths :Array;
		private var _bakeAnimations :Boolean;
		private var _bakeFrameDuration :Number;
		private var animations:Array = [];
		private var animation:SkinAnimation = new SkinAnimation;
		public var root:Node3D;
		
		/**
		 *  
		 */
		public function DAEParser() 
		{
			super();
			
			_fileSearchPaths = new Array();
			_bakeAnimations = true;
			_bakeFrameDuration = DEFAULT_FRAME_DURATION;
		}

		/**
		 * Adds a path to search for referenced files like images, xrefs etc.
		 * 
		 * @param path
		 */
		public function addFileSearchPath(path : String) : void 
		{
			_fileSearchPaths.push(path);			
		}
		
		/**
		 *  
		 */
		public function load(root:Node3D, asset:*) : void 
		{
			this.root =root||new Node3D;
			this.target = new Node3D;
			
			if (asset is ByteArray || asset is XML) 
			{
				parseXML(new XML(asset));
			} 
			else if (asset is String) 
			{
				var loader :URLLoader = new URLLoader();
				
				loader.addEventListener(Event.COMPLETE, onFileLoadComplete);
				loader.addEventListener(ProgressEvent.PROGRESS, onFileLoadProgress);
				
				loader.load(new URLRequest(String(asset)));
			} 
			else 
			{
				throw new IllegalOperationError("Expected an url, some XML or a ByteArray!");
			}
		}
		
		/**
		 * 
		 * @param parent
		 * @param node
		 */
		private function buildAnimations(node : DaeNode) : void 
		{
			if(!node.channels) 
			{
				return;
			}
			
			var target : Node3D = _nodeToObject[node];
			if(!target) 
			{
				trace("no target for node " + node.id);
				return;
			}
			
			var matrixStackTrack :Track = buildMatrixStackTrack(node);
			matrixStackTrack.target = target;
			//var track/* : AbstractTrack*/ = matrixStackTrack;
			
			if(matrixStackTrack) 
			{
				animation.tracks.push(matrixStackTrack);
				for each(var f:TrackFrame in matrixStackTrack.frames) {
					if (f.time>animation.endTime) {
						animation.endTime = f.time;
					}
				}
				
				//var controller ={}//:AnimationController = new AnimationController(target);
				//if(_bakeAnimations) 
				//{
					// bake!
					//track = matrixStackTrack.bake(_bakeFrameDuration) || matrixStackTrack;
				//} 
				///controller.addTrack(track);
				
				//target.animation = controller;
				
			}
		}
		
		/**
		 * 
		 */
		private function buildMatrixStackTrack(node : DaeNode) : Track/*MatrixStackTrack*/ 
		{
			var transform : DaeTransform;
			//var channel : DaeChannel;
			var matrixStackTrack:Track = new Track();
			var i : int;
			for(i = 0; i < node.transforms.length; i++) 
			{
				//var track /*:AbstractTrack;*/
				
				transform = node.transforms[i];	
				//channel = node.getTransformChannelBySID(transform.sid);
				switch(transform.nodeName)
				{
					case "matrix":
						matrixStackTrack = buildMatrixTrack(node, transform);
						break;
					//case "rotate":
						//track = channel ? buildRotationTrack(channel, transform) : null/*new RotationTrack()*/;
						//break;
					//case "scale":
						//track = channel ? buildScaleTrack(channel, transform) :null/* new ScaleTrack()*/;
						//break;
					//case "translate":
						//track = channel ? buildTranslationTrack(channel, transform) :null /*new TranslationTrack()*/;
						//break;
					default:
						trace("unhandled transform type : " + transform.nodeName);
						continue;
				}
				
				/*if(track) 
				{	
					if(!channel) 
					{
						//track.addKeyframe(new NumberKeyframe3D(0, Vector.<Number>(transform.data.concat())));
					}
					matrixStackTrack.addTrack(track);	
					
					if(channel && channel.animation.clips) 
					{
						trace("CLIPS: " + channel.animation.id + " " + channel.animation.clips[0].id);	
					}
				}*/
			}
			
			return matrixStackTrack;
		}
		
		private function buildMatrixTrack(node : DaeNode, transform : DaeTransform) :Track
		{
			var track:Track = new Track;
			var frame2data:Dictionary = new Dictionary;
			for each(var channel:DaeChannel in node.channels) {
				if (transform.sid!=channel.targetSID) {
					continue;
				}
				var input : Array = channel.sampler.input.data;
				var output : Array = channel.sampler.output.data;
				var i : int;
				
				if (track.frames.length<=input.length) {
					track.frames.length = input.length;
				}
				for(i = 0; i < input.length; i++) 
				{
					if (track.frames[i]==null) {
						track.frames[i] = new TrackFrame;
						track.frames[i].matrix = new Matrix3D;
						frame2data[track.frames[i]] = Vector.<Number>(transform.data);
						track.frames[i].time = time;
					}
					var frame:TrackFrame = track.frames[i];
					
					var time : Number = input[i];
					var data : Vector.<Number> = frame2data[frame];
					if(channel.type == DaeChannel.ARRAY_ACCESS) 
					{
						if(channel.arrayIndex0 >= 0 && channel.arrayIndex1 >= 0) 
						{
							var idx : int = channel.arrayIndex1 *4 + channel.arrayIndex0;
							data[idx] = output[i];
						}
					}
					
					if(!data) 
					{
						trace("DAEParser#buildBakedMatrixTrack : invalid data!");
						continue;
					}
				}
			}
			for each(frame in track.frames) {
				frame.matrix.copyRawDataFrom(frame2data[frame], 0, true);
			}
			return track;
		}
		
		private function buildRotationTrack(channel:DaeChannel, transform:DaeTransform):Object/*RotationTrack*/ 
		{
			if(!channel.sampler || !channel.sampler.input || !channel.sampler.output) 
			{
				trace("invalid animation channel! " + channel.source + " " + channel.target);
				return null;
			}
			
			var track:Track// : RotationTrack = new RotationTrack();
			var input : Array = channel.sampler.input.data;
			var output : Array = channel.sampler.output.data;
			var i : int;

			for(i = 0; i < input.length; i++) 
			{
				var time : Number = input[i];
				var data : Array = output[i] is Array ? output[i] : [output[i]];
				var vdata : Vector.<Number>;
				
				switch(channel.targetMember) 
				{
					case "ANGLE":
						vdata = new Vector.<Number>(4);
						vdata[0] = transform.data[0];
						vdata[1] = transform.data[1];
						vdata[2] = transform.data[2];
						vdata[3] = data[0];
						//track.addKeyframe(new NumberKeyframe3D(time, vdata));
						break;
					default:
						trace("unhandled channel " + channel);
						break;
				}
			}
			return track;
		}
		
		private function buildScaleTrack(channel:DaeChannel, transform:DaeTransform):Object/*ScaleTrack*/ 
		{
			if(!channel.sampler || !channel.sampler.input || !channel.sampler.output) 
			{
				trace("invalid animation channel! " + channel.source + " " + channel.target);
				return null;
			}
			
			var track:Track //: ScaleTrack = new ScaleTrack();
			var input : Array = channel.sampler.input.data;
			var output : Array = channel.sampler.output.data;
			var i : int;

			for(i = 0; i < input.length; i++) 
			{
				var time : Number = input[i];
				var data : Array = output[i] is Array ? output[i] : [output[i]];
				var vdata : Vector.<Number> = new Vector.<Number>(3);
				
				vdata[0] = transform.data[0];
				vdata[1] = transform.data[1];
				vdata[2] = transform.data[2];
						
				switch(channel.targetMember) {
					case "X":
						vdata[0] = data[0];
						break;
					case "Y":
						vdata[1] = data[0];
						break;
					case "Z":
						vdata[2] = data[0];
						break;
					default:
						trace("DAEParser#buildScaleTrack : unhandled " + channel);
						continue;
				}
				//track.addKeyframe(new NumberKeyframe3D(time, vdata));
			}
			return track;
		}
		
		/**
		 * 
		 */
		private function buildTranslationTrack(channel:DaeChannel, transform:DaeTransform):Object/*TranslationTrack*/ 
		{
			if(!channel.sampler || !channel.sampler.input || !channel.sampler.output) 
			{
				trace("invalid animation channel! " + channel.source + " " + channel.target);
				return null;
			}
			
			var track:Track //: TranslationTrack = new TranslationTrack();
			var input : Array = channel.sampler.input.data;
			var output : Array = channel.sampler.output.data;
			var i : int;

			for(i = 0; i < input.length; i++) 
			{
				var time : Number = input[i];
				var data : Array = output[i] is Array ? output[i] : [output[i]];
				var vdata : Vector.<Number> = new Vector.<Number>(3);
				
				vdata[0] = transform.data[0];
				vdata[1] = transform.data[1];
				vdata[2] = transform.data[2];
						
				switch(channel.targetMember) 
				{
					case "X":
						vdata[0] = data[0];
						break;
					case "Y":
						vdata[1] = data[0];
						break;
					case "Z":
						vdata[2] = data[0];
						break;
					default:
						if(channel.targetMember == null && data.length == 3) 
						{
							vdata = Vector.<Number>(data);
						} 
						else 
						{
							trace("DAEParser#buildTranslationTrack : unhandled " + channel);
							continue;
						}
						break;
				}
				//track.addKeyframe(new NumberKeyframe3D(time, vdata));
			}
			return track;
		}
		
		/**
		 * 
		 */
		private function buildControllers(target:Node3D/*TriangleMesh*/, node : DaeNode) : void 
		{
			var controllerInstance : DaeInstanceController;
			var controller : DaeController;
			var i : int;
			
			for(i = 0; i < node.controllerInstances.length; i++) 
			{
				controllerInstance = node.controllerInstances[i];
				controller = this.document.controllers[ controllerInstance.url ]; 
				
				if(controller.skin) 
				{
					buildSkinController(target, controllerInstance);
				} 
				else if(controller.morph) 
				{
					buildMorphController(target, controllerInstance);
				}
			}
		}
		
		/**
		 * 
		 * @param parent
		 * @param node
		 */
		private function buildGeometries(parent :Node3D /*TriangleMesh*/, node : DaeNode) : void 
		{
			var geometryInstance :DaeInstanceGeometry;
			var geometry :DaeGeometry;
			
			for each(geometryInstance in node.geometryInstances) 
			{
				var url : String = geometryInstance.url;
				
				if(url.charAt(0) == "#") 
				{
					// local to file
					url = url.substr(1);
				} 
				else 
				{
					// TODO: handle geometry xrefs
					continue;
				}
				
				geometry = this.document.geometries[url];
				if(geometry && geometry.mesh) 
				{
					buildMesh(parent, geometry.mesh, geometryInstance.bindMaterial);
				}
			}
		}
		
		/**
		 * 
		 */
		private function buildMaterial(daeInstanceMaterial:DaeInstanceMaterial, shader:String="diffuse"):Material/*AbstractMaterial*/ 
		{
			var material : Material = null;
			
			if(!daeInstanceMaterial) 
			{
				return material;
			}
			
			var url : String = daeInstanceMaterial.target;
				
			if(url.charAt(0) == "#") 
			{
				// local to file
				url = url.substr(1);
			} 
			else 
			{
				// TODO: handle material xrefs
				return material;
			}
				
			var daeMaterial :DaeMaterial = this.document.materials[url];
			if(!daeMaterial) 
			{
				return material;
			}
			
			var daeEffect :DaeEffect = this.document.effects[daeMaterial.instance_effect];
			if(!daeEffect) 
			{
				return material;
			}
			
			var daeColorOrTexture :DaeColorOrTexture = daeEffect.shader[ shader ];
			if(!daeColorOrTexture) 
			{
				return material;
			}
			
			if(daeEffect.surface || daeColorOrTexture.texture is DaeTexture) 
			{
				var image :DaeImage = daeEffect.surface ? 
									  this.document.images[daeEffect.surface.init_from] : 
									  this.document.images[daeColorOrTexture.texture.texture];

				if(image && image.bitmapData is BitmapData) 
				{
					material = new Material;
					//material.wireframeColor = Vector.<Number>([.5,.5,.5,0]);
					material.diffTexture = new TextureSet(image.bitmapData);
					//material.wireframeAble = true;
					//material = new BitmapMaterial(image.bitmapData.clone());
				}
			} 
			else if(daeColorOrTexture.color) 
			{
				var r :int = daeColorOrTexture.color.r /** 255.0*/;
				var g :int = daeColorOrTexture.color.g /** 255.0*/;
				var b :int = daeColorOrTexture.color.b /** 255.0*/;
				var a :int = daeColorOrTexture.color.a /** 255.0*/;
				//var color :uint = (a << 24 | r << 16 | g << 8 | b);

				//var bitmapData : BitmapData = new BitmapData(1, 1, true, color);
				//material = new BitmapMaterial(bitmapData);
				material = new Material;
				material.color = Vector.<Number>([r,g,b,a]);
			}
			return material;
		}
		 
		/**
		 * Builds a mesh.
		 * 
		 * @param parent
		 * @param daeMesh
		 * @param daeBindMaterial
		 */
		private function buildMesh(parent:Node3D/*TriangleMesh*/, daeMesh:DaeMesh, daeBindMaterial:DaeBindMaterial):void 
		{
			var vertexStart : uint = _nodeToMesh[parent]?_nodeToMesh[parent].length:0;//parent.drawable .triangleGeometry.vertices.length;
			var daeInstMaterial :DaeInstanceMaterial;
			var daePrimitive :DaePrimitive;
			var verticesSource :DaeSource = daeMesh.vertices.source;
			
			buildVertices(parent, daeMesh);
			
			for each(daePrimitive in daeMesh.primitives) 
			{
				daeInstMaterial = daeBindMaterial ? daeBindMaterial.getInstanceMaterialBySymbol(daePrimitive.material) : null;	
				buildPrimitive(parent, daePrimitive, daeInstMaterial, vertexStart);
			}
			
			if(verticesSource && verticesSource.channels && verticesSource.channels.length) 
			{
				trace("vertices are animated!");
			}
		}
		
		/**
		 * 
		 */
		private function buildMorphController(target:Object/*TriangleMesh*/, controllerInstance:DaeInstanceController) : void 
		{
			
		}
		
		/**
		 * Builds a node.
		 * 
		 * @param node
		 * @param parent
		 */
		private function buildNode(node:DaeNode, parent:Node3D) : void 
		{
			var object:Node3D = new Node3D(node.name)//: DisplayObject3D;
			object.type = node.type;
			var i : int;

			if(node.geometryInstances.length || node.controllerInstances.length) 
			{
				buildGeometries(object, node);
			}
			if (node.type=="JOINT") {
				var size:Number = .4;
				//object.drawable = Meshs.cube(size,size,size);
				//object.material = new Material;
			}
			parent.addChild(object);

			for(i = 0; i < node.nodes.length; i++) 
			{
				buildNode(node.nodes[i], object);
			}
			
			object.matrix = buildNodeMatrix(node);
			
			_objectToNode[object] = node;
			_nodeToObject[node] = object;
			
			buildAnimations(node);
		}
		
		/**
		 * Builds a matrix for a node.
		 * 
		 * @param node
		 * 
		 * @return The created Matrix3D
		 */
		private function buildNodeMatrix(node : DaeNode) : Matrix3D 
		{
			var matrix : Matrix3D = new Matrix3D();
			var transform : DaeTransform;
			var i : int;
			
			for(i = 0; i < node.transforms.length; i++) 
			{
				transform = node.transforms[i];
				switch(transform.nodeName) 
				{
					case "rotate":
						var axis : Vector3D = new Vector3D(transform.data[0], transform.data[1], transform.data[2]);
						matrix.prependRotation(transform.data[3], axis);
						break;
					case "scale":
						matrix.prependScale(transform.data[0], transform.data[1], transform.data[2]);
						break;
					case "translate":
						matrix.prependTranslation(transform.data[0], transform.data[1], transform.data[2]);
						break;
					case "matrix":
						var m : Matrix3D = new Matrix3D(Vector.<Number>(transform.data));
						m.transpose();
						matrix.append(m);
						break;
					default:
						break;
				}
			}
			return matrix;
		}
		
		/**
		 * Builds a primitive.
		 * 
		 * @param parent
		 * @param daePrimitive
		 * @param daeInstMaterial
		 * @param vertexStart
		 */
		private function buildPrimitive(parent : Node3D/*TriangleMesh*/, daePrimitive : DaePrimitive, 
										daeInstMaterial : DaeInstanceMaterial, vertexStart : uint) : void {
			var material:Material //: AbstractMaterial;
			var defaultTexCoordInput :DaeInput = (daePrimitive.texCoordInputs && daePrimitive.texCoordInputs.length) ? daePrimitive.texCoordInputs[0] : null;
			var uvIndices : Array = defaultTexCoordInput ? daePrimitive.uvSets[defaultTexCoordInput.setnum] : null;
			var uvs : Array = buildUV(daePrimitive, daeInstMaterial);
			var tri : Array;
			var uv : Array;
			var i : int;
			
			material = buildMaterial(daeInstMaterial);
			if(!material) 
			{
				var bmp : BitmapData = new BitmapData(1,1,false,0xaaaaaa);		
				material = new Material;
				material.diffTexture = new TextureSet(bmp);
				//material = new BitmapMaterial(bmp);
			}
			if(parent.drawable==null){
				parent.drawable = new Drawable3D;
				parent.drawable.pos = new VertexBufferSet(new Vector.<Number>, 3);
				parent.drawable.uv = new VertexBufferSet(new Vector.<Number>, 2);
				parent.drawable.index = new IndexBufferSet(new Vector.<uint>);
			}
			
			var mesh:Array = _nodeToMesh[parent];
			if(daePrimitive.triangles) 
			{
				parent.material = material;
				for(i = 0; i < daePrimitive.triangles.length; i++) 
				{
					tri = daePrimitive.triangles[i];
					var oldi0:int = vertexStart + tri[0];
					var oldi1:int = vertexStart + tri[1];
					var oldi2:int = vertexStart + tri[2];
					var v0:Array = mesh[oldi0];
					var v1:Array = mesh[oldi1];
					var v2:Array = mesh[oldi2];
				
					var t0 : Array;
					var t1 : Array;
					var t2 : Array;

					if(uvs && uvIndices && uvIndices.length == daePrimitive.triangles.length) 
					{
						uv = uvIndices[i];
						t0 = uvs[uv[0]];
						t1 = uvs[uv[1]];
						t2 = uvs[uv[2]];
					} 
					else 
					{
						t0 = [];// new UVCoord();
						t1 = []//new UVCoord();
						t2 = []//new UVCoord();
					}
					parent.drawable.addVertex(v0,t0,oldi0);
					parent.drawable.addVertex(v2,t2,oldi1);
					parent.drawable.addVertex(v1,t1,oldi2);
					_numTriangles++;
				}
			}
		}
		
		/**
		 * 
		 */
		private function buildScene():void
		{
			_objectToNode = new Dictionary(true);
			_nodeToObject = new Dictionary(true);
			_nodeToMesh = new Dictionary(true);
			_numVertices = 0;
			_numTriangles = 0;
			
			target.name = this.document.scene.name;
			
			buildNode(this.document.scene, target);
			
			linkControllers(target);
			
			var elapsed : Number = (getTimer() - _parseStartTime) / 1000;
			
			trace("parsed COLLADA scene '" + target.name + "' in about " + elapsed.toFixed(2) + " seconds.");
			trace(" -> #vertices : " + _numVertices);
			trace(" -> #triangles: " + _numTriangles);
		} 
		
		/**
		 * 
		 */
		private function buildSkinController(target:Node3D/*TriangleMesh*/, controllerInstance:DaeInstanceController) :void /*SkinController*/ 
		{
			var controller : DaeController = this.document.controllers[ controllerInstance.url ];
			var geometry : DaeGeometry;
			var skin : DaeSkin = controller.skin;
			var url : String = skin.source;
			var morphController :DaeController;
			
			if(url.charAt(0) == "#") 
			{
				url = url.substr(1);
			} 
			else 
			{
				// TODO: handle skin controller xrefs
				//return null;
			}
			
			geometry = this.document.geometries[url];
			if(geometry) 
			{
				buildMesh(target, geometry.mesh, controllerInstance.bindMaterial);
			} 
			else 
			{
				morphController = this.document.controllers[url];	
				if(morphController && morphController.morph) 
				{
					var morphInstance : DaeInstanceController = new DaeInstanceController(null, null);
					
					morphInstance.url = morphController.id;
					morphInstance.bindMaterial = controllerInstance.bindMaterial;
					
				//	morphModifier = buildMorphModifier(target, morphInstance);
				}	
			}
			
			var i : int;
			var bindMatrix : Matrix3D = new Matrix3D(Vector.<Number>(skin.bind_shape_matrix.data));
			
			/*
			if(morphModifier) 
			{
				modifier.input = morphModifier;
			}
			*/
			
			bindMatrix.transpose();
			
			animation.bindShapeMatrix = bindMatrix;
			
			var gskin:Skin = new Skin;
			gskin.skinFrame = new SkinFrame;
			for(i = 0; i < skin.joints.length; i++)
			{
				var node : DaeNode = this.document.getNodeByName(skin.joints[i]) || this.document.getNodeBySID(skin.joints[i]);
				
				node = node || this.document.getNodeByID(skin.joints[i]);

				var joint:Node3D = _nodeToObject[node] as Node3D;
				if(!joint) 
				{
					trace("could not find joint with name = " + skin.joints[i]);
					continue;
				}

				var blendWeights : Vector.<DaeBlendWeight> = Vector.<DaeBlendWeight>(skin.getBlendWeightsForJoint(skin.joints[i]));
				
				var transform : DaeTransform = skin.inv_bind_matrix[i];
				var rawData : Array = transform.data;
				var inverseBindMatrix : Matrix3D = new Matrix3D(Vector.<Number>(rawData));
				
				inverseBindMatrix.transpose();
				gskin.skinFrame.matrixs.push(new Matrix3D);	
				gskin.joints.push(joint);
				gskin.invBindMatrixs.push(inverseBindMatrix);
			}
			
			target.controllers = new Vector.<Ctrl>;
			target.controllers.push(animation);
			animation.target = target;
			
			var material:Material = target.material;
			material.gpuSkin = !gskin.useCpu;
			//material.lightAble = false;
			//material.wireframeAble = true;
			target.skin = gskin;
			var drawable:Drawable3D = target.drawable;
			gskin.maxWeight = 0;
			for each(var weights:Array in skin.vertex_weights) {
				if (weights.length>gskin.maxWeight) {
					gskin.maxWeight = weights.length;
				}
			}
			
			drawable.weights = new VertexBufferSet(new Vector.<Number>(gskin.maxWeight*drawable.pos.data.length/3), gskin.maxWeight);
			drawable.joints = new VertexBufferSet(new Vector.<Number>(gskin.maxWeight*drawable.pos.data.length/3), gskin.maxWeight);
			drawable.quatJoints = new VertexBufferSet(new Vector.<Number>(gskin.maxWeight*drawable.pos.data.length/3), gskin.maxWeight);
			for each(weights in skin.vertex_weights) {
				for (i = 0; i < weights.length;i++ ) {
					var weight:DaeBlendWeight = weights[i];
					var jointId:int = skin.joints.indexOf(weight.joint);
					for each(var newIndex:int in drawable.oldIndex2NewIndexs[weight.vertexIndex]) {
						var index:int = gskin.maxWeight * newIndex+ i;
						drawable.weights.data[index] = weight.weight;
						drawable.joints.data[index] = jointId * 4;
						drawable.quatJoints.data[index] = jointId * 2;
					}
				}
			}
			if (gskin.maxWeight > 4) {
				drawable.weights.subBuffs = [[0,0, VertexBufferSet.FORMATS[4]],[0,4, VertexBufferSet.FORMATS[gskin.maxWeight-4]]]
				drawable.joints.subBuffs = [[0,0, VertexBufferSet.FORMATS[4]],[0,4, VertexBufferSet.FORMATS[gskin.maxWeight-4]]]
				drawable.quatJoints.subBuffs = [[0, 0, VertexBufferSet.FORMATS[4]], [0, 4, VertexBufferSet.FORMATS[gskin.maxWeight - 4]]]
			}
		}
		
		/**
		 * Builds uvs.
		 * 
		 * @param p
		 * @param im
		 * 
		 * @return Array of UVCoord
		 */
		private function buildUV(p:DaePrimitive, im:DaeInstanceMaterial) : Array 
		{
			var input : DaeInput = p.texCoordInputs && p.texCoordInputs.length ? p.texCoordInputs[0] : null;
			var source : DaeSource = input ? this.document.sources[input.source] : null;
			var uvs : Array;
			var i : int;
			
			if(im && im.bind_vertex_input && im.bind_vertex_input.length) 
			{
				
			}
			
			if(source) 
			{
				uvs = new Array();
				for(i = 0; i < source.data.length; i++) 
				{
					var data : Array = source.data[i];
					uvs.push([data[0], 1- data[1]]);
				}
			}

			return uvs;
		}
		
		/**
		 * Builds vertices for the specified TriangleMesh.
		 * 
		 * @param target
		 * @param mesh
		 */
		private function buildVertices(target:Node3D/*TriangleMesh*/, mesh:DaeMesh) : void 
		{
			var i : int;
			var data : Array = mesh.vertices.source.data;
			var meshd:Array  = _nodeToMesh[target] || [];
			_nodeToMesh[target] = meshd.concat(data);
			_numVertices += _nodeToMesh[target].length;
		}
		
		/**
		 * Links controllers to the specified object.
		 * 
		 * @param object
		 */
		private function linkControllers(object : Node3D) : void 
		{
			var child:Node3D// : DisplayObject3D;
			
			var node : DaeNode = _objectToNode[object];
			
			if(node&&node.controllerInstances.length) 
			{
				buildControllers(object , node);	
			}
			
			for each(child in object.children) 
			{
				linkControllers(child);
			}
		}
		
		/**
		 * 
		 */
		protected function parseXML(xml:XML):void
		{
			_parseStartTime = getTimer();
			
			this.document = new DaeDocument();
			
			for(var i:int = 0; i < _fileSearchPaths.length; i++) 
			{
				this.document.addFileSearchPath(_fileSearchPaths[i]);
			}
			
			this.document.addEventListener(Event.COMPLETE, onParseComplete);
			this.document.read(xml);	
		}
		
		/**
		 * 
		 */
		protected function onFileLoadComplete(event:Event):void 
		{
			var loader :URLLoader = event.target as URLLoader;
			
			parseXML(new XML(loader.data));
		}
		
		/**
		 * 
		 */
		protected function onFileLoadProgress(event:ProgressEvent):void
		{
			
		}
		
		/**
		 * 
		 */
		protected function onParseComplete(event:Event):void 
		{
			buildScene();
			root.addChild(target);
			dispatchEvent(event);
		}
		
		/**
		 * Whether to bake animations to single MatrixTrack's.
		 */
		public function set bakeAnimations(value : Boolean) : void 
		{
			_bakeAnimations = value;
		}
		
		public function get bakeAnimations() : Boolean 
		{
			return _bakeAnimations;	
		}
		
		/**
		 * The duration of a animation frame. Only used when #bakeAnimations was set to true.
		 */
		public function set bakeFrameDuration(value : Number) : void
		{
			_bakeFrameDuration = value;
		}
		
		public function get bakeFrameDuration() : Number 
		{
			return _bakeFrameDuration;	
		}
	}
}
