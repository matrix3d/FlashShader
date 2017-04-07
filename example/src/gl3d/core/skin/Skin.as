package gl3d.core.skin 
{
	import flash.geom.Matrix3D;
	import gl3d.core.Drawable;
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
		public static var MAX_WEIGHT:int = 4;
		public var skinFrame:SkinFrame;
		public var maxWeight:int;
		public var joints:Vector.<Joint> = new Vector.<Joint>;
		public var iks:Vector.<Joint> = new Vector.<Joint>;
		public var useQuat:Boolean = true;
		public var useHalfFloat:Boolean = true;
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
			if (node.drawable.source) {
				optimize2(node);
				return;
			}
			var jid2newjid:Object = { };
			var joints:Vector.<Joint> = new Vector.<Joint>;
			var drawable:Drawable = node.drawable;
			var js:Vector.<Number> = drawable.joint.data;
			var ws:Vector.<Number> = drawable.weight.data;
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
			node.drawable.joint = new VertexBufferSet(newjs, newMaxWeight);
			var news:Skin = new Skin;
			news.joints = joints;
			news.maxWeight = newMaxWeight;
			node.skin = news;
		}
		
		static private function optimize2(node:Node3D):void 
		{
			var jid2newjid:Object = { };
			var joints:Vector.<Joint> = new Vector.<Joint>;
			var drawable:Drawable = node.drawable;
			var js:Array = drawable.source.joint;
			if (js == null) return;
			var ws:Array = drawable.source.weight;
			var ins:Array = drawable.source.index;
			var maxWeight:int = node.skin.maxWeight;
			var newMaxWeight:int = 0;
			var newjid:int = 0;
			for (var i:int = 0,len:int=ins.length; i < len;i++ ) {
				var f:Array = ins[i];
				for (var k:int = 0,len2:int=f.length; k < len2;k++ ) {
					var count:int = 0;
					for (var j:int = 0; j < maxWeight;j++ ) {
						var ii:int = f[k] * maxWeight + j;
						var jid:int = js[ii];
						var w:Number = ws[ii];
						if (w != 0) {
							if (jid2newjid[jid] == null) {
								jid2newjid[jid] = newjid;
								joints[newjid] = node.skin.joints[jid];
								newjid++;
							}
							count++;
						}
					}
					if (newMaxWeight < count) newMaxWeight = count;
				}
			}
			
			newMaxWeight = maxWeight;
			var newjs:Array = [];
			for each(jid in js) {
				newjs.push(int(jid2newjid[jid]));
			}
			node.drawable.source.joint = newjs;
			var news:Skin = new Skin;
			news.joints = joints;
			news.maxWeight = newMaxWeight;
			node.skin = news;
		}
	}

}