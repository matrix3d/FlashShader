package gl3d.pick 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import gl3d.core.Node3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class AS3Picking extends Picking
	{
		private var inv:Matrix3D;
		public function AS3Picking() 
		{
			
		}
		
		//http://www.cnblogs.com/graphics/archive/2010/08/09/1795348.html
		override public function pick(node:Node3D,rayOrigin:Vector3D, rayDirection:Vector3D,pixelPos:Vector3D=null ):Boolean {
			if (node.drawable) {
				inv = node.world2local;
				var localRayOrigin:Vector3D = inv.transformVector(rayOrigin);
				var localRayDirection:Vector3D = inv.deltaTransformVector(rayDirection);
				var rox:Number = localRayOrigin.x;
				var roy:Number = localRayOrigin.y;
				var roz:Number = localRayOrigin.z;
				var rdx:Number = localRayDirection.x;
				var rdy:Number = localRayDirection.y;
				var rdz:Number = localRayDirection.z;
				
				var ins:Vector.<uint> = node.drawable.index.data;
				var xyz:Vector.<Number> = node.drawable.pos.data;
				for (var i:int = 0,len:int=ins.length; i < len;i+=3 ) {
					var i0:int = ins[i]*3;
					var i1:int = ins[i+1]*3;
					var i2:int = ins[i+2]*3;
					var x0:Number = xyz[i0];
					var y0:Number = xyz[i0+1];
					var z0:Number = xyz[i0+2];
					var x1:Number = xyz[i1];
					var y1:Number = xyz[i1+1];
					var z1:Number = xyz[i1+2];
					var x2:Number = xyz[i2];
					var y2:Number = xyz[i2 + 1];
					var z2:Number = xyz[i2 + 2];
					
					var e1x:Number = x1-x0;
					var e1y:Number = y1-y0;
					var e1z:Number = z1-z0;
					var e2x:Number = x2-x0;
					var e2y:Number = y2-y0;
					var e2z:Number = z2-z0;
					var px:Number = rdy * e2z - rdz * e2y;
					var py:Number = rdz * e2x - rdx * e2z;
					var pz:Number = rdx * e2y - rdy * e2x;
					
					// determinant
					var det:Number = e1x * px + e1y * py + e1z * pz;

					// keep det > 0, modify T accordingly
					if( det >0 )
					{
						var tx:Number = rox-x0;
						var ty:Number = roy-y0;
						var tz:Number = roz-z0;
					}
					else
					{
						tx = x0-rox;
						ty = y0-roy;
						tz = z0-roz;
						det = -det;
					}

					// If determinant is near zero, ray lies in plane of triangle
					if ( det < 0.0001 ) {
						continue;
					}

					// Calculate u and make sure u <= 1
					var u:Number = tx * px + ty * py + tz * pz;
					if ( u < 0.0 || u > det ) {
						continue;
					}

					// Q
					var qx:Number = ty * e1z - tz * e1y;
					var qy:Number = tz * e1x - tx * e1z;
					var qz:Number = tx * e1y - ty * e1x;
					
					// Calculate v and make sure u + v <= 1
					var v:Number = rdx * qx + rdy * qy + rdz * qz;
					if ( v < 0.0 || u + v > det ) {
						continue;
						//return false;
					}

					// Calculate t, scale parameters, ray intersects triangle
					var t2:Number = e2x * qx + e2y * qy + e2z * qz;

					var fInvDet:Number = 1.0 / det;
					t2 *= fInvDet;
					u *= fInvDet;
					v *= fInvDet;
					if (pixelPos) {
						/*pixelPos.x = (1 - u - v) * x0 + u * x1 + x2 * v;
						pixelPos.y = (1 - u - v) * y0 + u * y1 + y2 * v;
						pixelPos.z = (1 - u - v) * z0 + u * z1 + z2 * v;
						pixelPos.copyFrom(node.world.transformVector(pixelPos));*/
						pixelPos.x = rayOrigin.x + t2 * rayDirection.x;
						pixelPos.y = rayOrigin.y + t2 * rayDirection.y;
						pixelPos.z = rayOrigin.z + t2 * rayDirection.z;
					}
					return true;
				}
			}
			return false;
		}
		
	}

}