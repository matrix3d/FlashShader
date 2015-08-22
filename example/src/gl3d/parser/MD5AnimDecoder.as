package gl3d.parser 
{
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	/**
	 * ...
	 * @author lizhi
	 */
	public class MD5AnimDecoder 
	{
		public var frameRate:int = 60;
		public var jointInfos:Array = [];
		public var baseFrameJoints:Array = [];
		public var components:Array = [];
		public function MD5AnimDecoder(txt:String) 
		{
			txt= txt.replace(/\/\/.*/g,"");
			var lines:Array = txt.split(/[\r\n]+/g);
			var result:Object;
			var numJoints:int = 0;
			var numFrames:int = 0;
			var numAnimatedComponents:int = 0;
			var i:int;
			while(lines.length>0) {
				var line:String = lines.shift();
				if ((result= /MD5Version (\d+)/.exec(line))!=null) {
				}else if ((result = /numFrames (\d+)/.exec(line))) {
					numFrames = parseInt(result[1]);
				}else if ((result = /numJoints (\d+)/.exec(line))) {
					numJoints = parseInt(result[1]);
				}else if ((result = /frameRate (\d+)/.exec(line))) {
					frameRate = parseInt(result[1]);
				}else if ((result =/numAnimatedComponents (\d+)/.exec(line))) {
					numAnimatedComponents = parseInt(result[1]);
				}else if ((result=/hierarchy {/.exec(line))) {
					for (i = 0; i < numJoints;i++ ) {
						line = lines.shift();
						(result = /"(.+)"\s+(\S+)\s+(\S+)\s+(\S+)/.exec(line));
						var info:Array = [result[1],parseInt(result[2]),parseInt(result[3]),parseInt(result[4])];
						jointInfos.push(info);
					}
				}else if ((result=/bounds {/.exec(line))) {
					for (i = 0; i < numFrames;i++ ) {
						line = lines.shift();
						(result = /\(\s*(\S+)\s+(\S+)\s+(\S+)\s*\)\s*\(\s*(\S+)\s+(\S+)\s+(\S+)\s*\)/.exec(line));
					}
				}else if ((result=/baseframe {/.exec(line))) {
					for (i = 0; i < numJoints;i++ ) {
						line = lines.shift();
						(result = /\(\s*(\S+)\s+(\S+)\s+(\S+)\s*\)\s*\(\s*(\S+)\s+(\S+)\s+(\S+)\s*\)/.exec(line));
						var baseFrame:Array=[parseFloat(result[1]),parseFloat(result[2]), parseFloat(result[3]),parseFloat(result[4]), parseFloat(result[5]), parseFloat(result[6])];
						baseFrameJoints.push(baseFrame);
					}
				}else if ((result = /frame (\d+)/.exec(line))) {
					var fsValue:Array = [];
					components[parseInt(result[1])]=fsValue;
					i = 0;
					while(i<numAnimatedComponents) {
						line = lines.shift();
						var fs:Array = line.split(/\s+/g);
						while (fs.length > 0) {
							var f:String = fs.shift();
							if (f!="") {
								fsValue.push(parseFloat(f));
								i++;
							}
						}
					}
				}
			}
		}
	}

}