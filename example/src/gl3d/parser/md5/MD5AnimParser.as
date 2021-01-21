package gl3d.parser.md5 
{
	import flash.geom.Matrix3D;
	import gl3d.core.math.Quaternion;
	import gl3d.core.skin.Joint;
	import gl3d.core.skin.Skin;
	import gl3d.core.skin.SkinAnimation;
	import gl3d.core.skin.SkinAnimationCtrl;
	import gl3d.core.skin.Track;
	import gl3d.core.skin.TrackFrame;
	import gl3d.ctrl.Ctrl;
	import gl3d.parser.md5.MD5AnimDecoder;
	import gl3d.util.Converter;
	/**
	 * ...
	 * @author lizhi
	 */
	public class MD5AnimParser 
	{
		public var anim:SkinAnimation
		private var jointMap:Object = {};
		public function MD5AnimParser(txt:String,md5:MD5MeshParser) 
		{
			for each(var jo:Joint in md5.skin.joints){
				jointMap[jo.name] = jo;
			}
			
			var converter:Converter=new Converter(Converter.ZtoY);
			var decoder:MD5AnimDecoder = new MD5AnimDecoder(txt);
			anim = new SkinAnimation();
			if (md5.animc==null) {
				md5.target.controllers = new Vector.<Ctrl>;
				md5.animc = new SkinAnimationCtrl;
				md5.target.controllers.push(md5.animc);
			}
			md5.animc.add(anim);
			anim.maxTime = decoder.components.length / decoder.frameRate;
			anim.targets = md5.skinNodes;
			var q:Quaternion = new Quaternion;
			for (var i:int = 0; i < decoder.components.length; i++ ) {//多少帧
				var component:Array = decoder.components[i];
				for (var j:int = 0; j < decoder.jointInfos.length; j++ ) {
					var info:Array = decoder.jointInfos[j];
					var jname:String = info[0];
					if (anim.tracks[jname] == null) {//第一帧找到joint
						var target:Joint = jointMap[jname];
						if (target==null){
							continue;
						}
						var track:Track = new Track;
						anim.tracks[jname]=track;
						track.target = target;
					}
					track = anim.tracks[jname];
					var baseframe:Array = decoder.baseFrameJoints[j];
					q.tran.x = baseframe[0];
					q.tran.y = baseframe[1];
					q.tran.z = baseframe[2];
					q.x=baseframe[3]
					q.y=baseframe[4]
					q.z=baseframe[5]
					var index:int = info[3];
					if (info[2]&1) {
						q.tran.x = component[index++];
					}
					if (info[2]&2) {
						q.tran.y = component[index++];
					}
					if (info[2]&4) {
						q.tran.z = component[index++];
					}
					if (info[2]&8) {
						q.x = component[index++];
					}
					if (info[2]&16) {
						q.y = component[index++];
					}
					if (info[2]&32) {
						q.z = component[index++];
					}
					q.computeW();
					var frame:TrackFrame = new TrackFrame;
					frame.matrix = converter.getConvertedMat4(q.toMatrix());
					track.frames.push(frame);
					frame.time = i/decoder.frameRate;
				}
			}
		}
		
	}

}