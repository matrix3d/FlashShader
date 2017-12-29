package 
{
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.display3D.Context3DTriangleFace;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	import gl3d.core.Drawable;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.ctrl.ArcBallCtrl;
	import gl3d.meshs.Meshs;
	import gl3d.meshs.Teapot;
	import gl3d.parser.obj.OBJParser;
	import org.recast4j.detour.FindNearestPolyResult;
	import org.recast4j.detour.FindPathResult;
	import org.recast4j.detour.MeshTile;
	import org.recast4j.detour.QueryFilter;
	import org.recast4j.detour.StraightPathItem;
	import org.recast4j.detour.Tupple2;
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
		private var obj:OBJParser;
		private var node:Node3D;
		private var startNode:Node3D;
		private var endNode:Node3D;
		private var rsmtest:RecastSoloMeshTest;
		private var pathWrapper:Node3D;
		private var cubeDrawable:Drawable = Meshs.sphere()
		private var dfM:Material = new Material;
		public function TestRecast() 
		{
			dfM.color.setTo(0, 1, 1);
		}
		
		override public function initNode():void 
		{
			rsmtest = new RecastSoloMeshTest();
			rsmtest.testDungeonWatershed();
			rsmtest.setUp();
			
			var res:FindNearestPolyResult = rsmtest.query.findNearestPoly([0,0,0],[0,0,0],new QueryFilter);
			trace(res.getNearestRef());
			//return;
			var mesh:PolyMeshDetail = rsmtest.m_dmesh; 
			node = new Node3D;
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
			
			obj = new OBJParser(AbstractDetourTest.getOBJ(
			"dungeon.obj"
			//"nav_test.obj"
			));
			view.scene.addChild(obj.target);
			
			stage.addEventListener(MouseEvent.CLICK, stage_click);
			
			startNode = new Node3D;
			startNode.material = new Material;
			startNode.drawable = Meshs.cube();
			//startNode.setScale(.3, .3, .3);
			startNode.material.color.setTo(0, 1, 0);
			view.scene.addChild(startNode);
			endNode = new Node3D;
			endNode.material = new Material;
			endNode.material.color.setTo(1, 0, 0);
			endNode.drawable = Teapot.teapot();
			endNode.setScale(.3, .3, .3);
			view.scene.addChild(endNode);
			
			pathWrapper = new Node3D;
			view.scene.addChild(pathWrapper);
			
		}
		
		private function stage_click(e:MouseEvent):void 
		{
			var rayOrigin:Vector3D = new Vector3D;
			var rayDirection:Vector3D = new Vector3D;
			var pix:Vector3D = new Vector3D;
			view.camera.computePickRayDirectionMouse(mouseX, mouseY, stage.stageWidth, stage.stageHeight, rayOrigin, rayDirection);
			var t:int = getTimer();
			if (node.rayMeshTest(rayOrigin, rayDirection, pix)){
				//startNode.x = pix.x;
				//startNode.y = pix.y;
				//startNode.z = pix.z;
				endNode.setPosition(startNode.x, startNode.y, startNode.z);
				startNode.setPosition(pix.x, pix.y, pix.z);
				
				var startPos:Array = [pix.x, pix.y, -pix.z];
				var endPos:Array = [endNode.x, endNode.y, -endNode.z];
				var startRef:FindNearestPolyResult = rsmtest.query.findNearestPoly(startPos, [0, 0, 0], new QueryFilter);
				var endRef:FindNearestPolyResult = rsmtest.query.findNearestPoly(endPos, [0, 0, 0], new QueryFilter);
				pathWrapper.children.length = 0;
				if (startRef.getNearestRef()&&endRef.getNearestRef()){
					var res:FindPathResult= rsmtest.query.findPath(startRef.getNearestRef(), endRef.getNearestRef(), startPos, endPos, new QueryFilter);
					var path:Array = rsmtest.query.findStraightPath(startPos, endPos, res.getRefs(), 0xffffffff);
					var lastItem:StraightPathItem;
					for each(var item:StraightPathItem in path){
						if (lastItem){
							var vstart:Array = [lastItem.getPos()[0],lastItem.getPos()[1],-lastItem.getPos()[2]];
							var vend:Array = [item.getPos()[0],item.getPos()[1],-item.getPos()[2]];
							var vd:Array = [vend[0]-vstart[0],vend[1]-vstart[1],vend[2]-vstart[2]];
							var len:Number = Math.ceil(Math.sqrt(vd[0]*vd[0]+vd[1]*vd[1]+vd[2]*vd[2]));
							for (var i:int = 0; i <= len;i++ ){
								var p:Node3D = new Node3D;
								pathWrapper.addChild(p);
								p.material = dfM;
								p.drawable = cubeDrawable;
								var np:Array = [vstart[0]+vd[0]*i/len,vstart[1]+vd[1]*i/len,vstart[2]+vd[2]*i/len];
								p.setPosition(np[0],np[1],np[2]);
							}
							
						}
						lastItem = item;
					}
				}else{
					trace("找不到？",startPos,endPos,startRef.getNearestRef(),endRef.getNearestRef());
				}
			}
			trace(getTimer()-t,"ms");
		}
		
	}

}