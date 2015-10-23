package gl3d.parser.q3bsp 
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	/**
	 * http://www.mralligator.com/q3/
	 * 
	 * Quake 3 BSP files are IBSP files, and therefore have a structure similar to previous BSP files from id Software. 
	 * Every IBSP file begins with a header, which in turn contains a lump directory. 
	 * The lump directory describes the layout of the rest of the file, 
	 * which contains some number of lumps. Each lump stores a particular kind of map data.
	 * @author lizhi
	 */
	public class Q3BSP
	{
		private var src:ByteArray;
		public var header:Q3BSPHeader = new Q3BSPHeader;
		
		///Lump directory, seventeen entries.
		public var lumps:Vector.<Q3BSPLump> = new <Q3BSPLump>[];
		
		///0	Entities	Game-related object descriptions.
		public var entities:Vector.<Q3BSPEntity> = new <Q3BSPEntity>[];
		
		///1	Textures	Surface descriptions.
		public var textures:Vector.<Q3BSPTexture> = new <Q3BSPTexture>[];
		
		///2	Planes	Planes used by map geometry.
		public var planes:Vector.<Q3BSPPlane> = new <Q3BSPPlane>[];
		
		///3	Nodes	BSP tree nodes.
		public var nodes:Vector.<Q3BSPNode> = new <Q3BSPNode>[];
		
		///4	Leafs	BSP tree leaves.
		public var leafs:Vector.<Q3BSPLeaf> = new <Q3BSPLeaf>[];
		
		///5	Leaffaces	Lists of face indices, one list per leaf.
		public var leaffaces:Vector.<Q3BSPLeafface> = new <Q3BSPLeafface>[];
		
		///6	Leafbrushes	Lists of brush indices, one list per leaf.
		public var leafbrushes:Vector.<Q3BSPLeafbrush> = new <Q3BSPLeafbrush>[];
		
		///7	Models	Descriptions of rigid world geometry in map.
		public var models:Vector.<Q3BSPModel> = new <Q3BSPModel>[];
		
		///8	Brushes	Convex polyhedra used to describe solid space.
		public var brushes:Vector.<Q3BSPBrush> = new <Q3BSPBrush>[];
		
		///9	Brushsides	Brush surfaces.
		public var brushsides:Vector.<Q3BSPBrushside> = new <Q3BSPBrushside>[];
		
		///10	Vertexes	Vertices used to describe faces.
		public var vertexes:Vector.<Q3BSPVertex> = new <Q3BSPVertex>[];
		
		///11	Meshverts	Lists of offsets, one list per mesh.
		public var meshverts:Vector.<Q3BSPMeshvert> = new <Q3BSPMeshvert>[];
		
		///12	Effects	List of special map effects.
		public var effects:Vector.<Q3BSPEffect> = new <Q3BSPEffect>[];
		
		///13	Faces	Surface geometry.
		public var faces:Vector.<Q3BSPFace> = new <Q3BSPFace>[];
		
		///14	Lightmaps	Packed lightmap data.
		public var lightmaps:Vector.<Q3BSPLightmap> = new <Q3BSPLightmap>[];
		public var lightmapBmd:BitmapData;
		
		///15	Lightvols	Local illumination data.
		public var lightVols:Vector.<Q3BSPLightvol> = new <Q3BSPLightvol>[];
		
		///16	Visdata	Cluster-cluster visibility data.
		public var visdata:Vector.<Q3BSPVisdata> = new <Q3BSPVisdata>[];
		public function Q3BSP(src:ByteArray) 
		{
			this.src = src;
			src.endian = Endian.LITTLE_ENDIAN;
			src.position = 0;
			readHeader();
			readLumps();
			readEntities(lumps[0]);
			readTextures(lumps[1]);
			readPlanes(lumps[2]);
			readNodes(lumps[3]);
			readLeafs(lumps[4]);
			readLeaffaces(lumps[6]);
			readLeafbrushes(lumps[6]);
			readModels(lumps[7]);
			readBrushes(lumps[8]);
			readBrushsides(lumps[9]);
			readVertexes(lumps[10]);
			readMeshverts(lumps[11]);
			readEffects(lumps[12]);
			readFaces(lumps[13]);
			readLightmaps(lumps[14]);
			readLightVols(lumps[15]);
			readVisdata(lumps[16]);
		}
		
		private function readVisdata(lump:Q3BSPLump):void 
		{
			
		}
		
		private function readLightVols(lump:Q3BSPLump):void 
		{
			
		}
		
		private function readLightmaps(lump:Q3BSPLump):void 
		{
			var lightmapSize:Number = 128 * 128;
			var count:int = lump.length / (lightmapSize*3);
			src.position = lump.offset;
			
			var gridSize:int = 2;
			
			while(gridSize * gridSize < count) {
				gridSize *= 2;
			}
			
			var textureSize:int = gridSize * 128;
			
			var xOffset:int = 0;
			var yOffset:int = 0;
			
			lightmapBmd = new BitmapData(gridSize*128, gridSize*128, false, 0xffffff);
			var rgb:Array = [ 0, 0, 0 ];
			
			for(var i:int = 0; i < count; ++i) {
				var elements:ByteArray = new ByteArray;// new Array(lightmapSize * 4);
				for(var j:int = 0; j < lightmapSize*4; j+=4) {
					rgb[0] = src.readUnsignedByte();
					rgb[1] = src.readUnsignedByte();
					rgb[2] = src.readUnsignedByte();
					
					brightnessAdjust(rgb, 4.0);
					elements.writeByte(255);
					elements.writeByte(rgb[0]);
					elements.writeByte(rgb[1]);
					elements.writeByte(rgb[2]);
				}
				elements.position = 0;
				lightmapBmd.setPixels(new Rectangle(xOffset, yOffset, 128, 128), elements);
				var lightmap:Q3BSPLightmap = new Q3BSPLightmap;
				lightmap.x = xOffset / textureSize;
				lightmap.y = yOffset / textureSize;
				lightmap.xScale = 128 / textureSize;
				lightmap.yScale = 128 / textureSize;
				lightmaps.push(lightmap);
				xOffset += 128;
				if(xOffset >= textureSize) {
					yOffset += 128;
					xOffset = 0;
				}
			}
		}
		
		private function brightnessAdjust(color:Array, factor:Number):void {
			var scale:Number = 1.0, temp:Number = 0.0;
			
			color[0] *= factor;
			color[1] *= factor;
			color[2] *= factor;
			
			if(color[0] > 255 && (temp = 255/color[0]) < scale) { scale = temp; }
			if(color[1] > 255 && (temp = 255/color[1]) < scale) { scale = temp; }
			if(color[2] > 255 && (temp = 255/color[2]) < scale) { scale = temp; }
			
			color[0] *= scale;
			color[1] *= scale;
			color[2] *= scale;
		}
		
		private function readFaces(lump:Q3BSPLump):void 
		{
			var count:int = lump.length / 104;
			src.position = lump.offset;
			for (var i:int = 0; i < count; i++ ) {
				var face:Q3BSPFace = new Q3BSPFace;
				face.texture = src.readUnsignedInt();
				face.effect = src.readUnsignedInt();
				face.type = src.readUnsignedInt();
				face.vertex = src.readUnsignedInt();
				face.n_vertexes = src.readUnsignedInt();
				face.meshvert = src.readUnsignedInt();
				face.n_meshverts = src.readUnsignedInt();
				face.lm_index = src.readUnsignedInt();
				face.lm_start = new Vector3D(src.readUnsignedInt(),src.readUnsignedInt());
				face.lm_size = new Vector3D(src.readUnsignedInt(),src.readUnsignedInt());
				face.lm_origin = new Vector3D(src.readFloat(),src.readFloat(),src.readFloat());
				face.lm_vecs = [
				new Vector3D(src.readFloat(),src.readFloat(),src.readFloat()),
				new Vector3D(src.readFloat(),src.readFloat(),src.readFloat())];
				face.normal = new Vector3D(src.readFloat(),src.readFloat(),src.readFloat());
				face.size = new Vector3D(src.readUnsignedInt(),src.readUnsignedInt());
				faces.push(face);
			}
		}
		
		private function readEffects(lump:Q3BSPLump):void 
		{
			var count:int = lump.length / 72;
			src.position = lump.offset;
			for (var i:int = 0; i < count; i++ ) {
				var effect:Q3BSPEffect = new Q3BSPEffect;
				effect.name = src.readUTFBytes(64);
				effect.brush = src.readUnsignedInt();
				effect.unknown = src.readUnsignedInt();
				effects.push(effect);
			}
		}
		
		private function readMeshverts(lump:Q3BSPLump):void 
		{
			var count:int = lump.length / 4;
			src.position = lump.offset;
			for (var i:int = 0; i < count; i++ ) {
				var meshvert:Q3BSPMeshvert = new Q3BSPMeshvert;
				meshvert.offset = src.readUnsignedInt();
				meshverts.push(meshvert);
			}
		}
		
		private function readVertexes(lump:Q3BSPLump):void 
		{
			var count:int = lump.length / 44;
			src.position = lump.offset;
			for (var i:int = 0; i < count; i++ ) {
				var vert:Q3BSPVertex = new Q3BSPVertex;
				vert.position=new Vector3D(src.readFloat(),src.readFloat(),src.readFloat());
				vert.texcoord = [
					new Vector3D(src.readFloat(), src.readFloat()),
					new Vector3D(src.readFloat(), src.readFloat())
				];
				vert.normal = new Vector3D(src.readFloat(), src.readFloat(), src.readFloat());
				vert.color = src.readUnsignedInt();
				vertexes.push(vert);
			}
		}
		
		private function readBrushsides(lump:Q3BSPLump):void 
		{
			var count:int = lump.length / 8;
			src.position = lump.offset;
			for (var i:int = 0; i < count; i++ ) {
				var side:Q3BSPBrushside = new Q3BSPBrushside;
				side.plane = src.readUnsignedInt();
				side.texture = src.readUnsignedInt();
				brushsides.push(side);
			}
		}
		
		private function readBrushes(lump:Q3BSPLump):void 
		{
			var count:int = lump.length / 12;
			src.position = lump.offset;
			for (var i:int = 0; i < count; i++ ) {
				var brush:Q3BSPBrush = new Q3BSPBrush;
				brush.brushside = src.readUnsignedInt();
				brush.n_brushsides = src.readUnsignedInt();
				brush.texture = src.readUnsignedInt();
				brushes.push(brush);
			}
		}
		
		private function readModels(lump:Q3BSPLump):void 
		{
			
		}
		
		private function readLeafbrushes(lump:Q3BSPLump):void 
		{
			var count:int = lump.length / 4;
			src.position = lump.offset;
			for (var i:int = 0; i < count; i++ ) {
				var brush:Q3BSPLeafbrush = new Q3BSPLeafbrush;
				brush.brush = src.readUnsignedInt();
				leafbrushes.push(brush);
			}
		}
		
		private function readLeaffaces(lump:Q3BSPLump):void 
		{
			var count:int = lump.length / 4;
			src.position = lump.offset;
			for (var i:int = 0; i < count; i++ ) {
				var face:Q3BSPLeafface = new Q3BSPLeafface;
				face.face = src.readUnsignedInt();
				leaffaces.push(face);
			}
		}
		
		private function readLeafs(lump:Q3BSPLump):void 
		{
			var count:int = lump.length / 48;
			src.position = lump.offset;
			for (var i:int = 0; i < count; i++ ) {
				var leaf:Q3BSPLeaf = new Q3BSPLeaf;
				leaf.cluster = src.readUnsignedInt();
				leaf.area = src.readUnsignedInt();
				leaf.mins = new Vector3D(src.readUnsignedInt(),src.readUnsignedInt(),src.readUnsignedInt());
				leaf.maxs = new Vector3D(src.readUnsignedInt(), src.readUnsignedInt(), src.readUnsignedInt());
				leaf.leafface = src.readUnsignedInt();
				leaf.n_leaffaces = src.readUnsignedInt();
				leaf.leafbrush = src.readUnsignedInt();
				leaf.n_leafbrushes = src.readUnsignedInt();
				leafs.push(leaf);
			}
		}
		
		private function readNodes(lump:Q3BSPLump):void 
		{
			var count:int = lump.length / 36;
			src.position = lump.offset;
			for (var i:int = 0; i < count; i++ ) {
				var node:Q3BSPNode = new Q3BSPNode;
				node.plane=src.readUnsignedInt();
				node.children = [src.readUnsignedInt(),src.readUnsignedInt()];
				node.min = new Vector3D(src.readUnsignedInt(),src.readUnsignedInt(),src.readUnsignedInt());
				node.max = new Vector3D(src.readUnsignedInt(), src.readUnsignedInt(), src.readUnsignedInt());
				nodes.push(node);
			}
		}
		
		private function readPlanes(lump:Q3BSPLump):void 
		{
			var count:int = lump.length / 16;
			src.position = lump.offset;
			for (var i:int = 0; i < count; i++ ) {
				var plane:Q3BSPPlane = new Q3BSPPlane;
				plane.normal = new Vector3D(src.readFloat(),src.readFloat(),src.readFloat());
				plane.distance = src.readFloat();
				planes.push(plane);
			}
		}
		
		private function readTextures(lump:Q3BSPLump):void 
		{
			var count:int = lump.length / 72;
			src.position = lump.offset;
			for (var i:int = 0; i < count; i++ ) {
				var texture:Q3BSPTexture = new Q3BSPTexture;
				texture.name = src.readUTFBytes(64);
				texture.flags=src.readUnsignedInt();
				texture.contents=src.readUnsignedInt();
				textures.push(texture);
			}
		}
		
		private function readEntities(lump:Q3BSPLump):void 
		{
			src.position = lump.offset;
			var entityData:String = src.readUTFBytes(lump.length);
			
			var end:int = -1;
			while(true)
			{
				var begin:int = entityData.indexOf('{', end + 1);
				if(begin == -1)
					break;
				
				end = entityData.indexOf('}', begin + 1);
				
				var entityString:String = entityData.substring(begin + 1, end);
				
				var entity:Q3BSPEntity = new Q3BSPEntity(entityString);
				
				//if(this.isBrushEntity(entity))
				//	this.brushEntities.push(entity);
				
				this.entities.push(entity);
			}
		}
		
		public function readHeader():void {
			header.magic=src.readUTFBytes(4);
			header.version=src.readUnsignedInt();
			if (header.magic!="IBSP"||header.version!=0x2e) {
				trace("不是Q3BSP");
			}
		}
		
		public function readLumps():void {
			for (var i:int = 0; i < 17; i++ ) {
				var lump:Q3BSPLump = new Q3BSPLump;
				lump.offset = src.readUnsignedInt();
				lump.length=src.readUnsignedInt()
				lumps.push(lump);
			}
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
				var entity:Q3BSPEntity = this.entities[i];

				if(entity.properties.classname == name)
					matches.push(entity);
			}
			
			return matches;
		}
	}

}