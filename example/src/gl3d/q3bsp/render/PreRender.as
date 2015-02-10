package gl3d.q3bsp.render 
{
	import flash.display.BitmapData;
	import gl3d.core.Drawable3D;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.TextureSet;
	import gl3d.core.VertexBufferSet;
	import gl3d.meshs.Meshs;
	import gl3d.q3bsp.Q3BSP;
	import gl3d.q3bsp.Q3BSPFace;
	import gl3d.q3bsp.Q3BSPLightmap;
	import gl3d.q3bsp.Q3BSPTexture;
	import gl3d.q3bsp.Q3BSPVertex;
	import gl3d.shaders.LightMapGLShader;
	import gl3d.util.Utils;
	/**
	 * ...
	 * @author lizhi
	 */
	public class PreRender 
	{
		private var bsp:Q3BSP;
		public var target:Node3D = new Node3D;
		public function PreRender(bsp:Q3BSP) 
		{
			this.bsp = bsp;
			var b:BitmapData = new BitmapData(512, 512);
			Utils.createXorMap(b)
			var diffTexture:TextureSet = new TextureSet(b);
			var lightmapTexture:TextureSet = new TextureSet(bsp.lightmapBmd);
			var textures:Array = [];
			for (var i:int = 0; i < bsp.faces.length; i++)
			{
				var face:Q3BSPFace = bsp.faces[i];
				if (textures[face.texture]==null) {
					textures[face.texture] = [];
				}
				textures[face.texture].push(face);
			}
			for (var key:String in textures) {
				var arr:Array = textures[key];
				var index:Vector.<uint> = new Vector.<uint>;
				var vertices:Vector.<Number> = new <Number>[];
				var uvs:Vector.<Number> = new <Number>[];
				var lmuvs:Vector.<Number> = new <Number>[];
				for each(face in arr) {
					var start:int = vertices.length / 3;
					if (face.lm_index < 0) face.lm_index = 0;
					if(face.lm_index<bsp.lightmaps.length){
						var lightmap:Q3BSPLightmap = bsp.lightmaps[face.lm_index];
					}
					if (lightmap==null) {
						lightmap = new Q3BSPLightmap;
					}
					for (var j:int = 0; j < face.n_meshverts; j++)
					{	
						var vertex:Q3BSPVertex = bsp.vertexes[face.vertex+bsp.meshverts[face.meshvert+j].offset];
						
						vertices.push(vertex.position.x);
						vertices.push(vertex.position.y);
						vertices.push(vertex.position.z);
						uvs.push(1-vertex.texcoord[0].x);
						uvs.push(vertex.texcoord[0].y);
						lmuvs.push(vertex.texcoord[1].x * lightmap.xScale+lightmap.x,
						vertex.texcoord[1].y*lightmap.yScale+lightmap.y);
						if (j > 1)
						{
							//index.push(start, j + start, j + start-1);
						}
						if (j%3==2) {
							index.push(start+j-1, start+j-2, start+j);
						}
					}
				}
				if (vertices.length>0&&index.length>0) {
					var d:Drawable3D = Meshs.createDrawable(index, vertices, uvs, null);
					d.lightmapUV = new VertexBufferSet(lmuvs, 2);
					var node:Node3D = new Node3D;
					node.drawable = d;
					node.material = new Material;
					node.material.shader = new LightMapGLShader;
					node.material.diffTexture = diffTexture
					node.material.lightmapTexture = lightmapTexture
					target.addChild(node);
				}
			}
		}
		
	}

}