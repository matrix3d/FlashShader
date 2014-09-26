package gl3d 
{
	import flash.display3D.Context3D;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Node3D 
	{
		public var parent:Node3D;
		public var world:Matrix3D = new Matrix3D;
		public var matrix:Matrix3D = new Matrix3D;
		public var children:Vector.<Node3D> = new Vector.<Node3D>;
		public var drawable:Drawable3D;
		public var material:Material;
		public function Node3D() 
		{
			
		}
		
		public function addChild(n:Node3D):void {
			children.push(n);
			n.parent = this;
		}
		
		public function update(view:View3D,camera:Camera3D):void {
			if (parent) {
				world.copyFrom(parent.world);
			}else {
				world.identity();
			}
			world.append(matrix);
			for each(var c:Node3D in children) {
				c.update(view,camera);
			}
			
			if (material) {
				material.draw(this,camera,view);
			}
		}
		
	}

}