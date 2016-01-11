package awayphysics 
{
	import awayphysics.math.AWPTransform;
	import AWPC_Run.CModule;
	import flash.geom.Matrix3D;
	import gl3d.core.Node3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class GL3DObject extends Away3dObject
	{
		public var node:Node3D;
		private var rawData:Vector.<Number> = new Vector.<Number>(16);
		public function GL3DObject(node:Node3D) 
		{
			this.node = node;
			rawData[15] = 1;
			
		}
		override public function set matrix(value:AWPTransform):void 
		{
			var p:int = value.pointer;
			rawData[0] = CModule.readFloat(p);
			rawData[1] = CModule.readFloat(p + 16);
			rawData[2] = CModule.readFloat(p + 32);
			rawData[4] = CModule.readFloat(p + 4);
			rawData[5] = CModule.readFloat(p + 20);
			rawData[6] = CModule.readFloat(p + 36);
			rawData[8] = CModule.readFloat(p + 8);
			rawData[9] = CModule.readFloat(p + 24);
			rawData[10] = CModule.readFloat(p + 40);
			rawData[12] = CModule.readFloat(p + 48)*_scaling;
			rawData[13] = CModule.readFloat(p + 52)*_scaling;
			rawData[14] = CModule.readFloat(p + 56)*_scaling;
			node.matrix.copyRawDataFrom(rawData);
			node.updateTransforms(true);
		}
	}

}