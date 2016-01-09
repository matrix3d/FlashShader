package awayphysics.collision.shapes {
	import AWPC_Run.*;
	
	import flash.utils.getQualifiedClassName;
	
	public class AWPBvhTriangleMeshShape extends AWPCollisionShape {
		private var indexDataPtr : uint;
		private var vertexDataPtr : uint;
		/**
		 *create a static triangle mesh shape with a 3D mesh object
		 */
		public function AWPBvhTriangleMeshShape(indexData:Vector.<uint>,vertexData:Vector.<Number>, subGeometryIndex:int = 0, useQuantizedAabbCompression : Boolean = true) {
			var vertexDataNum:int = 3;
			var indexDataLen : int = indexData.length;
			indexDataPtr = createTriangleIndexDataBufferInC(indexDataLen);
			
			for (var i : int = 0; i < indexDataLen; i++ ) {
				CModule.write32(indexDataPtr+i*4,indexData[i]);
			}
			
			var vertexDataLen : int = vertexData.length/vertexDataNum;
			vertexDataPtr = createTriangleVertexDataBufferInC(vertexDataLen*3);
			
			for (i = 0; i < vertexDataLen; i++ ) {
				CModule.writeFloat(vertexDataPtr+i*12,vertexData[i*vertexDataNum] / _scaling);
				CModule.writeFloat(vertexDataPtr+i*12 + 4,vertexData[i*vertexDataNum+1] / _scaling);
				CModule.writeFloat(vertexDataPtr+i*12 + 8,vertexData[i*vertexDataNum+2] / _scaling);
			}
			
			var triangleIndexVertexArrayPtr : uint = createTriangleIndexVertexArrayInC(int(indexDataLen / 3), indexDataPtr, int(vertexDataLen), vertexDataPtr);
			
			pointer = createBvhTriangleMeshShapeInC(triangleIndexVertexArrayPtr, useQuantizedAabbCompression ? 1 : 0, 1);
			super(pointer, 9);
		}
		
		override public function dispose() : void {
			m_counter--;
			if (m_counter > 0) {
				return;
			}else {
				m_counter = 0;
			}
			if (!_cleanup) {
				_cleanup  = true;
				removeTriangleIndexDataBufferInC(indexDataPtr);
				removeTriangleVertexDataBufferInC(vertexDataPtr);
				disposeCollisionShapeInC(pointer);
			}
		}
	}
}