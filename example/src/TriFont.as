package 
{
	import DDLS.data.DDLSConstraintSegment;
	import DDLS.data.DDLSEdge;
	import DDLS.data.DDLSFace;
	import DDLS.data.DDLSMesh;
	import DDLS.data.DDLSVertex;
	import DDLS.data.graph.DDLSGraph;
	import DDLS.data.math.DDLSPotrace;
	import DDLS.factories.DDLSRectMeshFactory;
	import flash.display.Bitmap;
	import flash.display3D.Context3DTriangleFace;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.text.Font;
	import gl3d.util.Utils;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.TextureSet;
	import gl3d.meshs.Meshs;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TriFont extends BaseExample
	{
		private var node:Node3D;
		
		public function TriFont() 
		{
			
		}
		
		override public function initNode():void 
		{
			trace("1");
			var arr:Array= Font.enumerateFonts(true);
			
			addSky();
			var tf:TextField = new TextField;
			tf.defaultTextFormat = new TextFormat("宋体", 100,null,true);
			tf.text = loaderInfo.parameters["text"] || "齉龘饕餮";
			tf.autoSize = "left";
			var bmd:BitmapData = new BitmapData(tf.width, tf.height, false, 0xffffff);
			bmd.draw(tf);
			
			// 2 containers to store result of extraction
			var vertices:Vector.<Point> = new Vector.<Point>();
			var triangles:Vector.<int> = new Vector.<int>();
			
			// extraction !
			var constraineds:Object = { };
			extractMeshFromBitmap(bmd, vertices, triangles,constraineds);
			var vs:Vector.<Number> = new Vector.<Number>;
			for each(var v:Point in vertices) {
				vs.push((v.x-tf.width/2)/50, -(v.y-tf.height/2)/50, -0.1);
				vs.push((v.x-tf.width/2)/50, -(v.y-tf.height/2)/50, 0.1);
				vs.push((v.x-tf.width/2)/50, -(v.y-tf.height/2)/50, -0.1);
				vs.push((v.x-tf.width/2)/50, -(v.y-tf.height/2)/50, 0.1);
			}
			var ins:Vector.<uint> = new Vector.<uint>;
			for each(var i:int in triangles) {
				ins.push(i*4);
			}
			for each(i in triangles) {
				ins.unshift(i*4+1);
			}
			
			for (i=0 ; i<triangles.length ; i+=3)
			{
				var i0:int = triangles[i];
				var i1:int = triangles[i+1];
				var i2:int = triangles[i + 2];
				if(constraineds[Math.min(i0,i1)+" "+Math.max(i0,i1)]){
					ins.push(i0*4+2);
					ins.push(i0*4+3);
					ins.push(i1 * 4 + 2);
					
					ins.push(i0 * 4+3)
					ins.push(i1*4+3);;
					ins.push(i1*4+2);
				}
				if(constraineds[Math.min(i1,i2)+" "+Math.max(i1,i2)]){
					ins.push(i1*4+2);
					ins.push(i1*4+3);
					ins.push(i2 * 4 + 2);
					
					ins.push(i1 * 4+3);
					ins.push(i2*4+3);
					ins.push(i2*4+2);
				}
				if(constraineds[Math.min(i0,i2)+" "+Math.max(i0,i2)]){
					ins.push(i2*4+2);
					ins.push(i2*4+3);
					ins.push(i0 * 4 + 2);
					
					ins.push(i2 * 4+3);
					ins.push(i0*4+3);
					ins.push(i0*4+2);
				}
			}
			
			node = new Node3D;
			node.material = new Material;
			//node.material.culling = Context3DTriangleFace.NONE;
			view.scene.addChild(node);
			node.drawable = Meshs.createDrawable(ins, vs, null, null);
			
			bmd = new BitmapData(128, 128, false, 0);
			bmd.perlinNoise(4, 10, 2, 1, true, true);
			
			node.material.reflectTexture = skyBoxTexture;// new TextureSet([bmd, bmd, bmd, bmd, bmd, bmd]);
			node.drawable = Meshs.unpack(node.drawable);
			node.material.wireframeAble = true;
			
			/*var screenMesh:Sprite = new Sprite();
			addChild(screenMesh);
			screenMesh.y = 200;
			screenMesh.graphics.lineStyle(1, 0xFF0000);
			for (i=0 ; i<triangles.length ; i+=3)
			{
				screenMesh.graphics.moveTo(vertices[triangles[i]].x, vertices[triangles[i]].y);
				screenMesh.graphics.lineTo(vertices[triangles[i+1]].x, vertices[triangles[i+1]].y);
				screenMesh.graphics.lineTo(vertices[triangles[i+2]].x, vertices[triangles[i+2]].y);
				screenMesh.graphics.lineTo(vertices[triangles[i]].x, vertices[triangles[i]].y);
			}*/
			trace(2);
		}
		
		override public function enterFrame(e:Event):void 
		{
			//node.matrix.appendRotation(1, Vector3D.Y_AXIS);
			//node.updateTransforms();
			super.enterFrame(e);
		}
		
		static public function extractMeshFromBitmap(bmpData:BitmapData, vertices:Vector.<Point>, triangles:Vector.<int>,constraineds:Object):void
		{
			trace(3);
			var i:int;
			var j:int;
			
			// OUTLINES STEP-LIKE SHAPES GENERATION
			var shapes:Vector.<Vector.<Number>> = DDLSPotrace.buildShapes(bmpData);
			
			// GRAPHS OF POTENTIAL SEGMENTS GENERATION
			var graphs:Vector.<DDLSGraph> = new Vector.<DDLSGraph>();
			for (i=0 ; i<shapes.length ; i++)
			{
				graphs.push( DDLSPotrace.buildGraph(shapes[i]) );
			}
			
			// OPTIMIZED POLYGONS GENERATION
			var polygons:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
			for (i=0 ; i<graphs.length ; i++)
			{
				polygons.push( DDLSPotrace.buildPolygon(graphs[i]));
			}
			
			// MESH GENERATION
			var mesh:DDLSMesh = DDLSRectMeshFactory.buildRectangle(bmpData.width, bmpData.height);
			var edges:Vector.<DDLSEdge> = new Vector.<DDLSEdge>(); // WE KEEP TRACK OF 1 EDGE BY SHAPE
			var segment:DDLSConstraintSegment;
			for (i=0 ; i<polygons.length ; i++)
			{
				for (j=0 ; j<polygons[i].length-2 ; j+=2)
				{
					segment = mesh.insertConstraintSegment(polygons[i][j], polygons[i][j+1], polygons[i][j+2], polygons[i][j+3]);
					if (j==0)
					{
						if (segment.edges[0].originVertex.pos.x == polygons[i][j] && segment.edges[0].originVertex.pos.y == polygons[i][j+1])
							edges.push(segment.edges[0]);
						else
							edges.push(segment.edges[0].oppositeEdge);
					}
				}
				mesh.insertConstraintSegment(polygons[i][0], polygons[i][1], polygons[i][j], polygons[i][j+1]);
			}
			
			// FINAL EXTRACTION
			var indicesDict:Dictionary = new Dictionary();
			var vertex:DDLSVertex;
			var point:Point;
			for (i=0 ; i<mesh.__vertices.length ; i++)
			{
				vertex = mesh.__vertices[i];
				if (vertex.isReal
					&& vertex.pos.x > 0 && vertex.pos.x < bmpData.width
					&& vertex.pos.y > 0 && vertex.pos.y < bmpData.height)
				{
					point = new Point(vertex.pos.x, vertex.pos.y);
					vertices.push(point);
					indicesDict[vertex] = vertices.length-1;
				}
			}
			
			var temp:Object = { };
			for each(var ed:DDLSEdge in mesh.__edges) {
				if (ed.isConstrained) {
					var i0:int = indicesDict[ed.originVertex];
					var i1:int = indicesDict[ed.destinationVertex];
					constraineds[Math.min(i0,i1)+" "+Math.max(i0,i1)] = true;
				}
			}
			
			var facesDone:Dictionary = new Dictionary();
			var openFacesList:Vector.<DDLSFace> = new Vector.<DDLSFace>();
			for (i=0 ; i<edges.length ; i++)
			{
				openFacesList.push(edges[i].rightFace);
			}
			var currFace:DDLSFace;
			while (openFacesList.length > 0)
			{
				currFace = openFacesList.pop();
				if (facesDone[currFace])
					continue;
				
				triangles.push(indicesDict[currFace.edge.originVertex]);
				triangles.push(indicesDict[currFace.edge.nextLeftEdge.originVertex]);
				triangles.push(indicesDict[currFace.edge.nextLeftEdge.destinationVertex]);
				
				if (! currFace.edge.isConstrained)
					openFacesList.push(currFace.edge.rightFace);
				if (! currFace.edge.nextLeftEdge.isConstrained)
					openFacesList.push(currFace.edge.nextLeftEdge.rightFace);
				if (! currFace.edge.prevLeftEdge.isConstrained)
					openFacesList.push(currFace.edge.prevLeftEdge.rightFace);
				
				facesDone[currFace] = true;
			}
			trace(4);
		}
		
	}

}