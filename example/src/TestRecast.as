package 
{
	import flash.display.Sprite;
	import flash.display3D.Context3DTriangleFace;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.meshs.Meshs;
	import gl3d.parser.obj.OBJParser;
	import org.recast4j.recast.PolyMeshDetail;
	import org.recast4j.recast.RecastMeshDetail;
	import test.AbstractDetourTest;
	import test.RecastSoloMeshTest;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestRecast extends BaseExample
	{
		
		public function TestRecast() 
		{
			
		}
		
		override public function initNode():void 
		{
			var rsmtest:RecastSoloMeshTest = new RecastSoloMeshTest();
			rsmtest.testDungeonWatershed();
			var mesh:PolyMeshDetail = rsmtest.m_dmesh; 
			var node:Node3D = new Node3D;
			view.scene.addChild(node);
			node.material = new Material;
			//node.material.culling = Context3DTriangleFace.NONE;
			node.material.wireframeAble = true;
			
			var ins:Vector.<uint> = new Vector.<uint>;
			for (var m:int= 0; m < mesh.nmeshes; m++) {
				var vfirst:int= mesh.meshes[m * 4];
				var tfirst:int= mesh.meshes[m * 4+ 2];
				for (var f:int= 0; f < mesh.meshes[m * 4+ 3]; f++) {
					ins.push((vfirst + mesh.tris[(tfirst + f) * 4] ) ,
							 (vfirst + mesh.tris[(tfirst + f) * 4+ 1]),
							 (vfirst + mesh.tris[(tfirst + f) * 4+ 2]) );
				}
			}
			
			var verts:Vector.<Number> = Vector.<Number>(mesh.verts);
			for (var i:int = 0; i < verts.length;i+=3 ) {
				verts[i+2] *= -1;
			}
			node.drawable = Meshs.createDrawable(ins, verts).unpackedDrawable;
			
			var obj:OBJParser = new OBJParser(AbstractDetourTest.getOBJ(
			"dungeon.obj"
			//"nav_test.obj"
			));
			view.scene.addChild(obj.target);
		}
		
	}

}