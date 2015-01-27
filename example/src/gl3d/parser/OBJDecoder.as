package gl3d.parser 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class OBJDecoder 
	{
		public var mtllibs:Array = [];
		public var objs:Array = [];
		public var vs:Array = [];
		public var vts:Array = [];
		public var vns:Array = [];
		
		private var currentObj:Object;
		private var currentGroup:Object;
		public function OBJDecoder(txt:String) 
		{
			txt = txt.replace(/#.*/g, "");
			var lines:Array = txt.split(/[\r\n]+/g);
			for each(var line:String in lines) {
				var data:Array = line.split(/\s+/);
				switch(data[0]) {
					case "mtllib":
						mtllibs.push(data[1]);
						break;
					case "usemtl":
						if (currentGroup==null) {
							currentGroup = createGroup();
						}
						currentGroup.mtl = data[1];
						break;
					case "o":
						currentGroup = null;
						currentObj = createObj();
						currentObj.name = data[1];
						break;
					case "g":
						currentGroup = createGroup();
						currentGroup.name = data[1];
						break;
					case "s":
						if (currentGroup == null) {
							currentGroup = createGroup();
						}
						currentGroup.s = data[1] != "off";
						break;
					case "v":
						pushVert(vs, data);
						break;
					case "vt":
						pushVert(vts, data);
						break;
					case "vn":
						pushVert(vns, data);
						break;
					case "f":
						if (currentGroup==null) {
							currentGroup = createGroup();
						}
						var idata:Array = [];
						for (var i:int = 1,len:int=data.length; i < len;i++ ) {
							var inss:Array = data[i].split("/");
							var idatap:Array = [];
							idata.push(idatap);
							for (var j:int = 0, jlen:int = inss.length; j < jlen;j++ ) {
								idatap.push(parseInt(inss[j])-1);
							}
						}
						currentGroup.f.push(idata);
						break;
				}
			}
		}
		
		private function pushVert(arr:Array,data:Array):void {
			arr.push(parseFloat(data[1]),parseFloat(data[2]),parseFloat(data[3]));
		}
		
		private function createObj():Object {
			var obj:Object = { };
			obj.g = [];
			objs.push(obj);
			return obj;
		}
		
		private function createGroup():Object {
			var group:Object = { };
			group.f = [];
			group.s = true;
			if (currentObj==null) {
				currentObj = createObj();
			}
			currentObj.g.push(group);
			return group;
		}
	}
}