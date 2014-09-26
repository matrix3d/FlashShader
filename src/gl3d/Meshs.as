package gl3d 
{
	import flash.display3D.VertexBuffer3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Meshs 
	{
		
		public function Meshs() 
		{
			
		}
		
		public static function sphere(w:Number = 120, h:Number = 105):Drawable3D {
			var vs:Vector.<Number> = Vector.<Number>([0,-1,0]);
			var ins:Vector.<uint> = new Vector.<uint>;
			for (var i:int = 0; i < h - 1; i++ ) {
				var rot:Number = Math.PI / h * (i+1) -Math.PI/2;
				var sin:Number = Math.sin(rot);
				var cos:Number = Math.cos(rot);
				for (var j:int = 0; j < w;j++ ) {
					rot = Math.PI * 2 / w*j;
					vs.push(Math.cos(rot)*cos, sin, Math.sin(rot)*cos);
					var ni:int = vs.length/3 - 1;
					if (i==0) {
						if (j != 0) {
							ins.push(ni, ni - 1, 0);
						}else {
							ins.push(ni, ni + w - 1, 0);
						}
					}
					if (i > 0) {
						if (j != 0) {
							ins.push(ni, ni - 1, ni - w, ni - 1, ni - w - 1, ni - w);
						}
						else {
							ins.push(ni, ni + w - 1, ni - w, ni + w - 1, ni - 1, ni - w);
						}
					}
					if (i==h-2) {
						if (j != 0) {
							ins.push(ni, ni - 1, w*(h-1)+1);
						}else {
							ins.push(ni, ni + w - 1, w*(h-1)+1);
						}
					}
				}
			}
			vs.push(0,1,0);
			return createDrawable(ins, vs, null,vs);
		}
		
		public static function test():Drawable3D {
			return createDrawable(Vector.<uint>([0,1,2]), Vector.<Number>([1,1,0,1,0,0,0,1,0]), null, null);
		}
		public static function cube(width:Number=1,heigth:Number=1,depth:Number=1):Drawable3D {
			var hw:Number = width / 2;
			var hh:Number = heigth / 2;
			var hd:Number = depth / 2;
			return createDrawable(
				Vector.<uint>([
					0, 1, 2, 0, 2, 3,
					4, 5, 6, 4, 6, 7,
					8, 9, 10, 8, 10, 11,
					12, 13, 14, 12, 14, 15,
					16, 17, 18, 16, 18, 19,
					20, 21, 22, 20, 22, 23
					]),
				Vector.<Number>([
					hw, hh, hd, hw, -hh, hd, -hw, -hh, hd, -hw, hh, hd,
					hw, hh, -hd, hw, -hh, -hd, -hw, -hh, -hd, -hw, hh, -hd,
					hw, hh, hd, hw, hh, -hd, -hw, hh, -hd, -hw, hh, hd,
					hw, -hh, hd, hw, -hh, -hd, -hw, -hh, -hd, -hw, -hh, hd,
					hw, hh, hd, hw, hh, -hd, hw, -hh, -hd, hw, -hh, hd,
					-hw, hh, hd, -hw, hh, -hd, -hw, -hh, -hd, -hw, -hh, hd
				]),
				Vector.<Number>([
					1, 1, 1, 0, 0, 0, 0, 1,
					1, 1, 1, 0, 0, 0, 0, 1,
					1, 1, 1, 0, 0, 0, 0, 1,
					1, 1, 1, 0, 0, 0, 0, 1,
					1, 1, 1, 0, 0, 0, 0, 1,
					1, 1, 1, 0, 0, 0, 0, 1
				]),
				Vector.<Number>([
					0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1,
					0, 0, -1, 0, 0, -1, 0, 0, -1, 0, 0, -1,
					0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0,
					0, -1, 0, 0, -1, 0, 0, -1, 0, 0, -1, 0,
					1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0,
					-1, 0, 0, -1, 0, 0, -1, 0, 0, -1, 0, 0
				])
			);
		}
		
		public static function createDrawable(index:Vector.<uint>,pos:Vector.<Number>,uv:Vector.<Number>,norm:Vector.<Number>):Drawable3D {
			var drawable:Drawable3D = new Drawable3D;
			drawable.index = new IndexBufferSet(index);
			drawable.pos = new VertexBufferSet(pos,3);
			drawable.uv = new VertexBufferSet(uv,2);
			drawable.norm = new VertexBufferSet(norm, 3);
			return drawable;
		}
		
	}

}