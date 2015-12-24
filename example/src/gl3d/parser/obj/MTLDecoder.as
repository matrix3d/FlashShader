package gl3d.parser.obj 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class MTLDecoder 
	{
		//kd 漫反射
		//map_kd 漫反射贴图
		//ka 
		//ks 镜面反射
		//ns
		//ni
		//d
		//illum
		public var mtls:Array = [];
		public var currentMtl:Object;
		public function MTLDecoder(txt:String) 
		{
			txt = txt.replace(/#.*/g, "");
			var lines:Array = txt.split(/[\r\n]+/g);
			for each(var line:String in lines) {
				var data:Array = line.split(/\s+/);
				if (data[0]=="") {
					data.shift();
				}
				var value:Object = null;
				switch(data[0]) {
					case "newmtl":
						currentMtl = {};
						mtls.push(currentMtl);
						value = data[1];
						break;
					case "map_Kd":
						value = data[1];
						break;
					case "Ka":
					case "Kd":
					case "Ks":
						value = [parseFloat(data[1]), parseFloat(data[2]), parseFloat(data[3])];
						break;
					case "Ni":
					case "d":
						value = parseFloat(data[1]);
						break;
					default:
						value = data[1];
				}
				if (value) {
					currentMtl[data[0]] = value;
				}
			}
		}
		
		public function getmtl(name:String):Object {
			for each(var mtl:Object in mtls) {
				if (mtl.newmtl==name) {
					return mtl;
				}
			}
			return null;
		}
	}

}