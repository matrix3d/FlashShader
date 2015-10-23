package gl3d.parser.obj 
{
	import gl3d.core.Drawable3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class OBJEncoder 
	{
		
		public function OBJEncoder() 
		{
		}
		
		public static function encode(drawable:Drawable3D):String {
			var obj:String="# objencode v0.1\r\n";
			var v:Vector.<Number> = drawable.pos.data;
			for (var i:int = 0; i < v.length;i+=3 ) {
				obj +="v "+ v[i]+" "+v[i+1]+" "+(-v[i+2])+"\r\n";
			}
			var vt:Vector.<Number> = drawable.uv.data;
			for (i = 0; i < vt.length;i+=2 ) {
				obj +="vt "+ vt[i]+" "+(1-vt[i+1])+"\r\n";
			}
			obj += "s off\r\n";
			obj += "g " + "\r\n";
			var ins:Vector.<uint> = drawable.index.data;
			for (i = 0; i < ins.length; i += 3 ) {
				var i0:int = ins[i] + 1;
				var i1:int = ins[i+1] + 1;
				var i2:int = ins[i+2] + 1;
				obj +="f "+ i0+"/"+i0+" "+ i1+"/"+i1+" "+ i2+"/"+i2+"\r\n"
			}
			return obj;
		}
		
	}

}