package gl3d.parser.fbx {
	import gl3d.parser.fbx.FbxProp;
	public class FbxTools {
		static public function get(n : *,path : String,opt : Boolean = false) : * {
			var parts : Array = path.split(".");
			var cur : * = n;
			{
				var _g : int = 0;
				while(_g < parts.length) {
					var p : String = parts[_g];
					++_g;
					var found : Boolean = false;
					{
						var _g1 : int = 0;
						var _g2 : Array = cur.childs;
						while(_g1 < _g2.length) {
							var c : * = _g2[_g1];
							++_g1;
							if(c.name == p) {
								cur = c;
								found = true;
								break;
							}
						}
					};
					if(!found) {
						if(opt) return null;
						throw n.name + " does not have " + path + " (" + p + " not found)";
					}
				}
			};
			return cur;
		}
		
		static public function getAll(n : *,path : String) : Array {
			var parts : Array = path.split(".");
			var cur : Array = [n];
			{
				var _g : int = 0;
				while(_g < parts.length) {
					var p : String = parts[_g];
					++_g;
					var out : Array = [];
					{
						var _g1 : int = 0;
						while(_g1 < cur.length) {
							var n1 : * = cur[_g1];
							++_g1;
							var _g2 : int = 0;
							var _g3 : Array = n1.childs;
							while(_g2 < _g3.length) {
								var c : * = _g3[_g2];
								++_g2;
								if(c.name == p) out.push(c);
							}
						}
					};
					cur = out;
					if(cur.length == 0) return cur;
				}
			};
			return cur;
		}
		
		static public function getInts(n : *) : Array {
			if(n.props.length != 1) throw n.name + " has " + String(n.props) + " props";
			{
				var _g : gl3d.parser.fbx.FbxProp = n.props[0];
				switch(_g.index) {
				case 4:
				{
					var v : Array = _g.params[0];
					return v;
				}
				break;
				default:
				throw n.name + " has " + String(n.props) + " props";
				break;
				}
			};
			return null;
		}
		
		static public function props2array(n:*):Array {
			var arr:Array = [];
			for each(var p:Object in n.props) {
				arr.push(p.params[0]);
			}
			return arr;
		}
		
		static public function getFloats(n : *) : Array {
			if(n.props.length != 1) throw n.name + " has " + String(n.props) + " props";
			{
				var _g : gl3d.parser.fbx.FbxProp = n.props[0];
				switch(_g.index) {
				case 5:
				{
					var v : Array = _g.params[0];
					return v;
				}
				break;
				case 4:
				{
					var i : Array = _g.params[0];
					{
						var fl : Array = new Array();
						{
							var _g1 : int = 0;
							while(_g1 < i.length) {
								var x : int = i[_g1];
								++_g1;
								fl.push(x);
							}
						};
						n.props[0] = gl3d.parser.fbx.FbxProp.PFloats(fl);
						return fl;
					}
				}
				break;
				default:
				throw n.name + " has " + String(n.props) + " props";
				break;
				}
			};
			return null;
		}
		
		static public function hasProp(n : *,p : gl3d.parser.fbx.FbxProp) : Boolean {
			{
				var _g : int = 0;
				var _g1 : Array = n.props;
				while(_g < _g1.length) {
					var p2 : gl3d.parser.fbx.FbxProp = _g1[_g];
					++_g;
					if(FbxDecoder.enumEq(p,p2)) return true;
				}
			};
			return false;
		}
		
		static protected function idToInt(f : Number) : int {
			return int(f);
		}
		
		static public function toInt(n : gl3d.parser.fbx.FbxProp) : int {
			if(n == null) throw "null prop";
			switch(n.index) {
			case 0:
			{
				var v : int = n.params[0];
				return v;
			}
			break;
			case 1:
			{
				var f : Number = n.params[0];
				return FbxTools.idToInt(f);
			}
			break;
			default:
			throw "Invalid prop " + String(n);
			break;
			};
			return 0;
		}
		
		static public function toFloat(n : gl3d.parser.fbx.FbxProp) : Number {
			if(n == null) throw "null prop";
			switch(n.index) {
			case 0:
			{
				var v : int = n.params[0];
				return v * 1.0;
			}
			break;
			case 1:
			{
				var v1 : Number = n.params[0];
				return v1;
			}
			break;
			default:
			throw "Invalid prop " + String(n);
			break;
			};
			return 0.;
		}
		
		static public function toString(n : gl3d.parser.fbx.FbxProp) : String {
			if(n == null) throw "null prop";
			switch(n.index) {
			case 2:
			{
				var v : String = n.params[0];
				return v;
			}
			break;
			default:
			throw "Invalid prop " + String(n);
			break;
			};
			return null;
		}
		
		static public function getId(n : *) : String {
			//if(n.props.length != 3) throw n.name + " is not an object";
			//{
				var _g : gl3d.parser.fbx.FbxProp = n.props[0];
				if(_g){
				switch(_g.index) {
				case 0:
				case 1:
				case 2:
				{
					return String(_g.params[0]);
				}
				break;
				default:
				throw n.name + " is not an object " + String(n.props);
				break;
				}
				}
			//};
			return "";
		}
		
		static public function getName(n : *) : String {
			//if(n.props.length != 3) throw n.name + " is not an object";
			//{
				var _g : gl3d.parser.fbx.FbxProp = n.props[n.props.length-2];
				switch(_g.index) {
				case 2:
				{
					var n1 : String = _g.params[0];
					return n1.split("::").pop();
				}
				break;
				default:
				throw n.name + " is not an object";
				break;
				}
			//};
			return null;
		}
		
		static public function getType(n : *) : String {
			//if(n.props.length != 3) throw n.name + " is not an object";
			//{
				var _g : gl3d.parser.fbx.FbxProp = n.props[n.props.length-1];
				if(_g){
				switch(_g.index) {
				case 2:
				{
					var n1 : String = _g.params[0];
					return n1;
				}
				break;
				default:
				throw n.name + " is not an object";
				break;
				}
				}
			//};
			return null;
		}
		
	}
}
