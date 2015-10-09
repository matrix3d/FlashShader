package gl3d.parser.fbx {
	public final class Token {
		
		public var tag : String;
		public var index : int;
		public var params : Array;
		public static const __isenum : Boolean = true;
		public function Token( t : String, index : int, p : Array = null ) : void { this.tag = t; this.index = index; this.params = p; }
		public static var TBraceClose : Token = new Token("TBraceClose",7);
		public static var TBraceOpen : Token = new Token("TBraceOpen",6);
		public static var TColon : Token = new Token("TColon",8);
		public static var TEof : Token = new Token("TEof",9);
		public static function TFloat(s : String) : Token { return new Token("TFloat",3,[s]); }
		public static function TIdent(s : String) : Token { return new Token("TIdent",0,[s]); }
		public static function TInt(s : String) : Token { return new Token("TInt",2,[s]); }
		public static function TLength(v : int) : Token { return new Token("TLength",5,[v]); }
		public static function TNode(s : String) : Token { return new Token("TNode",1,[s]); }
		public static function TString(s : String) : Token { return new Token("TString",4,[s]); }
		public static var __constructs__ : Array = ["TIdent","TNode","TInt","TFloat","TString","TLength","TBraceOpen","TBraceClose","TColon","TEof"];
	}
}
