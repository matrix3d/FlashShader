package gl3d.pick 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import gl3d.Node3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TerrainPicking extends Picking
	{
		private var node:Node3D;
		private var xyz:Vector.<Number>;
		private var size:int;
		private var width:Number;
		
		private var inv:Matrix3D = new Matrix3D;
		private var cen:Vector3D =new Vector3D;
		public function TerrainPicking(node:Node3D) 
		{
			this.node = node;
			xyz = node.drawable.pos.data;
			size = Math.sqrt(xyz.length / 3);
			width = xyz[(size-1) * 3] - xyz[0];
		}
		
		override public function pick(node:Node3D,rayOrigin:Vector3D, rayDirection:Vector3D,pixelPos:Vector3D=null ):Boolean {
			inv.copyFrom(node.world);
			inv.invert();
			var localRayOrigin:Vector3D = inv.transformVector(rayOrigin);
			var localRayDirection:Vector3D = inv.deltaTransformVector(rayDirection);
			if (localRayDirection.y>=0) {
				return false;
			}
			if (localRayDirection.x==0&&localRayDirection.z==0) {//垂直射入的射线直接返回结果
				var height:Number = getHeight(localRayOrigin.x,localRayOrigin.z);
				if (isNaN(height)||height>localRayOrigin.y) {
					return false;
				}else {
					if (pixelPos!=null) {
						pixelPos.x = localRayOrigin.x;
						pixelPos.z = localRayOrigin.z;
						pixelPos.y = height;
					}
					return true;
				}
			}
			
			var dxStart:Number = 0;
			var dxEnd:Number = 0;
			var dzStart:Number = 0;
			var dzEnd:Number = 0;
			if (localRayDirection.x>0) {
				dxStart = -width / 2 - localRayOrigin.x;
				dxEnd = width / 2 - localRayOrigin.x;
			}else if (localRayDirection.x<0) {
				dxStart = width / 2 - localRayOrigin.x;
				dxEnd = -width / 2 - localRayOrigin.x;
			}
			if (localRayDirection.z>0) {
				dzStart =-width / 2 - localRayOrigin.z;
				dzEnd = width / 2 - localRayOrigin.z;
			}else if (localRayDirection.z<0) {
				dzStart = width / 2 - localRayOrigin.z;
				dzEnd = -width / 2 - localRayOrigin.z;
			}
			var scale:Number = 0;
			if (localRayDirection.x!=0) {
				scale = dxStart / localRayDirection.x;
			}
			if (localRayDirection.z!=0) {
				var temp:Number = dzStart / localRayDirection.z;
				if (temp>scale) {
					scale = temp;
				}
			}
			if (scale > 0) {
				var sx:Number = localRayOrigin.x + localRayDirection.x * scale;
				var sy:Number = localRayOrigin.y + localRayDirection.y * scale;
				var sz:Number = localRayOrigin.z + localRayDirection.z * scale;
			}
			scale = 0;
			if (localRayDirection.x!=0) {
				scale = dxEnd / localRayDirection.x;
			}
			if (localRayDirection.z!=0) {
				temp = dzEnd / localRayDirection.z;
				if (temp<scale) {
					scale = temp;
				}
			}
			if (scale > 0) {
				var ex:Number = localRayOrigin.x + localRayDirection.x * scale;
				var ey:Number = localRayOrigin.y + localRayDirection.y * scale;
				var ez:Number = localRayOrigin.z + localRayDirection.z * scale;
			}else {
				return false;
			}
			
			var sheight:Number=getHeight(sx,sz)
			var eheight:Number=getHeight(ex,ez)
			if (sy<sheight||ey>eheight) {
				return false;
			}
			
			while (true) {
				var cx:Number = sx / 2 + ex / 2;
				var cy:Number = sy / 2 + ey / 2;
				var cz:Number = sz / 2 + ez / 2;
				height = getHeight(cx, cz);
				if (cy>height) {
					sx = cx;
					sy = cy;
					sz = cz;
				}else {
					ex = cx;
					ey = cy;
					ez = cz;
				}
				if (sy-ey<.01) {
					pixelPos.x = sx;
					pixelPos.z = sz;
					pixelPos.y = sy;
					return true;
				}
			}
			return false;
		}
		
		public function getHeight(localX:Number, localY:Number):Number {
			var x:Number = (localX + width / 2) * (size-1) / width;
			var z:Number = (localY + width / 2) * (size-1) / width;
			var x0:int = x;
			var y0:int = z;
			if (x0 >= 0 && y0 >= 0 && x0 < size && y0 < size) {
				var x1:int = x0 + 1;
				var y1:int = z + 1;
				var dx0:Number =  x - x0;
				var dx1:Number = 1 - dx0;
				var dy0:Number =  z - y0;
				var dy1:Number = 1 - dy0;
				
				var i:int = x0 + y0 * size;
				var c0:Number = xyz[i*3+1];// x0 y0
				var c1:Number = y1<size?xyz[(i+size)*3+1]:0;//x0 y1
				var c2:Number = x1<size?xyz[(i+1)*3+1]:0;//x1 y0
				var c3:Number = (x1<size&&y1<size)?xyz[(i + 1 + size)*3+1]:0;//x1 y1
				
				c0 *= dx1 * dy1;
				c1 *= dx1 * dy0;
				c2 *= dx0 * dy1;
				c3 *= dx0 * dy0;
				
				c0 += c1 + c2 + c3;
				return c0;
			}
			return Number.NaN;
		}
	}
}