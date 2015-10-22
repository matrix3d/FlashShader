package gl3d.util 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	/**
	 * 转换坐标系 ，需要转换坐标， 动画矩阵，和invbind矩阵
	 * @author lizhi
	 */
	public class Converter 
	{
		private var upConversion:String;
		private var sign:Vector3D;
		public function Converter(upConversion:String,sign:Vector3D=null) 
		{
			this.sign = sign;
			this.upConversion = upConversion;
		}
		
		public function convertedVec3s(data:Object):Object {
			if (upConversion||sign) {
				for (var i:int = 0, len:int = data.length; i < len;i+=3 ) {
					fixCoords(data, i);
				}
			}
			return data;
		}
		public function fixCoords( data:Object, offset:int = 0):void {
			switch ( upConversion ) {
				case 'XtoY':
					var tmp:Number = data[offset  ];
					data[ offset ] =  data[ offset+1 ];
					data[ offset+1 ] = tmp;
					break;
				case 'XtoZ':
					tmp = data[offset+ 2 ];
					data[offset+ 2 ] = data[ offset+1 ];
					data[offset+ 1 ] = data[ offset ];
					data[ offset] = tmp;
					break;
				case 'YtoX':
					tmp = data[ offset ];
					data[ offset ] = data[ offset+1 ];
					data[ offset+1 ] =  tmp;
					break;
				case 'YtoZ':
					tmp = data[ offset+1 ];
					data[ offset+1 ] =  data[ offset+2 ];
					data[ offset+2 ] = tmp;
					break;
				case 'ZtoX':
					tmp = data[ offset ];
					data[ offset ] = data[ offset+1 ];
					data[ offset+1 ] = data[ offset+2 ];
					data[ offset+2 ] = tmp;
					break;
				case 'ZtoY':
					tmp = data[ offset+1 ];
					data[offset+ 1 ] = data[ offset+2 ];
					data[ offset+2 ] =  tmp;
					break;

			}

			if (sign) {
				data[offset] *= sign.x;
				data[offset+1] *= sign.y;
				data[offset+2] *= sign.z;
			}
		}
		
		
		public function getConvertedMat4(m:Matrix3D):Matrix3D {
			if (upConversion||sign) {
				var data2:Vector.<Number> = new Vector.<Number>(16);
				m.copyRawDataTo(data2, 0, true);
				var data:Array = [];
				for (var i:int = 0; i < 16;i++ ) {
					data[i] = data2[i];
				}
				
				// First fix rotation and scale
				// Columns first
				var arr:Array = [ data[ 0 ], data[ 4 ], data[ 8 ] ];
				fixCoords( arr);
				data[ 0 ] = arr[ 0 ];
				data[ 4 ] = arr[ 1 ];
				data[ 8 ] = arr[ 2 ];
				arr = [ data[ 1 ], data[ 5 ], data[ 9 ] ];
				fixCoords( arr);
				data[ 1 ] = arr[ 0 ];
				data[ 5 ] = arr[ 1 ];
				data[ 9 ] = arr[ 2 ];
				arr = [ data[ 2 ], data[ 6 ], data[ 10 ] ];
				fixCoords( arr);
				data[ 2 ] = arr[ 0 ];
				data[ 6 ] = arr[ 1 ];
				data[ 10 ] = arr[ 2 ];
				// Rows second
				arr = [ data[ 0 ], data[ 1 ], data[ 2 ] ];
				fixCoords( arr);
				data[ 0 ] = arr[ 0 ];
				data[ 1 ] = arr[ 1 ];
				data[ 2 ] = arr[ 2 ];
				arr = [ data[ 4 ], data[ 5 ], data[ 6 ] ];
				fixCoords( arr);
				data[ 4 ] = arr[ 0 ];
				data[ 5 ] = arr[ 1 ];
				data[ 6 ] = arr[ 2 ];
				arr = [ data[ 8 ], data[ 9 ], data[ 10 ] ];
				fixCoords( arr);
				data[ 8 ] = arr[ 0 ];
				data[ 9 ] = arr[ 1 ];
				data[ 10 ] = arr[ 2 ];

				// Now fix translation
				arr = [ data[ 3 ], data[ 7 ], data[ 11 ] ];
				fixCoords( arr);
				data[ 3 ] = arr[ 0 ];
				data[ 7 ] = arr[ 1 ];
				data[ 11 ] = arr[ 2 ];
				
				m.copyRawDataFrom(Vector.<Number>(data), 0, true);
			}
			return m;
		}
		
	}

}