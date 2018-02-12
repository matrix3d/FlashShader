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
		public static var XtoY:int = 1;
		public static var XtoZ:int = 2;
		public static var YtoX:int = 3;
		public static var YtoZ:int = 4;
		public static var ZtoX:int = 5;
		public static var ZtoY:int = 6;
		
		private var upConversion:int;
		private var sign:Vector3D;
		public function Converter(upConversion:int,sign:Vector3D=null) 
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
				case XtoY:
					var tmp:Number = data[offset  ];
					data[ offset ] =  data[ offset+1 ];
					data[ offset+1 ] = tmp;
					break;
				case XtoZ:
					tmp = data[offset+ 2 ];
					data[offset+ 2 ] = data[ offset+1 ];
					data[offset+ 1 ] = data[ offset ];
					data[ offset] = tmp;
					break;
				case YtoX:
					tmp = data[ offset ];
					data[ offset ] = data[ offset+1 ];
					data[ offset+1 ] =  tmp;
					break;
				case YtoZ:
					tmp = data[ offset+1 ];
					data[ offset+1 ] =  data[ offset+2 ];
					data[ offset+2 ] = tmp;
					break;
				case ZtoX:
					tmp = data[ offset ];
					data[ offset ] = data[ offset+1 ];
					data[ offset+1 ] = data[ offset+2 ];
					data[ offset+2 ] = tmp;
					break;
				case ZtoY:
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
		
		private static var helpvec16:Vector.<Number> = new Vector.<Number>(16);
		private static var helparr3:Array = [];
		public function getConvertedMat4(m:Matrix3D):Matrix3D {
			if (upConversion||sign) {
				var data:Vector.<Number> = helpvec16;
				m.copyRawDataTo(data, 0, true);
				//var data:Array = [];
				//for (var i:int = 0; i < 16;i++ ) {
				//	data[i] = data2[i];
				//}
				
				// First fix rotation and scale
				// Columns first
				var arr:Array = helparr3;
				arr[0] = data[0];
				arr[1] = data[4];
				arr[2] = data[8];
				fixCoords( arr);
				data[ 0 ] = arr[ 0 ];
				data[ 4 ] = arr[ 1 ];
				data[ 8 ] = arr[ 2 ];
				arr[0] = data[ 1 ]
				arr[1] = data[ 5 ]
				arr[2]=data[ 9 ];
				fixCoords( arr);
				data[ 1 ] = arr[ 0 ];
				data[ 5 ] = arr[ 1 ];
				data[ 9 ] = arr[ 2 ];
				arr[0] = data[ 2 ]
				arr[1] = data[ 6 ]
				arr[2]=data[ 10 ];
				fixCoords( arr);
				data[ 2 ] = arr[ 0 ];
				data[ 6 ] = arr[ 1 ];
				data[ 10 ] = arr[ 2 ];
				// Rows second
				arr [0] =  data[ 0 ]
				arr[1] = data[ 1 ]
				arr[2]=data[ 2 ] ;
				fixCoords( arr);
				data[ 0 ] = arr[ 0 ];
				data[ 1 ] = arr[ 1 ];
				data[ 2 ] = arr[ 2 ];
				arr[0] =  data[ 4 ]
				arr[1] = data[ 5 ]
				arr[2]=data[ 6 ] ;
				fixCoords( arr);
				data[ 4 ] = arr[ 0 ];
				data[ 5 ] = arr[ 1 ];
				data[ 6 ] = arr[ 2 ];
				arr[0] =  data[ 8 ]
				arr[1] = data[ 9 ]
				arr[2]=data[ 10 ] ;
				fixCoords( arr);
				data[ 8 ] = arr[ 0 ];
				data[ 9 ] = arr[ 1 ];
				data[ 10 ] = arr[ 2 ];

				// Now fix translation
				arr[0] =  data[ 3 ]
				arr[1] = data[ 7 ]
				arr[2]=data[ 11 ] ;
				fixCoords( arr);
				data[ 3 ] = arr[ 0 ];
				data[ 7 ] = arr[ 1 ];
				data[ 11 ] = arr[ 2 ];
				
				m.copyRawDataFrom(data, 0, true);
			}
			return m;
		}
		
	}

}