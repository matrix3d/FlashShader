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
	}

}