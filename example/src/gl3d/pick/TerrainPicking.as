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
		private var maxY:Number=Number.MIN_VALUE;
		private var minY:Number=Number.MAX_VALUE;
		
		private var inv:Matrix3D = new Matrix3D;
		private var cen:Vector3D =new Vector3D;
		public function TerrainPicking(node:Node3D) 
		{
			this.node = node;
			xyz = node.drawable.pos.data;
			size = Math.sqrt(xyz.length / 3);
			width = xyz[(size-1) * 3] - xyz[0];
			for (var i:int = 0; i < xyz.length;i+=3 ) {
				var y:Number = xyz[i + 1];
				if (y<minY) {
					minY = y;
				}
				if (y > maxY) {
					maxY = y;
				}
			}
		}
		
		override public function pick(node:Node3D,rayOrigin:Vector3D, rayDirection:Vector3D,pixelPos:Vector3D=null ):Boolean {
			inv.copyFrom(node.world);
			inv.invert();
			var localRayOrigin:Vector3D = inv.transformVector(rayOrigin);
			var localRayDirection:Vector3D = inv.deltaTransformVector(rayDirection);
			if (localRayOrigin.x<-width/2) {
				var dx:Number = -width / 2 - localRayOrigin.x;
				if (localRayDirection.x != 0) {
					var scale:Number = dx / localRayDirection.x;
					if (scale < 0) return false;
					localRayOrigin.x += localRayDirection.x*scale;
					localRayOrigin.y += localRayDirection.y*scale;
					localRayOrigin.z += localRayDirection.z*scale;
				}else {
					return false;
				}
			}else if (localRayOrigin.x>width/2) {
				dx = width / 2 - localRayOrigin.x;
				if (localRayDirection.x != 0) {
					scale = dx / localRayDirection.x;
					if (scale < 0) return false;
					localRayOrigin.x += localRayDirection.x*scale;
					localRayOrigin.y += localRayDirection.y*scale;
					localRayOrigin.z += localRayDirection.z*scale;
				}else {
					return false;
				}
			}else {
				
			}
			if (localRayOrigin.z<-width/2) {
				var dz:Number = -width / 2 - localRayOrigin.z;
				if (localRayDirection.z != 0) {
					scale = dz / localRayDirection.z;
					if (scale < 0) return false;
					localRayOrigin.x += localRayDirection.x*scale;
					localRayOrigin.y += localRayDirection.y*scale;
					localRayOrigin.z += localRayDirection.z*scale;
				}else {
					return false;
				}
			}else if (localRayOrigin.z>width/2) {
				dz = width / 2 - localRayOrigin.z;
				if (localRayDirection.z != 0) {
					scale = dz / localRayDirection.z;
					if (scale < 0) return false;
					localRayOrigin.x += localRayDirection.x*scale;
					localRayOrigin.y += localRayDirection.y*scale;
					localRayOrigin.z += localRayDirection.z*scale;
				}else {
					return false;
				}
			}else {
				
			}
			if (localRayDirection.y==0) {
				return false;
			}
			var localRayEnd:Vector3D
			if (localRayOrigin.y<minY) {
				var dy:Number = maxY - localRayOrigin.y;
				scale = dy / localRayDirection.y;
				
			}else {
				dy = maxY - localRayOrigin.y;
				scale = dy / localRayDirection.y;
			}
			scale = 1000;
			localRayEnd = new Vector3D(localRayOrigin.x + localRayDirection.x * scale, localRayOrigin.y + localRayDirection.y * scale, localRayOrigin.z + localRayDirection.z * scale);
			
			var y0:Number=getHeight(localRayOrigin.x,localRayOrigin.z)
			var y1:Number=getHeight(localRayEnd.x,localRayEnd.z)
			while (true) {
				cen.x = localRayOrigin.x / 2 + localRayEnd.x / 2;
				cen.y = localRayOrigin.y / 2 + localRayEnd.y / 2;
				cen.z = localRayOrigin.z / 2 + localRayEnd.z / 2;
				var cenY:Number = getHeight(cen.x, cen.z);
				var flag:Boolean = false;
				if ((localRayOrigin.y>y0&&cen.y>cenY)||(localRayOrigin.y<y0&&cen.y<cenY)) {
					localRayOrigin = cen;
					y0 = cenY;
				}else if(isNaN(y1)||(localRayEnd.y>y0&&cen.y>cenY)||(localRayEnd.y<y0&&cen.y<cenY)){
					localRayEnd = cen;
					y1 = cenY;
				}else{
					flag = true;
				}
				if (flag||Vector3D.distance(localRayOrigin,localRayEnd)<.01) {
					pixelPos.x = cen.x;
					pixelPos.z = cen.z;
					pixelPos.y = cenY;
					return true;
				}
			}
			return false;
		}
		
		public function getHeight(localX:Number, localY:Number):Number {
			var x:Number = (localX + width / 2) * (size-1) / width;
			var z:Number = (localY + width / 2) * (size-1) / width;
			var xi:int = x;
			var zi:int = z;
			if (xi >= 0 && zi >= 0 && xi < (size-1) && zi < (size-1)) {
				var x0:int = x;
				var x1:int = x0 + 1;
				var y0:int = z;
				var y1:int = z + 1;
				var dx0:Number =  x - x0;
				var dx1:Number = 1 - dx0;
				var dy0:Number =  z - y0;
				var dy1:Number = 1 - dy0;
				
				var i:int = xi + zi * size;
				var c0:Number = xyz[i*3+1];
				var c1:Number = xyz[(i+size)*3+1];
				var c2:Number = xyz[(i+1)*3+1];
				var c3:Number = xyz[(i + 1 + size)*3+1];
				
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