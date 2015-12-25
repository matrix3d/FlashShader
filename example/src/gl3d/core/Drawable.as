package gl3d.core {
	import flash.display3D.Context3D;
	import flash.geom.Vector3D;
	import gl3d.core.renders.GL;
	import gl3d.meshs.Meshs;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Drawable 
	{
		private var _pos:VertexBufferSet;
		private var _norm:VertexBufferSet;
		private var _tangent:VertexBufferSet;
		private var _uv:VertexBufferSet;
		private var _random:VertexBufferSet;
		private var _sphereRandom:VertexBufferSet;
		public var randomStep:int = 4;
		private var _targetPosition:VertexBufferSet;
		public var uv2:VertexBufferSet;
		
		private var _joint:VertexBufferSet;
		private var _weight:VertexBufferSet;
		
		private var _index:IndexBufferSet;
		public var source:DrawableSource;
		
		private var _unpackedDrawable:Drawable;
		public var oldi2newis:Object;
		public var smooting:Boolean = true;
		public function Drawable() 
		{
			
		}
		
		public function get pos():VertexBufferSet 
		{
			if (_pos == null && source && source.pos) {
				if (source.index&&source.uvIndex) {
					index;
				}else{
					_pos = new VertexBufferSet(Vector.<Number>(source.pos), 3);
				}
			}
			return _pos;
		}
		
		public function set pos(value:VertexBufferSet):void 
		{
			_pos = value;
		}
		
		public function get norm():VertexBufferSet 
		{
			if (_norm==null) {
				_norm=Meshs.computeNormal(this);
			}
			return _norm;
		}
		
		public function set norm(value:VertexBufferSet):void 
		{
			_norm = value;
		}
		
		public function get tangent():VertexBufferSet 
		{
			if (_tangent==null) {
				_tangent = Meshs.computeTangent(this);
			}
			return _tangent;
		}
		
		public function set tangent(value:VertexBufferSet):void 
		{
			_tangent = value;
		}
		
		public function get uv():VertexBufferSet 
		{
			if (_uv == null && source && source.uv) {
				if (source.index&&source.uvIndex) {
					index;
				}else{
					_uv = new VertexBufferSet(Vector.<Number>(source.uv), 2);
				}
			}
			if (_uv == null) {
				_uv = Meshs.computeUV(this);
			}
			return _uv;
		}
		
		public function set uv(value:VertexBufferSet):void 
		{
			_uv = value;
		}
		
		public function get random():VertexBufferSet 
		{
			if (_random==null) {
				_random = Meshs.computeRandom(this,randomStep);
			}
			return _random;
		}
		
		public function set random(value:VertexBufferSet):void 
		{
			_random = value;
		}
		
		public function get sphereRandom():VertexBufferSet 
		{
			if (_sphereRandom==null) {
				_sphereRandom = Meshs.computeSphereRandom(this,randomStep);
			}
			return _sphereRandom;
		}
		
		public function set sphereRandom(value:VertexBufferSet):void 
		{
			_sphereRandom = value;
		}
		
		public function get targetPosition():VertexBufferSet 
		{
			if (_targetPosition==null) {
				_targetPosition = Meshs.computeTargetPosition(this);
			}
			return _targetPosition;
		}
		
		public function set targetPosition(value:VertexBufferSet):void 
		{
			_targetPosition = value;
		}
		
		public function get index():IndexBufferSet 
		{
			if (_index == null && source && source.index) {
				if (source.uvIndex != null) {
					var maxI:int = 0;
					oldi2newis = { };
					var oldh2newi:Object = { };
					var sIndex:Array = [];
					var face:Array = null;
					var sPos:Array = [];
					if (source.joint) {
						var sjoint:Array = [];
						var maxWeight:int = 3 * source.joint.length / source.pos.length;
					}
					if (source.weight) {
						var sweight:Array = [];
					}
					
					var sUV:Array = [];
					var len:int = source.index.length;
					for (var i:int = 0; i < len; i++) {
						face = null;
						for (var j:int = 0, len2:int = source.index[i].length; j < len2 ; j++ ) {
							if (face == null) {
								face = [];
								sIndex.push(face);
							}
							var oldI:int = source.index[i][j];
							var oldUVI:int = source.uvIndex[i][j];
							if(smooting){
								var hash:String = oldI + " " + oldUVI;
								var newi:Object = oldh2newi[hash];
							}else {
								newi = null;
							}
							if (newi==null) {
								newi = maxI++;
								sPos.push(source.pos[oldI * 3], source.pos[oldI * 3 + 1], source.pos[oldI * 3 + 2]);
								if (sjoint && sweight) {
									for (var k:int = 0; k < maxWeight;k++ ) {
										sjoint.push(source.joint[oldI * maxWeight+k]);
										sweight.push(source.weight[oldI * maxWeight+k]);
									}
								}
								sUV.push(source.uv[oldUVI * 2], source.uv[oldUVI * 2 + 1]);
								if(smooting){
									oldh2newi[hash] = newi;
									var newis:Array = oldi2newis[oldI];
									if (newis==null) {
										oldi2newis[oldI] = newis = [];
									}
									newis.push(newi);
								}
							}
							face.push(newi);
						}
					}
					
					_pos = new VertexBufferSet(Vector.<Number>(sPos), 3);
					if (sjoint) {
						_joint = new VertexBufferSet(Vector.<Number>(sjoint), maxWeight);
					}
					if (sweight) {
						_weight = new VertexBufferSet(Vector.<Number>(sweight), maxWeight);
					}
					_uv = new VertexBufferSet(Vector.<Number>(sUV), 2);
				}
				
				var sIndex2:Array = [];
				for each(face in sIndex||source.index) {
					len = face.length;
					for (i = 2; i < len;i++ ) {
						sIndex2.push(face[0],face[i-1],face[i]);
					}
				}
				_index = new IndexBufferSet(Vector.<uint>(sIndex2));
			}
			if (_index==null) {
				_index = Meshs.computeIndex(this);
			}
			return _index;
		}
		
		public function set index(value:IndexBufferSet):void 
		{
			_index = value;
		}
		
		public function get unpackedDrawable():Drawable 
		{
			if (_unpackedDrawable == null)_unpackedDrawable = Meshs.unpack(this);
			return _unpackedDrawable;
		}
		
		public function get joint():VertexBufferSet 
		{
			if (_joint == null && source && source.joint) {
				if (source.index&&source.uvIndex) {
					index;
				}else{
					_joint = new VertexBufferSet(Vector.<Number>(source.joint), source.joint.length/(source.pos.length/3));
				}
			}
			return _joint;
		}
		
		public function set joint(value:VertexBufferSet):void 
		{
			_joint = value;
		}
		
		public function get weight():VertexBufferSet 
		{
			if (_weight == null && source && source.weight) {
				if (source.index&&source.uvIndex) {
					index;
				}else{
					_weight = new VertexBufferSet(Vector.<Number>(source.weight), source.weight.length/(source.pos.length/3));
				}
			}
			return _weight;
		}
		
		public function set weight(value:VertexBufferSet):void 
		{
			_weight = value;
		}
		
		/**
		 * 优化source，
		 * 1 根据index把没有用到的 pos，joint等删除，生成新的pos，和index
		 * 2 根据uvindex把没有用到的uv，删除，生成新的uvindex，uv
		 * @param	source
		 */
		public static function optimizeSource(source:DrawableSource):void {
			optimzeSourceIndex(source,false);
			if (source.uvIndex) {
				optimzeSourceIndex(source,true);
			}
		}
		
		private static function optimzeSourceIndex(source:DrawableSource,isUV:Boolean):void {
			var index:Array = isUV?source.uvIndex:source.index;
			var o2n:Object = { };
			var newis:Array = [];
			if (isUV) {
				if (source.uv) {
					var uv:Array = source.uv;
					var newUV:Array = [];
					source.uv = newUV;
				}
				if (source.uv2) {
					var uv2:Array = source.uv2;
					var newUV2:Array = [];
					source.uv2 = newUV2;
				}
				source.uvIndex = newis;
			}else {
				if (source.pos) {
					var pos:Array = source.pos;
					var newPos:Array = [];
					source.pos = newPos;
				}
				if (source.joint) {
					var maxWeight:int = source.joint.length * 3 / pos.length;
					var joint:Array = source.joint;
					var newJoint:Array = [];
					source.joint = newJoint;
				}
				if (source.weight) {
					var weight:Array = source.weight;
					var newWeight:Array = [];
					source.weight = newWeight;
				}
				if (source.color) {
					var color:Array = source.color;
					var newColor:Array = [];
					source.color = newColor;
				}
				if (source.alpha) {
					var alpha:Array = source.alpha;
					var newAlpha:Array = [];
					source.alpha = newAlpha;
				}
				if(source.uvIndex==null){
					if (source.uv) {
						uv = source.uv;
						newUV = [];
						source.uv = newUV;
					}
					if (source.uv2) {
						uv2 = source.uv2;
						newUV2 = [];
						source.uv2 = newUV2;
					}
				}
				source.index = newis;
			}
			var max:int = 0;
			for each(var f:Array in index) {
				var newf:Array = [];
				newis.push(newf);
				for each(var i:int in f){
					var newi:Object = o2n[i];
					if (newi==null) {
						newi = max++;
						o2n[i] = newi;
						if (newPos) {
							newPos.push(pos[3 * i], pos[3 * i + 1], pos[3 * i + 2]);
						}
						if (uv) {
							newUV.push(uv[2 * i], uv[2 * i + 1]);
						}
						if (newColor) {
							newColor.push(color[3 * i], color[3 * i + 1], color[3 * i + 2]);
						}
						if (newAlpha) {
							newAlpha.push(alpha[i]);
						}
						if (newJoint&&newWeight) {
							for (var j:int = 0; j < maxWeight;j++ ) {
								newJoint.push(joint[maxWeight * i + j]);
								newWeight.push(weight[maxWeight * i + j]);
							}
						}
					}
					newf.push(newi);
				}
			}
		}
	}

}