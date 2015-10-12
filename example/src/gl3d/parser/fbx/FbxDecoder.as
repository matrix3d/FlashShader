package gl3d.parser.fbx {
	import gl3d.parser.fbx.FbxProp;
	import gl3d.parser.fbx.FbxToken;
	public class FbxDecoder {
		public var obj:Object;
		
		public function FbxDecoder(txt:String) : void {
			obj=parseText(txt);
		}
		
		public var line : int;
		public var buf : String;
		public var pos : int;
		protected var token : gl3d.parser.fbx.FbxToken;
		public function parseText(str : String) : * {
			this.buf = str;
			this.pos = 0;
			this.line = 1;
			this.token = null;
			return { name : "Root", props : [gl3d.parser.fbx.FbxProp.PInt(0),gl3d.parser.fbx.FbxProp.PString("Root"),gl3d.parser.fbx.FbxProp.PString("Root")], childs : this.parseNodes()}
		}
		
		protected function parseNodes() : Array {
			var nodes : Array = [];
			while(true) {
				{
					var _g : gl3d.parser.fbx.FbxToken = this.peek();
					switch(_g.index) {
					case 9:case 7:
					return nodes;
					break;
					default:
					break;
					}
				};
				nodes.push(this.parseNode());
			};
			return nodes;
		}
		
		protected function parseNode() : * {
			var t : gl3d.parser.fbx.FbxToken = this.next();
			var name : String;
			switch(t.index) {
			case 1:
			{
				var n : String = t.params[0];
				name = n;
			}
			break;
			default:
			name = this.unexpected(t);
			break;
			};
			var props : Array = [];
			var childs : Array = null;
			try {
				while(true) {
					t = this.next();
					switch(t.index) {
					case 3:
					{
						var s : String = t.params[0];
						props.push(gl3d.parser.fbx.FbxProp.PFloat(parseFloat(s)));
					}
					break;
					case 2:
					{
						var s1 : String = t.params[0];
						props.push(gl3d.parser.fbx.FbxProp.PInt(parseInt(s1)));
					}
					break;
					case 4:
					{
						var s2 : String = t.params[0];
						props.push(gl3d.parser.fbx.FbxProp.PString(s2));
					}
					break;
					case 0:
					{
						var s3 : String = t.params[0];
						props.push(gl3d.parser.fbx.FbxProp.PIdent(s3));
					}
					break;
					case 6:case 7:
					this.token = t;
					break;
					case 5:
					{
						var v : int = t.params[0];
						{
							this.except(gl3d.parser.fbx.FbxToken.TBraceOpen);
							this.except(gl3d.parser.fbx.FbxToken.TNode("a"));
							var ints : Array = [];
							var floats : Array = null;
							var i : int = 0;
							while(i < v) {
								t = this.next();
								switch(t.index) {
								case 8:
								continue;
								break;
								case 2:
								{
									var s4 : String = t.params[0];
									{
										i++;
										if(floats == null) ints.push(parseInt(s4));
										else floats.push(parseInt(s4));
									}
								}
								break;
								case 3:
								{
									var s5 : String = t.params[0];
									{
										i++;
										if(floats == null) {
											floats = [];
											{
												var _g : int = 0;
												while(_g < ints.length) {
													var i1 : * = ints[_g];
													++_g;
													floats.push(i1);
												}
											};
											ints = null;
										};
										floats.push(parseFloat(s5));
									}
								}
								break;
								default:
								this.unexpected(t);
								break;
								}
							};
							props.push(((floats == null)?gl3d.parser.fbx.FbxProp.PInts(ints):gl3d.parser.fbx.FbxProp.PFloats(floats)));
							this.except(gl3d.parser.fbx.FbxToken.TBraceClose);
							throw "__break__";
						}
					}
					break;
					default:
					this.unexpected(t);
					break;
					};
					t = this.next();
					switch(t.index) {
					case 1:case 7:
					{
						this.token = t;
						throw "__break__";
					}
					break;
					case 8:
					break;
					case 6:
					{
						childs = this.parseNodes();
						this.except(gl3d.parser.fbx.FbxToken.TBraceClose);
						throw "__break__";
					}
					break;
					default:
					this.unexpected(t);
					break;
					}
				}
			} catch( e : * ) { if( e != "__break__" ) throw e; };
			if(childs == null) childs = [];
			return { name : name, props : props, childs : childs}
		}
		
		protected function except(except : gl3d.parser.fbx.FbxToken) : void {
			var t : gl3d.parser.fbx.FbxToken = this.next();
			if(!enumEq(t,except)) this.error("Unexpected '" + this.tokenStr(t) + "' (" + this.tokenStr(except) + " expected)");
		}
		static public function enumEq(a : *,b : *) : Boolean {
			if(a == b) return true;
			try {
				if(a.index != b.index) return false;
				var ap : Array = a.params;
				var bp : Array = b.params;
				{
					var _g1 : int = 0;
					var _g : int = ap.length;
					while(_g1 < _g) {
						var i : int = _g1++;
						if(!enumEq(ap[i],bp[i])) return false;
					}
				}
			}
			catch( e : * ){
				return false;
			};
			return true;
		}
		
		protected function peek() : gl3d.parser.fbx.FbxToken {
			if(this.token == null) this.token = this.nextToken();
			return this.token;
		}
		
		protected function next() : gl3d.parser.fbx.FbxToken {
			if(this.token == null) return this.nextToken();
			var tmp : gl3d.parser.fbx.FbxToken = this.token;
			this.token = null;
			return tmp;
		}
		
		protected function error(msg : String) : * {
			throw msg + " (line " + this.line + ")";
			return null;
		}
		
		protected function unexpected(t : gl3d.parser.fbx.FbxToken) : * {
			return this.error("Unexpected " + this.tokenStr(t));
		}
		
		protected function tokenStr(t : gl3d.parser.fbx.FbxToken) : String {
			switch(t.index) {
			case 9:
			return "<eof>";
			break;
			case 6:
			return "{";
			break;
			case 7:
			return "}";
			break;
			case 0:
			{
				var i : String = t.params[0];
				return i;
			}
			break;
			case 1:
			{
				var i1 : String = t.params[0];
				return i1 + ":";
			}
			break;
			case 3:
			{
				var f : String = t.params[0];
				return f;
			}
			break;
			case 2:
			{
				var i2 : String = t.params[0];
				return i2;
			}
			break;
			case 4:
			{
				var s : String = t.params[0];
				return "\"" + s + "\"";
			}
			break;
			case 8:
			return ",";
			break;
			case 5:
			{
				var l : int = t.params[0];
				return "*" + l;
			}
			break;
			};
			return null;
		}
		
		protected function nextChar() : int {
			return this.buf.charCodeAt(this.pos++);
		}
		
		protected function getBuf(pos : int,len : int) : String {
			return this.buf.substr(pos,len);
		}
		
		protected function isIdentChar(c : int) : Boolean {
			return c >= 97 && c <= 122 || c >= 65 && c <= 90 || c >= 48 && c <= 57 || c == 95 || c == 45;
		}
		
		protected function nextToken() : gl3d.parser.fbx.FbxToken {
			var start : int = this.pos;
			while(true) {
				var c : int = this.nextChar();
				switch(c) {
				case 32:case 13:case 9:
				start++;
				break;
				case 10:
				{
					this.line++;
					start++;
				}
				break;
				case 59:
				{
					while(true) {
						var c1 : int = this.nextChar();
						if(c1==0 || c1 == 10) {
							this.pos--;
							break;
						}
					};
					start = this.pos;
				}
				break;
				case 44:
				return gl3d.parser.fbx.FbxToken.TColon;
				break;
				case 123:
				return gl3d.parser.fbx.FbxToken.TBraceOpen;
				break;
				case 125:
				return gl3d.parser.fbx.FbxToken.TBraceClose;
				break;
				case 34:
				{
					start = this.pos;
					while(true) {
						c = this.nextChar();
						if(c == 34) break;
						if(c==0 || c == 10) this.error("Unclosed string");
					};
					return gl3d.parser.fbx.FbxToken.TString(this.getBuf(start,this.pos - start - 1));
				}
				break;
				case 42:
				{
					start = this.pos;
					do c = this.nextChar() while(c >= 48 && c <= 57);
					this.pos--;
					return gl3d.parser.fbx.FbxToken.TLength(parseInt(this.getBuf(start,this.pos - start)));
				}
				break;
				default:
				{
					if(c >= 97 && c <= 122 || c >= 65 && c <= 90 || c == 95) {
						do c = this.nextChar() while(this.isIdentChar(c));
						if(c == 58) return gl3d.parser.fbx.FbxToken.TNode(this.getBuf(start,this.pos - start - 1));
						this.pos--;
						return gl3d.parser.fbx.FbxToken.TIdent(this.getBuf(start,this.pos - start));
					};
					if(c >= 48 && c <= 57 || c == 45) {
						do c = this.nextChar() while(c >= 48 && c <= 57);
						if(c != 46 && c != 69 && c != 101 && this.pos - start < 10) {
							this.pos--;
							return gl3d.parser.fbx.FbxToken.TInt(this.getBuf(start,this.pos - start));
						};
						if(c == 46) do c = this.nextChar() while(c >= 48 && c <= 57);
						if(c == 101 || c == 69) {
							c = this.nextChar();
							if(c != 45 && c != 43) this.pos--;
							do c = this.nextChar() while(c >= 48 && c <= 57);
						};
						this.pos--;
						return gl3d.parser.fbx.FbxToken.TFloat(this.getBuf(start,this.pos - start));
					};
					if(c == 0) {
						this.pos--;
						return gl3d.parser.fbx.FbxToken.TEof;
					};
					this.error("Unexpected char '" + String.fromCharCode(c) + "'");
				}
				break;
				}
			};
			return null;
		}
		
	}
}
