package gl3d.parser.fbx {
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
		
		static public function getInts(n : * ) : Array {
			return n.props[0];
		}
		
		static public function getFloats(n : * ) : Array {
			return n.props[0];
		}
		
		static public function getId(n : * ) : String {
			return String(n.props[0]);
		}
		
		static public function getName(n : * ) : String {
			var n1:String = String(n.props[n.props.length - 2]);
			if(n1)n1= n1.split("::").pop();
			if(n1)n1= n1.split(":").pop();
			return n1;
		}
		
		static public function getType(n : * ) : String {
			return String(n.props[n.props.length-1]);
		}
		
	}
}
