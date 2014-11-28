package gl3d.hlbsp 
{
	import flash.geom.Vector3D;
	import gl3d.core.Drawable3D;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.meshs.Meshs;
	/**
	 * ...
	 * @author lizhi
	 */
	public class BspRender 
	{
		public var target:Node3D = new Node3D;
		private var bsp:Bsp;
		private var faceBufferRegions:Array;
		public function BspRender(bsp:Bsp) 
		{
			this.bsp = bsp;
			
		}
		
		public function preRender():void {
			var vertices:Array = new Array();
			var index:Array = new Array();
			var texCoords:Array = new Array();
			var lightmapCoords:Array = new Array();
			var normals:Array = new Array();
			
			this.faceBufferRegions = new Array(bsp.faces.length);
			var elements:int = 0;

			// for each face
			for(var i:int = 0; i < bsp.faces.length; i++)
			{
				var face:BspFace = bsp.faces[i];
			
				this.faceBufferRegions[i] = {
					start : elements,
					count : face.edges
				};
				
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
					
					lightmapCoords.push(lightmapCoord.s);
					lightmapCoords.push(lightmapCoord.t);
					
					normals.push(normal.x);
					normals.push(normal.y);
					normals.push(normal.z);
					
					elements += 1;
					
					if (j > 1) {
						var start:int=this.faceBufferRegions[i].start
						index.push(start,j+start-1, j +start);
					}
				}
			}
			var drawable:Drawable3D = Meshs.createDrawable(Vector.<uint>(index), Vector.<Number>(vertices), Vector.<Number>(texCoords), null/*Vector.<Number>(normals)*/);
			target.drawable = drawable;
			target.material = new Material;
		}
		
	}

}