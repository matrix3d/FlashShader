package  
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author lizhi
	 */
	public class CodeCreator extends Sprite
	{
		
		public function CodeCreator() 
		{
			var ops:Array= ["mov","add","sub","mul","div","rcp","min","max","frc","sqt","rsq","pow","log","exp","nrm","sin","cos","crs","dp3","dp4","abs","neg","sat","m33","m44","m34","ddx","ddy","ife","ine","ifg","ifl","els","eif","ted","kil","tex","sge","slt","sgn","seq","sne"]
			for each(var op:String in ops) {
				trace(op);
			}
		}
		
	}

}