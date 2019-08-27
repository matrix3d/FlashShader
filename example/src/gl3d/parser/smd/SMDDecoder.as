package gl3d.parser.smd 
{
	/**
	 * https://developer.valvesoftware.com/wiki/Studiomdl_Data
	 * @author lizhi
	 */
	public class SMDDecoder 
	{
		public var nodes:Array;
		public var skeletons:Array;
		public var triangless:Array;
		public function SMDDecoder(txt:String) 
		{
			txt=txt.replace(/\/\/.*/g,"");
			var lines:Array = txt.split(/[\r\n]+/);
			var result:Object;
			var numJoints:int = 0;
			var i:int;
			 nodes = [];
			 skeletons = [];
			var currTime:Array;
			 triangless = [];
			while(lines.length>0) {
				var line:String = lines.shift();
				if (line=="nodes") {
					while (lines.length>0) {
						line = lines.shift();
						if (line=="end"){
							break;
						}
						result = /\s*(\S+)\s+\"(.+)\"\s+(\S+)\s*/.exec(line);
						nodes.push([parseFloat(result[1]),result[2],parseFloat(result[3])]);
					}
				}else if (line=="skeleton") {
					while (lines.length>0) {
						line = lines.shift();
						if (line=="end"){
							break;
						}
						if ((result = /time (\d+)/.exec(line)) != null){
							currTime = [];
							skeletons[result[1]] = currTime;
						}else if((result = /\s*(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s*/.exec(line))!=null){
							currTime.push([parseInt(result[1]),parseFloat(result[2]),parseFloat(result[3]),parseFloat(result[4]),parseFloat(result[5]),parseFloat(result[6]),parseFloat(result[7])]);
						}
						
					}
				}
				else if (line == "triangles") {
					while (lines.length>0) {
						line = lines.shift();
						if (line=="end"){
							break;
						}
						var ct:Array = [];
						triangless.push(ct);
						ct.push(line);
						for (i = 0; i < 3;i++ ){
							line = lines.shift();
							var vs:Array = (line as String).split(/\s+/g);
							if (vs.length > 10){
								trace(vs.length);
							}
							result = /\s*(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s*/.exec(line);
							ct.push([parseInt(result[1]),parseFloat(result[2]),parseFloat(result[3]),parseFloat(result[4]),parseFloat(result[5]),parseFloat(result[6]),parseFloat(result[7]),parseFloat(result[8]),parseFloat(result[9])]);
						}
					}
				}
			}
		}
	}
}