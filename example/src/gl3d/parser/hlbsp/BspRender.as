package gl3d.parser.hlbsp
{
	import flash.display.BitmapData;
	import flash.display.PNGEncoderOptions;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.net.FileReference;
	import flash.utils.Dictionary;
	import gl3d.core.Drawable;
	import gl3d.core.IndexBufferSet;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.TextureSet;
	import gl3d.core.VertexBufferSet;
	import gl3d.core.View3D;
	import gl3d.core.shaders.GLShader;
	import gl3d.meshs.Meshs;
	import gl3d.shaders.LightMapFragmentShader;
	import gl3d.shaders.LightMapGLShader;
	import gl3d.shaders.LightMapVertexShader;
	import org.villekoskela.utils.RectanglePacker;
	
	/**
	 * ...
	 * @author lizhi
	 */
	public class BspRender
	{
		public var target:Node3D = new Node3D;
		private var bsp:Bsp;
		private var indexs:Array;
		private var bmd2texture:Dictionary = new Dictionary;
		private var view:View3D;
		private var bspRenderNode:BspRenderNode;
		
		private var vertices:Array;
		private var texCoords:Array;
		private var lightmapCoords:Array;
		private var normals:Array;
		
		private var min2maxLightmap:Object = {};//key id ,value bmd
		private var min2maxid:Object = {};
		public function BspRender(bspRenderNode:BspRenderNode)
		{
			this.bspRenderNode = bspRenderNode;
			this.view = bspRenderNode.view;
			this.bsp = bspRenderNode.bsp;
		
		}
		
		public function preRender():void
		{
			//合并lightmap贴图
			var rps:Array = [];
			var rp:RectanglePacker;// = new RectanglePacker(2048, 2048);
			var maxbmd:BitmapData;
			var min2maxrect:Object = {};//key id,value rectagele
			for (var i:int = 0; i < bsp.lightmapLookup.length;i++ ){
				var bmd:BitmapData = bsp.lightmapLookup[i] as BitmapData;
				if (bmd){
					while(true){
						if (rp==null){
							rp = new RectanglePacker(2048, 2048, 1);
							rps.push(rp);
							maxbmd = new BitmapData(2048, 2048, true,0);
						}
						var count:int = rp.rectangleCount;
						rp.insertRectangle(bmd.width, bmd.height, i);
						rp.packRectangles(false);
						if (rp.rectangleCount<=count){
							rp = null;
						}else{
							min2maxid[i] = rps.length-1;
							min2maxLightmap[i] = maxbmd;
							var rect:Rectangle = new Rectangle;
							min2maxrect[i] = rp.getRectangle(rp.rectangleCount - 1, rect);
							maxbmd.copyPixels(bmd, bmd.rect, new Point(rect.x, rect.y));
							break;
						}
					}
				}
			}
			
			//var f:FileReference = new FileReference;
			//f.save(maxbmd.encode(maxbmd.rect, new PNGEncoderOptions), "1.png");
			
			
			//////////////////////////
			
			vertices = new Array();
			texCoords = new Array();
			lightmapCoords = new Array();
			normals = new Array();
			
			indexs = [];
			
			bsp.faceBufferRegions = new Array(bsp.faces.length);
			var elements:int = 0;
			
			// for each face
			for (var i:int = 0; i < bsp.faces.length; i++)
			{
				rect = min2maxrect[i];
				var face:BspFace = bsp.faces[i];
				var index:Vector.<uint> = new Vector.<uint>;
				indexs[i] = new IndexBufferSet(index);
				bsp.faceBufferRegions[i] = {start: elements, count: face.edges};
				
				var texInfo:BspTextureInfo = bsp.textureInfos[face.textureInfo];
				var plane:BspPlane = bsp.planes[face.plane];
				
				var normal:Vector3D = plane.normal;
				
				var faceTexCoords:Array = bsp.textureCoordinates[i];
				var faceLightmapCoords:Array = bsp.lightmapCoordinates[i];
				
				for (var j:int = 0; j < face.edges; j++)
				{
					var edgeIndex:int = bsp.surfEdges[face.firstEdge + j]; // This gives the index into the edge lump
					
					var vertexIndex:int;
					if (edgeIndex > 0)
					{
						var edge:BspEdge = bsp.edges[edgeIndex];
						vertexIndex = edge.vertices[0];
					}
					else
					{
						edgeIndex *= -1;
						edge = bsp.edges[edgeIndex];
						vertexIndex = edge.vertices[1];
					}
					
					var vertex:Vector3D = bsp.vertices[vertexIndex];
					
					var texCoord:Object = faceTexCoords[j];
					var lightmapCoord:Object = faceLightmapCoords[j];
					
					// Write to buffers
					vertices.push(vertex.x);
					vertices.push(vertex.y);
					vertices.push(vertex.z);
					
					texCoords.push(texCoord.s);
					texCoords.push(texCoord.t);
					
					//根据st计算出新的st
					if(rect){
						lightmapCoords.push(rect.x/2048+rect.width/2048*lightmapCoord.s);
						lightmapCoords.push(rect.y / 2048 + rect.height / 2048 * lightmapCoord.t);
					}else{
						///////////
						lightmapCoords.push(lightmapCoord.s);
						lightmapCoords.push(lightmapCoord.t);
					}
					
					normals.push(normal.x);
					normals.push(normal.y);
					normals.push(normal.z);
					
					elements += 1;
					
					if (j > 1)
					{
						var start:int = bsp.faceBufferRegions[i].start
						index.push(start, j + start, j + start-1);
					}
				}
			}
			var drawable:Drawable = Meshs.createDrawable(null, Vector.<Number>(vertices), Vector.<Number>(texCoords),Vector.<Number>(normals),null);
			target.drawable = drawable;
			drawable.uv2 = new VertexBufferSet(Vector.<Number>(lightmapCoords), 2);
			target.material = new Material;
			target.material.diffTexture = new TextureSet(new BitmapData(1, 1));
			target.material.lightmapTexture = new TextureSet(new BitmapData(1, 1));
			(target.material as Material).shader = new GLShader(new LightMapVertexShader(), new LightMapFragmentShader(target.material as Material));// new LightMapGLShader;
		}
		
		/**
		 * 
		 * @return 0 obj,1 mtl
		 */
		public function toOBJ(name:String = "",mtllib:String=""):Array{
			var mtl:String = "";
			var t2f:Object = {};
			for each(var faceIndex:int in bsp.markSurfaces){
				var face:BspFace = bsp.faces[faceIndex];
				
				if (face.styles[0] == 0xFF)
					continue; // Skip sky faces
				var texInfo:BspTextureInfo = bsp.textureInfos[face.textureInfo];
				if (t2f[texInfo.mipTexture]==null){
					t2f[texInfo.mipTexture] = [];
					
					var bmd:BitmapData = bsp.textureLookup[texInfo.mipTexture];
					var m:BspMipTexture = bsp.mipTextures[texInfo.mipTexture]; 
					var mname:String = ((bmd&&bmd!=bsp.whiteTexture)?name:"") + m.name;
					
					mtl += "newmtl " + mname+"\r\n"
					+"Kd 1.0000 1.0000 1.0000\r\n"
					+"illum 0\r\n"
					+"map_Kd "+mname+".png\r\n"
					
				}
				t2f[texInfo.mipTexture].push(faceIndex);
			}
			
			var obj:String = "# objencode v0.1\r\n";
			obj += "mtllib "+mtllib + "\r\n";
			var drawable:Drawable = target.drawable;
			var v:Vector.<Number> = drawable.pos.data;
			for (var i:int = 0; i < v.length;i+=3 ) {
				obj +="v "+ v[i]+" "+v[i+1]+" "+(v[i+2])+"\r\n";
			}
			var vt:Vector.<Number> = drawable.uv.data;
			for (i = 0; i < vt.length;i+=2 ) {
				obj +="vt "+ vt[i]+" "+(1-vt[i+1])+"\r\n";
			}
			obj += "s off\r\n";
			for (var tid:int in t2f){
				var bmd:BitmapData = bsp.textureLookup[tid];
				var m:BspMipTexture = bsp.mipTextures[tid];
				var mname:String = ((bmd&&bmd!=bsp.whiteTexture)?name:"") + m.name;
				obj += "g " + mname + "\r\n"
				+"usemtl " + mname + "\r\n";
				for each(faceIndex in t2f[tid]){
					var face:BspFace = bsp.faces[faceIndex];
					if (face.styles[0] == 0xFF)
						continue; // Skip sky faces
					var texInfo:BspTextureInfo = bsp.textureInfos[face.textureInfo];
					
					// if the light map offset is not -1 and the lightmap lump is not empty, there are lightmaps
					var lightmapAvailable:Boolean = face.lightmapOffset != -1 && bsp.header.lumps[Bsp.LUMP_LIGHTING].length > 0;
					//gl.activeTexture(gl.TEXTURE1);
					//gl.bindTexture(gl.TEXTURE_2D, this.lightmapLookup[faceIndex]);
					var ins:Vector.<uint>=  (indexs[faceIndex] as IndexBufferSet).data;
					
					for (i = 0; i < ins.length; i += 3 ) {
						var i0:int = ins[i]+ 1;
						var i1:int = ins[i+1]+ 1;
						var i2:int = ins[i+2]+1;
						obj +="f "+ i0+"/"+i0+" "+ i1+"/"+i1+" "+ i2+"/"+i2+"\r\n"
					}
				}
			}
			return [obj,mtl];
		}
		
		public function renderAll():Node3D{
			var t2f:Object = {};
			for each(var faceIndex:int in bsp.markSurfaces){
				var face:BspFace = bsp.faces[faceIndex];
				if (face.styles[0] == 0xFF)
					continue; // Skip sky faces
				var texInfo:BspTextureInfo = bsp.textureInfos[face.textureInfo];
				var key:uint = (texInfo.mipTexture << 16) | min2maxid[faceIndex];
				if (t2f[key]==null){
					t2f[key] = [];
				}
				t2f[key].push(faceIndex);
			}
			
			var n:Node3D = new Node3D;
			for (var keyv:String in t2f){
				key = parseInt(keyv);
				var tid:int = key >> 16;
				var i2:Array = [];
				for each(faceIndex in t2f[keyv]){
					var face:BspFace = bsp.faces[faceIndex];
					if (face.styles[0] == 0xFF)
						continue; // Skip sky faces
					for each(var ii:uint in (indexs[faceIndex] as IndexBufferSet).data){
						i2.push(ii);
					}
				}
				
				if(i2.length>0){
					var target:Node3D = new Node3D;
						
					var drawable:Drawable = new Drawable;//Meshs.createDrawable(null, Vector.<Number>(vertices), Vector.<Number>(texCoords),Vector.<Number>(normals),null);
					drawable.uv = this.target.drawable.uv;
					drawable.pos = this.target.drawable.pos;
					drawable.uv2 = this.target.drawable.uv2;
					drawable.norm = this.target.drawable.norm;
					target.drawable = drawable;
					target.material = new Material;
					
					var bmd:BitmapData= bsp.textureLookup[tid];
					var lbmd:BitmapData = min2maxLightmap[key&0xffff];
					
					target.drawable.index = new IndexBufferSet(Vector.<uint>(i2));
					
					var texture:TextureSet = bmd2texture[bmd];
					var ltexture:TextureSet = bmd2texture[lbmd];
					if (texture==null) {
						texture=bmd2texture[bmd]=new TextureSet(bmd);
					}
					if (ltexture==null) {
						ltexture=bmd2texture[lbmd]=new TextureSet(lbmd);
					}
					target.material.diffTexture = texture;
					target.material.lightmapTexture = ltexture;
					n.addChild(target);
					(target.material as Material).shader = new GLShader(new LightMapVertexShader(), new LightMapFragmentShader(target.material as Material));// new LightMapGLShader;
		
				}
			}
			return n;
		}
		
		/**
		 * Renders the complete level.
		 */
		public function render(cameraPos:Vector3D):void
		{
			// enable/disable the required attribute arrays
			//gl.enableVertexAttribArray(texCoordLocation);  	
			//gl.enableVertexAttribArray(lightmapCoordLocation);  
			//gl.enableVertexAttribArray(normalLocation); 
			//gl.disableVertexAttribArray(colorLocation);
			
			// Bind the vertex buffer
			//gl.bindBuffer(gl.ARRAY_BUFFER, this.vertexBuffer);  
			//gl.vertexAttribPointer(positionLocation, 3, gl.FLOAT, false, 0, 0);
			
			// Bind texture coordinate buffer
			//gl.bindBuffer(gl.ARRAY_BUFFER, this.texCoordBuffer);
			//gl.vertexAttribPointer(texCoordLocation, 2, gl.FLOAT, false, 0, 0);
			
			// Bind lightmap coordinate buffer
			//gl.bindBuffer(gl.ARRAY_BUFFER, this.lightmapCoordBuffer);
			//gl.vertexAttribPointer(lightmapCoordLocation, 2, gl.FLOAT, false, 0, 0);
			
			// Bind normal coordinate buffer
			//gl.bindBuffer(gl.ARRAY_BUFFER, this.normalBuffer);
			//gl.vertexAttribPointer(normalLocation, 3, gl.FLOAT, false, 0, 0);
			
			// Get the leaf where the camera is in
			var cameraLeaf:int = bsp.traverseTree(cameraPos, 0);
			//console.log("Camera in leaf " + cameraLeaf);
			
			// Start the render traversal on the static geometry
			this.renderNode(0, cameraLeaf, cameraPos);
			
			// Now render all the entities
			for (var i:int = 0; i < bsp.brushEntities.length; i++)
				this.renderBrushEntity(bsp.brushEntities[i], cameraPos);
		}
		
		/**
		 * Renders the given brush entity.
		 *
		 * @param entity An instance of Entity which is a brush entity (it must have a property "model").
		 * @param cameraPos The current camera position.
		 */
		public function renderBrushEntity(entity:Entity, cameraPos:Vector3D):void
		{
			// Model
			var modelIndex:int = parseInt(entity.properties["model"].substring(1));
			var model:BspModel = bsp.models[modelIndex];
			
			// Alpha value
			var alpha:int;
			var renderamt:String = entity.properties["renderamt"];
			if (renderamt == null)
				alpha = 255;
			else
				alpha = parseInt(renderamt);
			
			// Rendermode
			var renderMode:int;
			var renderModeString:String = entity.properties["rendermode"];
			if (renderModeString == null)
				renderMode = Bsp.RENDER_MODE_NORMAL;
			else
				renderMode = parseInt(renderModeString);
			
			// push matrix and translate to model origin
			//var oldModelviewMatrix = new J3DIMatrix4(modelviewMatrix);
			//modelviewMatrix.translate(model.origin.x, model.origin.y, model.origin.z);
			//modelviewMatrix.setUniform(gl, modelviewMatrixLocation, false);
			
			switch (renderMode)
			{
				case Bsp.RENDER_MODE_NORMAL: 
					break;
				case Bsp.RENDER_MODE_TEXTURE: 
					//gl.uniform1f(alphaLocation, alpha / 255.0);
					//gl.enable(gl.BLEND);
					//gl.blendFunc(gl.SRC_ALPHA, gl.ONE);
					//gl.depthMask(false); // make z buffer readonly
					
					break;
				case Bsp.RENDER_MODE_SOLID: 
					//gl.uniform1i(alphaTestLocation, 1);
					break;
				case Bsp.RENDER_MODE_ADDITIVE: 
					//gl.uniform1f(alphaLocation, alpha / 255.0);
					//gl.enable(gl.BLEND);
					//gl.blendFunc(gl.ONE, gl.ONE);
					//gl.depthMask(false); // make z buffer readonly
					
					break;
			}
			
			this.renderNode(model.headNodes[0], -1, cameraPos);
			
			switch (renderMode)
			{
				case Bsp.RENDER_MODE_NORMAL: 
					break;
				case Bsp.RENDER_MODE_TEXTURE: 
				case Bsp.RENDER_MODE_ADDITIVE: 
					//gl.uniform1f(alphaLocation, 1.0);
					//gl.disable(gl.BLEND);
					//gl.depthMask(true);
					
					break;
				case Bsp.RENDER_MODE_SOLID: 
					//gl.uniform1i(alphaTestLocation, 0);
					break;
			}
		
			// pop matrix
			//modelviewMatrix = oldModelviewMatrix;
			//modelviewMatrix.setUniform(gl, modelviewMatrixLocation, false);
		}
		
		/**
		 * Renders a node of the bsp tree. Called by Bsp.render().
		 *
		 * @param nodeIndex The index of the node to render.
		 * @param cameraLeaf The leaf the camera is in. Used for PVS.
		 * @param cameraPos The position of the camera.
		 */
		public function renderNode(nodeIndex:int, cameraLeaf:int, cameraPos:Vector3D):void
		{
			if (nodeIndex < 0)
			{
				if (nodeIndex == -1) // Solid leaf 0
					return;
				
				// perform vis check
				if (cameraLeaf > 0)
					if (bsp.header.lumps[Bsp.LUMP_VISIBILITY].length != 0 && bsp.visLists[cameraLeaf - 1] != null && !bsp.visLists[cameraLeaf - 1][~nodeIndex - 1])
						return;
				
				this.renderLeaf(~nodeIndex);
				
				return;
			}
			
			var distance:Number;
			
			var node:BspNode = bsp.nodes[nodeIndex];
			var plane:BspPlane = bsp.planes[node.plane];
			
			switch (plane.type)
			{
				case Bsp.PLANE_X: 
					distance = cameraPos.x - plane.dist;
					break;
				case Bsp.PLANE_Y: 
					distance = cameraPos.y - plane.dist;
					break;
				case Bsp.PLANE_Z: 
					distance = cameraPos.z - plane.dist;
					break;
				default: 
					distance = plane.normal.dotProduct(cameraPos) - plane.dist;
			}
			
			if (distance > 0.0)
			{
				this.renderNode(node.children[1], cameraLeaf, cameraPos);
				this.renderNode(node.children[0], cameraLeaf, cameraPos);
			}
			else
			{
				this.renderNode(node.children[0], cameraLeaf, cameraPos);
				this.renderNode(node.children[1], cameraLeaf, cameraPos);
			}
		}
		
		/**
		 * Renders a leaf of the bsp tree. Called by Bsp.renderNode().
		 *
		 * @param leafIndex The index of the leaf to render.
		 */
		public function renderLeaf(leafIndex:int):void
		{
			var leaf:BspLeaf = bsp.leaves[leafIndex];
			
			// Loop through each face in this leaf
			for (var i:int = 0; i < leaf.markSurfaces; i++)
				this.renderFace(bsp.markSurfaces[leaf.firstMarkSurface + i]);
		}
		
		/**
		 * Renders a face of the bsp tree. Called by Bsp.renderLeaf().
		 *
		 * @param faceIndex The index of the face to render.
		 */
		public function renderFace(faceIndex:int):void
		{
			var face:BspFace = bsp.faces[faceIndex];
			var texInfo:BspTextureInfo = bsp.textureInfos[face.textureInfo];
			
			if (face.styles[0] == 0xFF)
				return; // Skip sky faces
			
			// if the light map offset is not -1 and the lightmap lump is not empty, there are lightmaps
			var lightmapAvailable:Boolean = face.lightmapOffset != -1 && bsp.header.lumps[Bsp.LUMP_LIGHTING].length > 0;
			//gl.activeTexture(gl.TEXTURE1);
			//gl.bindTexture(gl.TEXTURE_2D, this.lightmapLookup[faceIndex]);
			var bmd:BitmapData= bsp.textureLookup[texInfo.mipTexture];
			var lbmd:BitmapData = min2maxLightmap[faceIndex];//bsp.lightmapLookup[faceIndex];
			target.drawable.index = indexs[faceIndex];
			var texture:TextureSet = bmd2texture[bmd];
			var ltexture:TextureSet = bmd2texture[lbmd];
			if (texture==null) {
				texture=bmd2texture[bmd]=new TextureSet(bmd);
			}
			if (ltexture==null) {
				ltexture=bmd2texture[lbmd]=new TextureSet(lbmd);
			}
			target.material.diffTexture = texture;
			target.material.lightmapTexture = ltexture;
			target.matrix = bspRenderNode.world;
			target.material.draw(target, view);
			//gl.drawArrays(polygonMode ? gl.LINE_STRIP : gl.TRIANGLE_FAN, this.faceBufferRegions[faceIndex].start, this.faceBufferRegions[faceIndex].count);
		}
	}

}