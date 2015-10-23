package gl3d.parser.md5 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class MD5MeshDecoder 
	{
		public var joints:Array = [];
		public var meshs:Array = [];
		public var maxWeight:int = 0;
		public function MD5MeshDecoder(txt:String) 
		{
			txt=txt.replace(/\/\/.*/g,"");
			var lines:Array = txt.split(/[\r\n]+/);
			var result:Object;
			var numJoints:int = 0;
			var i:int;
			while(lines.length>0) {
				var line:String = lines.shift();
				if ((result= /MD5Version (\d+)/.exec(line))!=null) {
				}else if ((result=/numJoints (\d+)/.exec(line))!=null) {
					numJoints = parseInt(result[1]);
				}else if ((result =/numMeshes (\d+)/.exec(line))!=null) {
				}else if ((result=/joints {/.exec(line))) {
					for (i = 0; i < numJoints;i++ ) {
						line = lines.shift();
						((result = /"(.+)"\s+(-?\d+).*\(\s*(\S+)\s+(\S+)\s+(\S+)\s*\).*\(\s*(\S+)\s+(\S+)\s+(\S+)\s*\)/.exec(line))!=null)
						joints.push([result[1], parseInt(result[2]), parseFloat(result[3]), parseFloat(result[4]), parseFloat(result[5]), parseFloat(result[6]), parseFloat(result[7]), parseFloat(result[8])]);
					}
				}else if ((result =/mesh {/.exec(line))!=null) {
					var mesh:Object = { };
					mesh.vs = [];
					mesh.vs2 = [];
					mesh.ins = [];
					mesh.weights = [];
					meshs.push(mesh);
					while (lines.length>0) {
						line = lines.shift();
						if (line.charAt(0) == "}") break;
						if ((result =/shader\s+"(.+)"/.exec(line))!=null) {
						}else if ((result =/numverts (\d+)/.exec(line))!=null) {
						}else if ((result =/numtris (\d+)/.exec(line))!=null) {
						}else if ((result =/numweights (\d+)/.exec(line))!=null) {
						}else if ((result =/vert\s+(\d+)\s*\(\s*(\S+)\s+(\S+)\s*\)\s+(\d+)\s+(\d+)/.exec(line)) != null) {
							var count:int = parseInt(result[5]);
							if (count>maxWeight) {
								maxWeight = count;
							}
							mesh.vs2[parseInt(result[1])] = [parseFloat(result[2]), parseFloat(result[3]),parseInt(result[4]),count];
						}else if ((result =/vert\s+(\d+)\s*\(\s*(\S+)\s+(\S+)\s*\)\s+(\S+)\s+(\S+)\s+(\S+)/.exec(line))!=null) {
							mesh.vs[parseInt(result[1])] = [parseFloat(result[2]), parseFloat(result[3]), parseFloat(result[4]), parseFloat(result[5]), parseFloat(result[6])];
						}else if ((result =/tri\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/.exec(line))) {
							mesh.ins[parseInt(result[1])] = [parseInt(result[2]), parseInt(result[3]), parseInt(result[4]) ];
						}else if ((result =/weight\s+(\d+)\s+(\d+)\s+(\S+)\s*\(\s*(\S+)\s+(\S+)\s+(\S+)\s*\)/.exec(line))!=null) {
							mesh.weights[parseInt(result[1])] = [parseInt(result[2]), parseFloat(result[3]),parseFloat(result[4]), parseFloat(result[5]),parseFloat(result[6])];
						}
					}
				}
			}
		}
	}
}