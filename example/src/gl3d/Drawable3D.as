package gl3d 
{
	import flash.display3D.Context3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Drawable3D 
	{
		public var pos:VertexBufferSet;
		public var norm:VertexBufferSet;
		public var tangent:VertexBufferSet;
		public var uv:VertexBufferSet;
		public var index:IndexBufferSet;
		public function Drawable3D() 
		{
			
		}
		
		public function update(context:Context3D):void 
		{
			if (pos) {
				pos.update(context);
			}if (norm) {
				norm.update(context);
			}if (uv) {
				uv.update(context);
			}if (tangent) {
				tangent.update(context);
			}
			if (index) {
				index.update(context);
			}
		}
		
	}

}