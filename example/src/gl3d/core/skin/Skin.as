package gl3d.core.skin 
{
	import flash.geom.Matrix3D;
	import gl3d.core.Drawable3D;
	import gl3d.core.skin.Joint;
	import gl3d.core.Node3D;
	import gl3d.core.VertexBufferSet;
	import gl3d.meshs.Meshs;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Skin 
	{
		public var skinFrame:SkinFrame;
		public var maxWeight:int;
		public var joints:Vector.<Joint> = new Vector.<Joint>;
		//public var invBindMatrixs:Vector.<Matrix3D> = new Vector.<Matrix3D>;
		public var useQuat:Boolean = true;
		public var useCpu:Boolean = false;
		public function Skin() 
		{
			
		}
		
		/**
		 * 优化一个skin node，
		 * 提取用到的骨骼
		 * @param	node
		 */
		public static function optimize(node:Node3D):void {
			var jid2newjid:Object = { };
			var joints:Vector.<Joint> = new Vector.<Joint>;
			//var invBindMatrixs:Vector.<Matrix3D> = new Vector.<Matrix3D>;
			var drawable:Drawable3D = node.drawable;
			var js:Vector.<Number> = drawable.joints.data;
			var ws:Vector.<Number> = drawable.weights.data;
			var ins:Vector.<uint> = drawable.index.data;
			var maxWeight:int = node.skin.maxWeight;
			var newMaxWeight:int = 0;
			var newjid:int = 0;
			for (var i:int = 0,len:int=ins.length; i < len;i++ ) {
				var count:int = 0;
				for (var j:int = 0; j < maxWeight;j++ ) {
					var ii:int = ins[i] * maxWeight + j;
					var jid:int = js[ii];
					var w:Number = ws[ii];
					if (w != 0) {
						if (jid2newjid[jid] == null) {
							jid2newjid[jid] = newjid;
							joints[newjid] = node.skin.joints[jid];
							//invBindMatrixs[newjid] = node.skin.invBindMatrixs[jid];
							newjid++;
						}
						count++;
					}
				}
				if (newMaxWeight < count) newMaxWeight = count;
			}
			
			newMaxWeight = maxWeight;
			var newjs:Vector.<Number> = new Vector.<Number>;
			for each(jid in js) {
				newjs.push(int(jid2newjid[jid]));
			}
			
			node.drawable = new Drawable3D;
			node.drawable.index = drawable.index;
			node.drawable.uv = drawable.uv;
			node.drawable.pos = drawable.pos;
			node.drawable.joints = new VertexBufferSet(newjs, newMaxWeight);
			node.drawable.weights = drawable.weights;
			var news:Skin = new Skin;
			//news.invBindMatrixs = invBindMatrixs;
			news.joints = joints;
			news.maxWeight = newMaxWeight;
			node.skin = news;
		}
	}

}