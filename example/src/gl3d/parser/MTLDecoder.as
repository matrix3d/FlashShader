package gl3d.parser 
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
		public var currentMtl:Array;
		public function MTLDecoder(txt:String) 
		{
			txt = txt.replace(/#.*/g, "");
			var lines:Array = txt.split(/[\r\n]+/g);
			for each(var line:String in lines) {
				var data:Array = line.split(/\s+/);
				if (data[0]=="") {
					data.shift();
				}
				switch(data[0]) {
					case "newmtl":
						currentMtl = [];
						mtls.push(currentMtl);
						currentMtl[0]=data[1];
						break;
					case "map_Kd":
						var mapkd:String = data[1];
						currentMtl[1] = mapkd;
						mapkd = mapkd.slice(mapkd.lastIndexOf("\\") + 1, mapkd.lastIndexOf("."));
						currentMtl[2] = mapkd;
						break;
					case "Kd":
						currentMtl[3] = [parseFloat(data[1]), parseFloat(data[2]), parseFloat(data[3])];
				}
			}
		}
		
		public function getmtl(name:String):Array {
			for each(var mtl:Array in mtls) {
				if (mtl[0]==name) {
					return mtl;
				}
			}
			return null;
		}
	}

}