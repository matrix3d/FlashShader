/*
 * bsp.js
 * 
 * Copyright (c) 2012, Bernhard Manfred Gruber. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301  USA
 */

//'use strict';
package gl3d.hlbsp
{
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	public class Bsp {
		public var console:Console = new Console;
		
		
		//
		// Data loaded form the bsp file
		//
		public var header:BspHeader;          

		public var nodes:Array;
		public var leaves:Array;
		public var markSurfaces:Array;
		public var planes:Array;
		public var vertices:Array; // actually not needed for rendering, vertices are stored in vertexBuffer. But just in case someone needs them for e.g. picking etc.
		public var edges:Array;
		public var faces:Array;
		public var surfEdges:Array;
		//public var textureHeader;
		//public var mipTextures;
		//public var textureInfos;
		public var models:Array;
		public var clipNodes:Array;
		
		/** Array of Entity objects. @see Entity */
		public var entities:Array;
		
		/** References to the entities that are brush entities. Array of Entity references. */
		public var brushEntities:Array;
		
		//
		// Calculated
		//
		
		/** Stores the missing wads for this bsp file */
		//public var missingWads;

		/** Array (for each face) of arrays (for each vertex of a face) of JSONs holding s and t coordinate. */
		public var textureCoordinates:Array;
		//public var lightmapCoordinates;
		
		/**
		 * Contains a plan white 1x1 texture to be used, when a texture could not be loaded yet.
		 */
		//public var whiteTexture;
		
		/** 
		 * Stores the texture IDs of the textures for each face.
		 * Most of them will be dummy textures until they are later loaded from the Wad files.
		 */
		//public var textureLookup;
		
		/** Stores the texture IDs of the lightmaps for each face */
		//public var lightmapLookup;
		
		/** Stores a list of missing textures */
		//public var missingTextures;
		
		/** An array (for each leaf) of arrays (for each leaf) of booleans. */
		public var visLists:Array;
		
		//
		// Buffers
		//
		/*var vertexBuffer;
		var texCoordBuffer;
		var lightmapCoordBuffer;
		var normalBuffer;*/
		
		/** Holds start index and count of indexes into the buffers for each face. Array of JSONs { start, count } */
		//var faceBufferRegions;
		
		/** If set to true, all resources are ready to render */
		public var loaded:Boolean = false;
		
		/**
		 * BSP class.
		 * Responsible for loading, storing and rendering the bsp tree.
		 */
		public function Bsp()
		{
			
		}

		/**
		 * Returns the leaf that contains the given position
		 *
		 * @param pos A Vector3D describing the position to search for.
		 * @return Returns the leaf index where the position is found or -1 otherwise.
		 */
		/*public function traverseTree(pos, nodeIndex)
		{
			if(nodeIndex == undefined)
				nodeIndex = 0;
				
			var node = this.nodes[nodeIndex];
				
			// Run once for each child
			for (var i = 0; i < 2; i++)
			{
				// If the index is positive  it is an index into the nodes array
				if ((node.children[i]) >= 0)
				{
					if(pointInBox(pos, this.nodes[node.children[i]].mins, this.nodes[node.children[i]].maxs))
						return this.traverseTree(pos, node.children[i]);
				}
				// Else, bitwise inversed, it is an index into the leaf array
				// Do not test solid leaf 0
				else if (~this.nodes[nodeIndex].children[i] != 0)
				{
					if(pointInBox(pos, this.leaves[~(node.children[i])].mins, this.leaves[~(node.children[i])].maxs))
						return ~(node.children[i]);
				}
			}

			return -1;
		}*/

		/**
		 * Renders the complete level.
		 */
		/*public function render(cameraPos)
		{
			// enable/disable the required attribute arrays
			gl.enableVertexAttribArray(texCoordLocation);  	
			gl.enableVertexAttribArray(lightmapCoordLocation);  
			gl.enableVertexAttribArray(normalLocation); 
			gl.disableVertexAttribArray(colorLocation);
			
			// Bind the vertex buffer
			gl.bindBuffer(gl.ARRAY_BUFFER, this.vertexBuffer);  
			gl.vertexAttribPointer(positionLocation, 3, gl.FLOAT, false, 0, 0);
			
			// Bind texture coordinate buffer
			gl.bindBuffer(gl.ARRAY_BUFFER, this.texCoordBuffer);
			gl.vertexAttribPointer(texCoordLocation, 2, gl.FLOAT, false, 0, 0);
			
			// Bind lightmap coordinate buffer
			gl.bindBuffer(gl.ARRAY_BUFFER, this.lightmapCoordBuffer);
			gl.vertexAttribPointer(lightmapCoordLocation, 2, gl.FLOAT, false, 0, 0);
			
			// Bind normal coordinate buffer
			gl.bindBuffer(gl.ARRAY_BUFFER, this.normalBuffer);
			gl.vertexAttribPointer(normalLocation, 3, gl.FLOAT, false, 0, 0);
			
			// Get the leaf where the camera is in
			var cameraLeaf = this.traverseTree(cameraPos);
			//console.log("Camera in leaf " + cameraLeaf);
			
			// Start the render traversal on the static geometry
			this.renderNode(0, cameraLeaf, cameraPos);
			
			// Now render all the entities
			for (var i = 0; i < this.brushEntities.length; i++)
				this.renderBrushEntity(this.brushEntities[i], cameraPos);
		}*/

		/**
		 * Renders the given brush entity.
		 *
		 * @param entity An instance of Entity which is a brush entity (it must have a property "model").
		 * @param cameraPos The current camera position.
		 */
		/*public function renderBrushEntity(entity, cameraPos)
		{
			// Model
			var modelIndex = parseInt(entity.properties["model"].substring(1));
			var model = this.models[modelIndex];

			// Alpha value
			var alpha;
			var renderamt = entity.properties["renderamt"];
			if(renderamt == undefined)
				alpha = 255;
			else
				alpha = parseInt(renderamt);

			// Rendermode
			var renderMode;
			var renderModeString = entity.properties["rendermode"];
			if(renderModeString == undefined)
				renderMode = RENDER_MODE_NORMAL;
			else
				renderMode = parseInt(renderModeString);

			// push matrix and translate to model origin
			var oldModelviewMatrix = new J3DIMatrix4(modelviewMatrix);
			modelviewMatrix.translate(model.origin.x, model.origin.y, model.origin.z);
			modelviewMatrix.setUniform(gl, modelviewMatrixLocation, false);

			switch (renderMode)
			{
				case RENDER_MODE_NORMAL:
					break;
				case RENDER_MODE_TEXTURE:
					gl.uniform1f(alphaLocation, alpha / 255.0);
					gl.enable(gl.BLEND);
					gl.blendFunc(gl.SRC_ALPHA, gl.ONE);
					gl.depthMask(false); // make z buffer readonly

					break;
				case RENDER_MODE_SOLID:
					gl.uniform1i(alphaTestLocation, 1);
					break;
				case RENDER_MODE_ADDITIVE:
					gl.uniform1f(alphaLocation, alpha / 255.0);
					gl.enable(gl.BLEND);
					gl.blendFunc(gl.ONE, gl.ONE);
					gl.depthMask(false); // make z buffer readonly

					break;
			}

			this.renderNode(model.headNodes[0], -1, cameraPos);

			switch (renderMode)
			{
				case RENDER_MODE_NORMAL:
					break;
				case RENDER_MODE_TEXTURE:
				case RENDER_MODE_ADDITIVE:
					gl.uniform1f(alphaLocation, 1.0);
					gl.disable(gl.BLEND);
					gl.depthMask(true);

					break;
				case RENDER_MODE_SOLID:
					gl.uniform1i(alphaTestLocation, 0);
					break;
			}

			// pop matrix
			modelviewMatrix = oldModelviewMatrix;
			modelviewMatrix.setUniform(gl, modelviewMatrixLocation, false);
		}*/

		/**
		 * Renders a node of the bsp tree. Called by Bsp.render().
		 *
		 * @param nodeIndex The index of the node to render.
		 * @param cameraLeaf The leaf the camera is in. Used for PVS.
		 * @param cameraPos The position of the camera.
		 */
		/*public function renderNode(nodeIndex, cameraLeaf, cameraPos)
		{
			if (nodeIndex < 0)
			{
				if (nodeIndex == -1) // Solid leaf 0
					return;

				// perform vis check
				if (cameraLeaf > 0)
					if (this.header.lumps[LUMP_VISIBILITY].length != 0 &&
						this.visLists[cameraLeaf - 1] != null &&
						!this.visLists[cameraLeaf - 1][~nodeIndex - 1])
						return;

				this.renderLeaf(~nodeIndex);

				return;
			}

			var distance;
			
			var node = this.nodes[nodeIndex];
			var plane = this.planes[node.plane];

			switch (plane.type)
			{
			case PLANE_X:
				distance = cameraPos.x - plane.dist;
				break;
			case PLANE_Y:
				distance = cameraPos.y - plane.dist;
				break;
			case PLANE_Z:
				distance = cameraPos.z - plane.dist;
				break;
			default:
				distance = dotProduct(plane.normal, cameraPos) - plane.dist;
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
		}*/

		/**
		 * Renders a leaf of the bsp tree. Called by Bsp.renderNode().
		 *
		 * @param leafIndex The index of the leaf to render.
		 */
		/*Bsp.prototype.renderLeaf = function(leafIndex)
		{
			var leaf = this.leaves[leafIndex];
			
			// Loop through each face in this leaf
			for (var i = 0; i < leaf.markSurfaces; i++)
				this.renderFace(this.markSurfaces[leaf.firstMarkSurface + i]);
		}*/

		/**
		 * Renders a face of the bsp tree. Called by Bsp.renderLeaf().
		 *
		 * @param faceIndex The index of the face to render.
		 */
		/*public function renderFace(faceIndex)
		{
			var face = this.faces[faceIndex];
			var texInfo = this.textureInfos[face.textureInfo];
			
			if (face.styles[0] == 0xFF)
				return; // Skip sky faces

			// if the light map offset is not -1 and the lightmap lump is not empty, there are lightmaps
			var lightmapAvailable = face.lightmapOffset != -1 && this.header.lumps[LUMP_LIGHTING].length > 0;
			
			gl.activeTexture(gl.TEXTURE0);
			gl.bindTexture(gl.TEXTURE_2D, this.textureLookup[texInfo.mipTexture]);
			
			gl.activeTexture(gl.TEXTURE1);
			gl.bindTexture(gl.TEXTURE_2D, this.lightmapLookup[faceIndex]);


			gl.drawArrays(polygonMode ? gl.LINE_STRIP : gl.TRIANGLE_FAN, this.faceBufferRegions[faceIndex].start, this.faceBufferRegions[faceIndex].count);
		}*/

		/**
		 * Loades the complete level and prepares it for rendering
		 */
		public function loadBSP(arrayBuffer:ByteArray):Boolean
		{
			console.log('Begin loading bsp');
			arrayBuffer.endian = Endian.LITTLE_ENDIAN;
			this.loaded = false;
			
			var src:ByteArray = arrayBuffer;
			
			if(!this.readHeader(src))
				return false;
				
			this.readNodes(src);
			this.readLeaves(src);
			this.readMarkSurfaces(src);
			this.readPlanes(src);
			this.readVertices(src);
			this.readEdges(src);
			this.readFaces(src);
			this.readSurfEdges(src);
			//this.readMipTextures(src);
			//this.readTextureInfos(src);
			this.readModels(src);
			this.readClipNodes(src);
			
			this.loadEntities(src);   // muast be loaded before textures
			//this.loadTextures(src);   // plus coordinates
			//this.loadLightmaps(src);  // plus coordinates
			//this.loadVIS(src);
			
			// FINALLY create buffers for rendering
			//this.preRender();
			
			console.log('Finished loading BSP');
			this.loaded = true;
			
			return true;
		}

		public function readHeader(src:ByteArray):Boolean
		{
			this.header = new BspHeader();
			
			this.header.version = src.readInt();
			
			if(this.header.version != 30)
			{
				console.log('Invalid bsp version: ' + this.header.version + ' Only bsp v30 is supported');
				return false;
			}
			
			this.header.lumps = new Array();
			for(var i:int = 0; i < HEADER_LUMPS; i++)
			{
				var lump:BspLump = new BspLump();
				
				lump.offset = src.readInt();
				lump.length = src.readInt();
				
				this.header.lumps.push(lump);
			}
			
			console.log('Read ' + this.header.lumps.length + ' lumps');
			
			return true;
		}

		public function readNodes(src:ByteArray):void
		{
			src.position=this.header.lumps[LUMP_NODES].offset;
			
			this.nodes = new Array();

			for(var i:int = 0; i < this.header.lumps[LUMP_NODES].length / SIZE_OF_BSPNODE; i++)
			{
				var node:BspNode = new BspNode();
				
				node.plane = src.readUnsignedInt();
				
				node.children = new Array();
				node.children.push(src.readShort());
				node.children.push(src.readShort());
				
				node.mins = new Array();
				node.mins.push(src.readShort());
				node.mins.push(src.readShort());
				node.mins.push(src.readShort());
				
				node.maxs = new Array();
				node.maxs.push(src.readShort());
				node.maxs.push(src.readShort());
				node.maxs.push(src.readShort());
				
				node.firstFace = src.readUnsignedShort();
				node.faces = src.readUnsignedShort();
				
				this.nodes.push(node);
			}
			
			console.log('Read ' + this.nodes.length + ' Nodes');
		}

		public function readLeaves(src:ByteArray):void
		{
			src.position=(this.header.lumps[LUMP_LEAVES].offset);
			
			this.leaves = new Array();

			for(var i:int = 0; i < this.header.lumps[LUMP_LEAVES].length / SIZE_OF_BSPLEAF; i++)
			{
				var leaf:BspLeaf = new BspLeaf();
				
				leaf.content = src.readInt();
				
				leaf.visOffset = src.readInt();
				
				leaf.mins = new Array();
				leaf.mins.push(src.readShort());
				leaf.mins.push(src.readShort());
				leaf.mins.push(src.readShort());
				
				leaf.maxs = new Array();
				leaf.maxs.push(src.readShort());
				leaf.maxs.push(src.readShort());
				leaf.maxs.push(src.readShort());
				
				leaf.firstMarkSurface = src.readUnsignedShort();
				
				leaf.markSurfaces = src.readUnsignedShort();
				
				leaf.ambientLevels = new Array();
				leaf.ambientLevels.push(src.readUnsignedByte());
				leaf.ambientLevels.push(src.readUnsignedByte());
				leaf.ambientLevels.push(src.readUnsignedByte());
				leaf.ambientLevels.push(src.readUnsignedByte());
				
				this.leaves.push(leaf);
			}
			
			console.log('Read ' + this.leaves.length + ' Leaves');
		}

		public function readMarkSurfaces(src:ByteArray):void
		{
			src.position=(this.header.lumps[LUMP_MARKSURFACES].offset);
			
			this.markSurfaces = new Array();

			for(var i:int = 0; i < this.header.lumps[LUMP_MARKSURFACES].length / SIZE_OF_BSPMARKSURFACE; i++)
				this.markSurfaces.push(src.readUnsignedShort());
			
			console.log('Read ' + this.markSurfaces.length + ' MarkSurfaces');
		}

		public function readPlanes(src:ByteArray):void
		{
			src.position=(this.header.lumps[LUMP_PLANES].offset);
			
			this.planes = new Array();
			
			for(var i:int = 0; i < this.header.lumps[LUMP_PLANES].length / SIZE_OF_BSPPLANE; i++)
			{
				var plane:BspPlane = new BspPlane();
				
				plane.normal = new Vector3D();
				plane.normal.x = src.readFloat();
				plane.normal.y = src.readFloat();
				plane.normal.z = src.readFloat();
				
				plane.dist = src.readFloat();
				
				plane.type = src.readInt();
				
				this.planes.push(plane);
			}
			
			console.log('Read ' + this.planes.length + ' Planes');
		}

		public function readVertices(src:ByteArray):void
		{
			src.position=(this.header.lumps[LUMP_VERTICES].offset);
			
			this.vertices = new Array();
			
			for(var i:int = 0; i < this.header.lumps[LUMP_VERTICES].length / SIZE_OF_BSPVERTEX; i++)
			{
				var vertex:Vector3D = new Vector3D();
				
				vertex.x = src.readFloat();
				vertex.y = src.readFloat();
				vertex.z = src.readFloat();
				
				this.vertices.push(vertex);
			}
			
			console.log('Read ' + this.vertices.length + ' Vertices');
		}

		public function readEdges(src:ByteArray):void
		{
			src.position=(this.header.lumps[LUMP_EDGES].offset);
			
			this.edges = new Array();
			
			for(var i:int = 0; i < this.header.lumps[LUMP_EDGES].length / SIZE_OF_BSPEDGE; i++)
			{
				var edge:BspEdge = new BspEdge();
				
				edge.vertices = new Array();
				edge.vertices.push(src.readUnsignedShort());
				edge.vertices.push(src.readUnsignedShort());
				
				this.edges.push(edge);
			}
			
			console.log('Read ' + this.edges.length + ' Edges');
		}

		public function readFaces(src:ByteArray):void
		{
			src.position=(this.header.lumps[LUMP_FACES].offset);
			
			this.faces = new Array();
			
			for(var i:int = 0; i < this.header.lumps[LUMP_FACES].length / SIZE_OF_BSPFACE; i++)
			{
				var face:BspFace = new BspFace();
				
				face.plane = src.readUnsignedShort();
				
				face.planeSide = src.readUnsignedShort();
				
				face.firstEdge = src.readUnsignedInt();
				
				face.edges = src.readUnsignedShort();
				
				face.textureInfo = src.readUnsignedShort();
				
				face.styles = new Array();
				face.styles.push(src.readUnsignedByte());
				face.styles.push(src.readUnsignedByte());
				face.styles.push(src.readUnsignedByte());
				face.styles.push(src.readUnsignedByte());
				
				face.lightmapOffset = src.readUnsignedInt();
				
				this.faces.push(face);
			}

			console.log('Read ' + this.faces.length + ' Faces');    
		}

		public function readSurfEdges(src:ByteArray):void
		{
			src.position=(this.header.lumps[LUMP_SURFEDGES].offset);
			
			this.surfEdges = new Array();

			for(var i:int = 0; i < this.header.lumps[LUMP_SURFEDGES].length / SIZE_OF_BSPSURFEDGE; i++)
			{
				this.surfEdges.push(src.readInt());
			}
			
			console.log('Read ' + this.surfEdges.length + ' SurfEdges');
		}

		/*public function readTextureHeader(src)
		{
			src.seek(this.header.lumps[LUMP_TEXTURES].offset);
			
			this.textureHeader = new BspTextureHeader();
			
			this.textureHeader.textures = src.readULong();
			
			this.textureHeader.offsets = new Array();
			for(var i = 0; i < this.textureHeader.textures; i++)
				this.textureHeader.offsets.push(src.readLong());
			
			console.log('Read TextureHeader. Bsp files references/contains ' + this.textureHeader.textures + ' textures');
		}*/

		/*public function readMipTextures(src)
		{
			this.readTextureHeader(src);
			
			this.mipTextures = new Array();
			
			for(var i = 0; i < this.textureHeader.textures; i++)
			{
				src.seek(this.header.lumps[LUMP_TEXTURES].offset + this.textureHeader.offsets[i]);
				
				var miptex = new BspMipTexture();
				
				miptex.name = src.readString(MAXTEXTURENAME);
				
				miptex.width = src.readULong();
				
				miptex.height = src.readULong();
				
				miptex.offsets = new Array();
				for(var j = 0; j < MIPLEVELS; j++)
					miptex.offsets.push(src.readULong());
				
				this.mipTextures.push(miptex);
			}
		}*/

		/*public function readTextureInfos(src)
		{
			src.seek(this.header.lumps[LUMP_TEXINFO].offset);
			
			this.textureInfos = new Array();
			
			for(var i = 0; i < this.header.lumps[LUMP_TEXINFO].length / SIZE_OF_BSPTEXTUREINFO; i++)
			{
				var texInfo = new BspTextureInfo();
				
				texInfo.s = new Vector3D();
				texInfo.s.x = src.readFloat();
				texInfo.s.y = src.readFloat();
				texInfo.s.z = src.readFloat();
				
				texInfo.sShift = src.readFloat();
				
				texInfo.t = new Vector3D();
				texInfo.t.x = src.readFloat();
				texInfo.t.y = src.readFloat();
				texInfo.t.z = src.readFloat();
				
				texInfo.tShift = src.readFloat();
				
				texInfo.mipTexture = src.readULong();
				
				texInfo.flags = src.readULong();
				
				this.textureInfos.push(texInfo);
			}
			
			console.log('Read ' + this.textureInfos.length + ' TextureInfos');
		}*/

		public function readModels(src:ByteArray):void
		{
			src.position=(this.header.lumps[LUMP_MODELS].offset);
			
			this.models = new Array();

			for(var i:int = 0; i < this.header.lumps[LUMP_MODELS].length / SIZE_OF_BSPMODEL; i++)
			{
				var model:BspModel = new BspModel();
				
				model.mins = new Array();
				model.mins.push(src.readFloat());
				model.mins.push(src.readFloat());
				model.mins.push(src.readFloat());
				
				model.maxs = new Array();
				model.maxs.push(src.readFloat());
				model.maxs.push(src.readFloat());
				model.maxs.push(src.readFloat());
				
				model.origin = new Vector3D();
				model.origin.x = src.readFloat();
				model.origin.y = src.readFloat();
				model.origin.z = src.readFloat();
				
				model.headNodes = new Array();
				for(var j:int = 0; j < MAX_MAP_HULLS; j++)
					model.headNodes.push(src.readInt());
					
				model.visLeafs = src.readInt();
				
				model.firstFace = src.readInt();
				
				model.faces = src.readInt();
				
				this.models.push(model);
			}
			
			console.log('Read ' + this.models.length + ' Models');
		}

		public function readClipNodes(src:ByteArray):void
		{
			src.position=(this.header.lumps[LUMP_CLIPNODES].offset);
			
			this.clipNodes = new Array();

			for(var i:int = 0; i < this.header.lumps[LUMP_CLIPNODES].length / SIZE_OF_BSPCLIPNODE; i++)
			{
				var clipNode:BspClipNode = new BspClipNode();
				
				clipNode.plane = src.readInt();
				
				clipNode.children = new Array();
				clipNode.children.push(src.readShort());
				clipNode.children.push(src.readShort());
				
				this.clipNodes.push(clipNode);
			}
			
			console.log('Read ' + this.clipNodes.length + ' ClipNodes');
		}

		/**
		 * Returns true if the given entity is a brush entity (an entity, that can be rendered directly as small bsp tree).
		 */
		public function isBrushEntity(entity:Entity):Boolean
		{
			if (entity.properties.model == undefined)
				return false;
				
			if(entity.properties.model.substring(0, 1) != '*')
				return false; // external model

			/*var className = entity.classname;
			if (className == "func_door_rotating" ||
				className == "func_door" ||
				className == "func_illusionary" ||
				className == "func_wall" ||
				className == "func_breakable" ||
				className == "func_button")
				return true;
			else
				return false;
				
			return true;*/
			return true;
		}

		/**
		 * Loads and parses the entities from the entity lump.
		 */
		public function loadEntities(src:ByteArray):void
		{
			src.position=(this.header.lumps[LUMP_ENTITIES].offset);
			
			var entityData:String = src.readUTFBytes(this.header.lumps[LUMP_ENTITIES].length);
			
			this.entities = new Array();
			this.brushEntities = new Array();
			
			var end:int = -1;
			while(true)
			{
				var begin:int = entityData.indexOf('{', end + 1);
				if(begin == -1)
					break;
				
				end = entityData.indexOf('}', begin + 1);
				
				var entityString:String = entityData.substring(begin + 1, end);
				
				var entity:Entity = new Entity(entityString);
				
				if(this.isBrushEntity(entity))
					this.brushEntities.push(entity);
				
				this.entities.push(entity);
			}
			
			console.log('Read ' + this.entities.length + ' Entities (' + this.brushEntities.length + ' Brush Entities)');
		}

		/**
		 * Finds all entities that match the given classname.
		 *
		 * @param name The value of the classname property.
		 * @return Returns an array of Entity references to the found entities.
		 */
		public function findEntities(name:String):Array
		{
			var matches:Array = new Array();
			for(var i:int = 0; i < this.entities.length; i++)
			{
				var entity:Entity = this.entities[i];

				if(entity.properties.classname == name)
					matches.push(entity);
			}
			
			return matches;
		}

		/**
		 * Loads and decompresses the PVS (Potentially Visible Set, or VIS for short) from the bsp file.
		 */
		/*public function loadVIS(src)
		{
			if(this.header.lumps[LUMP_VISIBILITY].length > 0)
			{
				var visLeaves = this.countVisLeaves(0);
				
				this.visLists = new Array(visLeaves);
				
				for (var i = 0; i < visLeaves; i++)
				{
					if (this.leaves[i + 1].visOffset >= 0)
						this.visLists[i] = this.getPVS(src, i + 1, visLeaves);
					else
						this.visLists[i] = null;
				}
			}
			else
				console.log("No VIS found\n");
		}*/

		/**
		 * Counts the number of so-called VisLeaves (leafs that have VIS/PVS information) in the bsp file.
		 */
		public function countVisLeaves(nodeIndex:int):int
		{
			if (nodeIndex < 0)
			{
				// leaf 0
				if(nodeIndex == -1)
					return 0;

				if(this.leaves[~nodeIndex].contents == CONTENTS_SOLID)
					return 0;

				return 1;
			}
			
			var node:BspNode = this.nodes[nodeIndex];

			return this.countVisLeaves(node.children[0]) + this.countVisLeaves(node.children[1]);
		}

		/**
		 * Retrieves the PVS for the given leaf.
		 *
		 * @param src Reference to an instance of BinaryFile representing the bsp file to read from.
		 * @param leafIndex Index of the leaf to retrieve the PVS for.
		 * @param visLeaves The number of VisLeaves as returned by Bsp.countVisLeaves().
		 * @return Returns an array of boolean values representing the visibility list for the given leaf.
		 */
		/*public function getPVS(src, leafIndex, visLeaves)
		{
			var list = new Array(this.leaves.length - 1);
			
			for(var i = 0; i < list.length; i++)
				list[i] = false;

			var compressed = new Uint8Array(src.buffer, this.header.lumps[LUMP_VISIBILITY].offset + this.leaves[leafIndex].visOffset);

			var writeIndex = 0; // Index that moves through the destination bool array (list)

			for (var curByte = 0; writeIndex < visLeaves; curByte++)
			{
				// Check for a run of 0s
				if (compressed[curByte] == 0)
				{
					// Advance past this run of 0s
					curByte++;
					// Move the write pointer the number of compressed 0s
					writeIndex += 8 * compressed[curByte];
				}
				else
				{
					// Iterate through this byte with bit shifting till the bit has moved beyond the 8th digit
					for (var mask = 0x01; mask != 0x0100; writeIndex++, mask <<= 1)
					{
						// Test a bit of the compressed PVS with the bit mask
						if ((compressed[curByte] & mask) && (writeIndex  < visLeaves))
							list[writeIndex] = true;
					}
				}
			}

			//console.log("List for leaf " + leafIndex + ": " + list);
			
			return list;
		}*/

		/**
		 * Tries to load the texture identified by name from the loaded wad files.
		 *
		 * @return Returns the texture identifier if the texture has been found, otherwise null.
		 */
		/*public function loadTextureFromWad(name)
		{
			var texture = null;
			for(var k = 0; k < loadedWads.length; k++)
			{
				texture = loadedWads[k].loadTexture(name);
				if(texture != null)
					break;
			}
			
			return texture;
		}*/

		/**
		 * Loads all the texture data from the bsp file and generates texture coordinates.
		 */
		/*public function loadTextures(src)
		{
			this.textureCoordinates = new Array();
			
			//
			// Texture coordinates
			//
			
			for (var i = 0; i < this.faces.length; i++)
			{
				var face = this.faces[i];
				var texInfo = this.textureInfos[face.textureInfo];
				
				var faceCoords = new Array();

				for (var j = 0; j < face.edges; j++)
				{
					var edgeIndex = this.surfEdges[face.firstEdge + j];

					var vertexIndex;
					if (edgeIndex > 0)
					{
						var edge = this.edges[edgeIndex];
						vertexIndex = edge.vertices[0];
					}
					else
					{
						edgeIndex *= -1;
						var edge = this.edges[edgeIndex];
						vertexIndex = edge.vertices[1];
					}
					
					var vertex = this.vertices[vertexIndex];
					var mipTexture = this.mipTextures[texInfo.mipTexture];
					
					var coord = {
						s : (dotProduct(vertex, texInfo.s) + texInfo.sShift) / mipTexture.width,
						t : (dotProduct(vertex, texInfo.t) + texInfo.tShift) / mipTexture.height
					};
					
					faceCoords.push(coord);
				}
				
				this.textureCoordinates.push(faceCoords);
			}
			
			//
			// Texture images
			//
			
			// Create white texture
			this.whiteTexture =  pixelsToTexture(new Array(255, 255, 255), 1, 1, 3, function(texture, image)
			{
				gl.bindTexture(gl.TEXTURE_2D, texture);
				gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
				gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR_MIPMAP_LINEAR);
				gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
				gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
				gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGB, gl.RGB, gl.UNSIGNED_BYTE, image);
				gl.generateMipmap(gl.TEXTURE_2D);
				gl.bindTexture(gl.TEXTURE_2D, null);
			});

			
			this.textureLookup = new Array(this.faces.length);
			this.missingTextures = new Array();
			
			for(var i = 0; i < this.mipTextures.length; i++)
			{
				var mipTexture = this.mipTextures[i];
				
				if(mipTexture.offsets[0] == 0)
				{
					//
					// External texture
					//
				
					// search texture in loaded wads
					var texture = this.loadTextureFromWad(mipTexture.name);
					
					if(texture != null)
					{
						// the texture has been found in a loaded wad
						this.textureLookup[i] = texture;
						
						console.log("Texture " + mipTexture.name + " found");
					}
					else
					{
						// bind simple white texture to do not disturb lightmaps
						this.textureLookup[i] = this.whiteTexture;
					
						// store the name and position of this missing texture,
						// so that it can later be loaded to the right position by calling loadMissingTextures()
						this.missingTextures.push({ name: mipTexture.name, index: i });
						
						console.log("Texture " + mipTexture.name + " is missing");
					}
					
					continue; 
				}
				else
				{
					//
					// Load internal texture if present
					//
					
					// Calculate offset of the texture in the bsp file
					var offset = this.header.lumps[LUMP_TEXTURES].offset + this.textureHeader.offsets[i];
					
					// Use the texture loading procedure from the Wad class
					this.textureLookup[i] = Wad.prototype.fetchTextureAtOffset(src, offset);
					
					console.log("Fetched interal texture " + mipTexture.name);
				}
			}
			
			// Now that all dummy texture unit IDs have been created, alert the user to select wads for them
			this.showMissingWads();
		}*/

		/**
		 * Tries to load all missing textures from the currently loaded Wad files.
		 */
		/*public function loadMissingTextures()
		{
			for(var i = 0; i < this.missingTextures.length; i++)
			{
				var missingTexture = this.missingTextures[i];
				var texture = this.loadTextureFromWad(missingTexture.name);
				
				if(texture != null)
				{
					// the texture has finally be found, insert its ID
					this.textureLookup[missingTexture.index] = texture;
					
					console.log("Texture " + missingTexture.name + " found (delayed)");
					
					// and remove the entry
					this.missingTextures.splice(i, 1);
					i--;
				}
				else
					console.log("Texture " + missingTexture.name + " is still missing");
			}
		}*/

		/**
		 * Updates the gui by the wad files needed by the bsp file but currently not loaded.
		 */
		//public function showMissingWads()
		//{
			//this.missingWads = new Array();
			//
			//var worldspawn = this.findEntities('worldspawn')[0];
			//var wadString = worldspawn.properties['wad'];
			//var wads = wadString.split(';');
			//
			//for(var i = 0; i < wads.length; i++)
			//{
				//var wad = wads[i];
				//if(wad == '')
					//continue;
				//
				//// shorten path
				//var pos = wad.lastIndexOf('\\');
				//var file = wad.substring(pos + 1);
				////var dir = wad.substring(wad.lastIndexOf('\\', pos - 1) + 1, pos);
				//
				//// store the missing wad file
				////this.missingWads.push({ name: file, dir: dir });
				//var found = false;
				//for(var j = 0; j < loadedWads.length; j++)
					//if(loadedWads[j].name == file)
						//found = true;
				//
				//if(!found) // the wad file hasn't already been added loaded
					//this.missingWads.push(file);
			//}
			//
			//if(this.missingWads.length == 0)
				//return;
			//
			//$('#wadmissing p:first-child').html('The bsp file references the following missing Wad files:');
			//
			//for(var i = 0; i < this.missingWads.length; i++)
			//{
				//var name = this.missingWads[i];
				////var dir = this.missingWads[i].dir;
			//
				////if(dir == 'cstrike' || dir == 'valve')
				////	caption += ' (' + dir + ')';
				//
				////$('#wadmissing ul').append('<li><span data-name="' + name + '" data-dir="' + dir + '" class="error">' + caption + '</span></li>');
				//$('#wadmissing ul').append('<li data-name="' + name + '"><span class="error">' + name + '</span></li>');
			//}
			//
			//setTimeout($('#wadmissing').slideDown(300), 0);
		//}*/

		/**
		 * Loads all the lightmaps from bsp file, generates textures and texture coordinates.
		 */
		///*public function loadLightmaps(src)
		//{
			//this.lightmapCoordinates = new Array();
			//this.lightmapLookup = new Array(this.faces.length);
			//
			//var loadedData = 0;
			//var loadedLightmaps = 0;
//
			//for (var i = 0; i < this.faces.length; i++)
			//{
				//var face = this.faces[i];
				//
				//var faceCoords = new Array();
			//
				//if (face.styles[0] != 0 || face.lightmapOffset == -1)
				//{
					//this.lightmapLookup[i] = 0;
					//
					//// create dummy lightmap coords
					//for (var j = 0; j < face.edges; j++)
						//faceCoords.push({ s: 0, t : 0});
					//this.lightmapCoordinates.push(faceCoords);
					//
					//continue;
				//}
//
				///* *********** QRAD ********** */
//
				//var minU = 999999.0;
				//var minV = 999999.0;
				//var maxU = -99999.0;
				//var maxV = -99999.0;
//
				//var texInfo = this.textureInfos[face.textureInfo];
				//
				//for (var j = 0; j < face.edges; j++)
				//{
					//var edgeIndex = this.surfEdges[face.firstEdge + j];
					//var vertex;
					//if (edgeIndex >= 0)
						//vertex = this.vertices[this.edges[edgeIndex].vertices[0]];
					//else
						//vertex = this.vertices[this.edges[-edgeIndex].vertices[1]];
//
					//var u = Math.round(dotProduct(texInfo.s, vertex) + texInfo.sShift);
					//if (u < minU)
						//minU = u;
					//if (u > maxU)
						//maxU = u;
//
					//var v = Math.round(dotProduct(texInfo.t, vertex) + texInfo.tShift);
					//if (v < minV)
						//minV = v;
					//if (v > maxV)
						//maxV = v;
				//}
//
				//var texMinU = Math.floor(minU / 16.0);
				//var texMinV = Math.floor(minV / 16.0);
				//var texMaxU = Math.ceil(maxU / 16.0);
				//var texMaxV = Math.ceil(maxV / 16.0);
//
				//var width = Math.floor((texMaxU - texMinU) + 1);
				//var height = Math.floor((texMaxV - texMinV) + 1);
//
				///* *********** end QRAD ********* */
//
				///* ********** http://www.gamedev.net/community/forums/topic.asp?topic_id=538713 (last refresh: 20.02.2010) ********** */
//
				//var midPolyU = (minU + maxU) / 2.0;
				//var midPolyV = (minV + maxV) / 2.0;
				//var midTexU = width / 2.0;
				//var midTexV = height / 2.0;
				//
				//var coord;
//
				//for (var j = 0; j < face.edges; ++j)
				//{
					//var edgeIndex = this.surfEdges[face.firstEdge + j];
					//var vertex;
					//if (edgeIndex >= 0)
						//vertex = this.vertices[this.edges[edgeIndex].vertices[0]];
					//else
						//vertex = this.vertices[this.edges[-edgeIndex].vertices[1]];
//
					//var u = Math.round(dotProduct(texInfo.s, vertex) + texInfo.sShift);
					//var v = Math.round(dotProduct(texInfo.t, vertex) + texInfo.tShift);
//
					//var lightMapU = midTexU + (u - midPolyU) / 16.0;
					//var lightMapV = midTexV + (v - midPolyV) / 16.0;
//
					//coord = {
						//s : lightMapU / width,
						//t : lightMapV / height
					//}
					//
					//faceCoords.push(coord);
				//}
//
				///* ********** end http://www.gamedev.net/community/forums/topic.asp?topic_id=538713 ********** */
//
				//var pixels = new Uint8Array(src.buffer, this.header.lumps[LUMP_LIGHTING].offset + face.lightmapOffset, width * height * 3)
				//
				//var texture = pixelsToTexture(pixels, width, height, 3, function(texture, image)
				//{
					//gl.bindTexture(gl.TEXTURE_2D, texture);
					//gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
					//gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR_MIPMAP_LINEAR);
					//gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
					//gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
					//gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, image);
					//gl.generateMipmap(gl.TEXTURE_2D);
					//gl.bindTexture(gl.TEXTURE_2D, null);
					////$('body').append('<span>Texture (' + image.width + 'x' + image.height + ')</span>').append(image);
				//});
//
				//this.lightmapLookup[i] = texture;
				//this.lightmapCoordinates.push(faceCoords);
				//
				//loadedLightmaps++;
				//loadedData += width * height * 3;
			//}
			//
			//console.log('Loaded ' + loadedLightmaps + ' lightmaps, lightmapdatadiff: ' + (loadedData - this.header.lumps[LUMP_LIGHTING].length) + ' Bytes ');
		//}

		/**
		 * Unloads all allocated data of the Bsp class. This should be mostly OpenGL releated stuff.
		 */
		/*public function unload()
		{
			// Free lightmap lookup
			for(var i = 0; i < this.lightmapLookup.length; i++)
				gl.deleteTexture(this.lightmapLookup[i]);
				
			// Free texture lookup
			for(var i = 0; i < this.textureLookup.length; i++)
				gl.deleteTexture(this.textureLookup[i]);
				
			gl.deleteTexture(this.whiteTexture);

			gl.deleteBuffer(this.vertexBuffer);
			gl.deleteBuffer(this.texCoordBuffer);
			gl.deleteBuffer(this.lightmapCoordBuffer);
			gl.deleteBuffer(this.normalBuffer);
		}*/
		
		
		/*
		 * bspdef.js
		 * 
		 * Copyright (c) 2012, Bernhard Manfred Gruber. All rights reserved.
		 *
		 * This library is free software; you can redistribute it and/or
		 * modify it under the terms of the GNU Lesser General Public
		 * License as published by the Free Software Foundation; either
		 * version 3 of the License, or any later version.
		 *
		 * This library is distributed in the hope that it will be useful,
		 * but WITHOUT ANY WARRANTY; without even the implied warranty of
		 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
		 * Lesser General Public License for more details.
		 *
		 * You should have received a copy of the GNU Lesser General Public
		 * License along with this library; if not, write to the Free Software
		 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
		 * MA 02110-1301  USA
		 */

		'use strict';

		/**
		 * Contains the standard BSP v30 file definitions.
		 * For closer information visit my hlbsp project:
		 * http://hlbsp.sourceforge.net/index.php?content=bspdef
		 */

		public static var MAX_MAP_HULLS:int        = 4;

		public static var MAX_MAP_MODELS:int       = 400;
		public static var MAX_MAP_BRUSHES :int     = 4096;
		public static var MAX_MAP_ENTITIES :int    = 1024;
		public static var MAX_MAP_ENTSTRING :int   = (128*1024);

		public static var MAX_MAP_PLANES:int       = 32767;
		public static var MAX_MAP_NODES:int        = 32767; // because negative shorts are leaves
		public static var MAX_MAP_CLIPNODES:int    = 32767; //
		public static var MAX_MAP_LEAFS:int        = 8192;
		public static var MAX_MAP_VERTS:int        = 65535;
		public static var MAX_MAP_FACES:int        = 65535;
		public static var MAX_MAP_MARKSURFACES:int = 65535;
		public static var MAX_MAP_TEXINFO:int      = 8192;
		public static var MAX_MAP_EDGES:int        = 256000;
		public static var MAX_MAP_SURFEDGES:int    = 512000;
		public static var MAX_MAP_TEXTURES:int     = 512;
		public static var MAX_MAP_MIPTEX:int       = 0x200000;
		public static var MAX_MAP_LIGHTING:int     = 0x200000;
		public static var MAX_MAP_VISIBILITY:int   = 0x200000;

		public static var MAX_MAP_PORTALS:int      = 65536;

		public static var MAX_KEY:int              = 32;
		public static var MAX_VALUE:int            = 1024;

		// BSP-30 files contain these lumps
		public static var LUMP_ENTITIES:int     = 0;
		public static var LUMP_PLANES:int       = 1;
		public static var LUMP_TEXTURES:int     = 2;
		public static var LUMP_VERTICES:int     = 3;
		public static var LUMP_VISIBILITY:int   = 4;
		public static var LUMP_NODES:int        = 5;
		public static var LUMP_TEXINFO:int      = 6;
		public static var LUMP_FACES:int        = 7;
		public static var LUMP_LIGHTING:int     = 8;
		public static var LUMP_CLIPNODES:int    = 9;
		public static var LUMP_LEAVES:int       = 10;
		public static var LUMP_MARKSURFACES:int = 11;
		public static var LUMP_EDGES:int        = 12;
		public static var LUMP_SURFEDGES:int    = 13;
		public static var LUMP_MODELS:int       = 14;
		public static var HEADER_LUMPS:int      = 15;

		// Leaf content values
		public static var CONTENTS_EMPTY:int        = -1;
		public static var CONTENTS_SOLID:int        = -2;
		public static var CONTENTS_WATER:int        = -3;
		public static var CONTENTS_SLIME:int        = -4;
		public static var CONTENTS_LAVA :int        = -5;
		public static var CONTENTS_SKY:int          = -6;
		public static var CONTENTS_ORIGIN:int       = -7;
		public static var CONTENTS_CLIP:int         = -8;
		public static var CONTENTS_CURRENT_0:int    = -9;
		public static var CONTENTS_CURRENT_90:int   = -10;
		public static var CONTENTS_CURRENT_180:int  = -11;
		public static var CONTENTS_CURRENT_270:int  = -12;
		public static var CONTENTS_CURRENT_UP:int   = -13;
		public static var CONTENTS_CURRENT_DOWN:int = -14;
		public static var CONTENTS_TRANSLUCENT:int  = -15;

		//Plane types
		public static var PLANE_X :int   = 0; // Plane is perpendicular to given axis
		public static var PLANE_Y:int    = 1;
		public static var PLANE_Z:int    = 2;
		public static var PLANE_ANYX:int = 3; // Non-axial plane is snapped to the nearest
		public static var PLANE_ANYY:int = 4;
		public static var PLANE_ANYZ:int = 5;

		// Render modes
		public static var RENDER_MODE_NORMAL:int   = 0;
		public static var RENDER_MODE_COLOR:int    = 1;
		public static var RENDER_MODE_TEXTURE:int  = 2;
		public static var RENDER_MODE_GLOW:int     = 3;
		public static var RENDER_MODE_SOLID:int    = 4;
		public static var RENDER_MODE_ADDITIVE:int = 5;


		public static var SIZE_OF_BSPNODE:int = 24;


		public static var SIZE_OF_BSPLEAF:int = 28;

		// Leaves index into marksurfaces, which index into pFaces
		/*
		typedef uint16_t BSPMARKSURFACE;
		*/
		public static var SIZE_OF_BSPMARKSURFACE:int  = 2;


		public static var SIZE_OF_BSPPLANE:int = 20;

		public static var SIZE_OF_BSPVERTEX:int = 12;


		public static var SIZE_OF_BSPEDGE:int = 4;


		public static var SIZE_OF_BSPFACE:int = 20;


		// Surfedges lump is an array of signed int indices into the edge lump, where a negative index indicates
		// using the referenced edge in the opposite direction. Faces index into surfEdges, which index
		// into edges, which finally index into vertices.
		/*
		typedef int32_t BSPSURFEDGE;
		*/
		public static var SIZE_OF_BSPSURFEDGE:int = 4;

		// Textures lump begins with a header, followed by offsets to BSPMIPTEX structures, then BSPMIPTEX structures
		/*
		typedef struct _BSPTEXTUREHEADER
		{
			uint32_t nMipTextures;
		};
		*/
		// 32-bit offsets (within texture lump) to (nMipTextures) BSPMIPTEX structures
		/*
		typedef int32_t BSPMIPTEXOFFSET;
		*/
		public static var SIZE_OF_BSPMIPTEXOFFSET:int = 4;

		// BSPMIPTEX structures which defines a texture
		public static var MAXTEXTURENAME:int = 16
		public static var MIPLEVELS:int = 4
		/*
		typedef struct _BSPMIPTEX
		{
			char     szName[MAXTEXTURENAME]; 
			uint32_t nWidth, nHeight;        
			uint32_t nOffsets[MIPLEVELS];
		};
		*/

		// Texinfo lump contains information about how textures are applied to surfaces
		/*
		typedef struct _BSPTEXTUREINFO
		{
			VECTOR3D vS;      
			float    fSShift; 
			VECTOR3D vT;      
			float    fTShift; 
			uint32_t iMiptex; 
			uint32_t nFlags; 
		};
		*/
		public static var SIZE_OF_BSPTEXTUREINFO:int = 40;


		public static var SIZE_OF_BSPMODEL:int = 64;


		public static var SIZE_OF_BSPCLIPNODE:int = 8;
	}
}

class Console {
	public function log(...args):void {
		trace(args);
	}
}
