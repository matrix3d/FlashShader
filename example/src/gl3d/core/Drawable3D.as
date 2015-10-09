package gl3d.core {
	import flash.display3D.Context3D;
	import flash.geom.Vector3D;
	import gl3d.core.renders.GL;
	import gl3d.meshs.Meshs;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Drawable3D 
	{
		private var _pos:VertexBufferSet;
		private var _norm:VertexBufferSet;
		private var _tangent:VertexBufferSet;
		private var _uv:VertexBufferSet;
		private var _random:VertexBufferSet;
		private var _sphereRandom:VertexBufferSet;
		public var randomStep:int = 4;
		private var _targetPosition:VertexBufferSet;
		public var lightmapUV:VertexBufferSet;
		
		public var joints:VertexBufferSet;
		//public var quatJoints:VertexBufferSet;
		public var weights:VertexBufferSet;
		
		private var _index:IndexBufferSet;
		public var id2index:Object = { };
		public var oldIndex2NewIndexs:Array = [];
		
		private var _unpackedDrawable:Drawable3D;
		public function Drawable3D() 
		{
			
		}
		
		//public function update(context:GL):void 
		//{
			/*if (pos) {
				pos.update(context);
			}if (norm) {
				norm.update(context);
			}if (uv) {
				uv.update(context);
			}if (tangent) {
				tangent.update(context);
			}if (random) {
				random.update(context);
			}*/
			/*if (index) {
				index.update(context);
			}*/
		//}
		
		public function get pos():VertexBufferSet 
		{
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
			if (_index==null) {
				_index = Meshs.computeIndex(this);
			}
			return _index;
		}
		
		public function set index(value:IndexBufferSet):void 
		{
			_index = value;
		}
		
		public function get unpackedDrawable():Drawable3D 
		{
			if (_unpackedDrawable == null)_unpackedDrawable = Meshs.unpack(this);
			return _unpackedDrawable;
		}
		
		public function addVertex(posV:Array, uvV:Array,oldIndex:int=-1,hashAdder:String=""):int {
			var id:String = posV + ":" + uvV+hashAdder;
			if (id2index[id]==null) {
				var indexV:int = pos.data.length / 3;
				pos.data.push(posV[0], posV[1], posV[2]);
				uv.data.push(uvV[0], uvV[1]);
				id2index[id] = indexV;
				if (oldIndex!=-1) {
					if (oldIndex2NewIndexs[oldIndex]==null) {
						oldIndex2NewIndexs[oldIndex] = [];
					}
					oldIndex2NewIndexs[oldIndex].push(indexV);
				}
			}else {
				indexV=id2index[id] as int;
			}
			index.data.push(indexV);
			return indexV;
		}
		
		public function addVertex2(posV:Array, uvV:Array, indexV:int):void {
			if (pos.data.length<(indexV+1)*3) {
				pos.data.length = (indexV+1) * 3;
			}
			if (uv.data.length<(indexV+1)*2) {
				uv.data.length = (indexV+1) * 2;
			}
			pos.data[indexV * 3 + 0] = posV[0];
			pos.data[indexV * 3 + 1] = posV[1];
			pos.data[indexV * 3 + 2] = posV[2];
			uv.data[indexV * 2 + 0] = uvV[0];
			uv.data[indexV * 2 + 1] = uvV[1];
			index.data.push(indexV);
		}
	}

}