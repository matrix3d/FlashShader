package gl3d.parser.fnt 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class FntDecoder 
	{
		public var common:Object;
		public var chars:Object = {};
		public function FntDecoder(txt:String) 
		{
			var lines:Array = txt.split(/[\r\n]+/g);
			for each(var line:String in lines){
				var data:Array = line.split(/\s+/);
				var obj:Object = {};
				for (var i:int = 1; i < data.length;i++ ){
					var a:Array = data[i].split("=");
					if (a[1]){
						obj[a[0]] = int(a[1]);
					}
				}
				switch(data[0]){
					case "char":
						chars[String.fromCharCode(obj.id)]=obj;
						break;
					case "common":
						common = obj;
				}
			}
		}
		
	}

}