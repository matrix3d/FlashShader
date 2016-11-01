package gl3d.core 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class Scene3D extends Node3D
	{
		
		public function Scene3D() 
		{
			
		}
		
		override public function addChild(n:Node3D):void 
		{
			if (n.parent)
			{
				n.parent.removeChild(n);
			}
			children.push(n);
		}
		
		override public function removeChild(n:Node3D):void 
		{
			var i:int = children.indexOf(n);
			if (i != -1){
				children.splice(i, 1);
				n.parent = null;
			}
		}
		
	}

}