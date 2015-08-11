package 
{
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.meshs.Meshs;
	import gl3d.meshs.ShapeBuilder;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestShape extends BaseExample
	{
		
		public function TestShape() 
		{
			
		}
		
		override public function initNode():void 
		{
			var sb:ShapeBuilder = ShapeBuilder.Cylinder(1, .5, 1);
			var node:Node3D = new Node3D;
			node.material = new Material;
			node.drawable = Meshs.sphere();// Meshs.createDrawable(sb.indexs, sb.vertexs, null, null);
			node.drawable = Meshs.createDrawable(sb.indexs, sb.vertexs, null, null);
			view.scene.addChild(node);
		}
		
	}

}