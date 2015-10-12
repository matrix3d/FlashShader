package gl3d.parser.fbx {
	public final class FbxToken {
		
		public var tag : String;
		public var index : int;
		public var params : Array;
		public static const __isenum : Boolean = true;
		public function FbxToken( t : String, index : int, p : Array = null ) : void { this.tag = t; this.index = index; this.params = p; }
		public static var TBraceClose : FbxToken = new FbxToken("TBraceClose",7);
		public static var TBraceOpen : FbxToken = new FbxToken("TBraceOpen",6);
		public static var TColon : FbxToken = new FbxToken("TColon",8);
		public static var TEof : FbxToken = new FbxToken("TEof",9);
		public static function TFloat(s : String) : FbxToken { return new FbxToken("TFloat",3,[s]); }
		public static function TIdent(s : String) : FbxToken { return new FbxToken("TIdent",0,[s]); }
		public static function TInt(s : String) : FbxToken { return new FbxToken("TInt",2,[s]); }
		public static function TLength(v : int) : FbxToken { return new FbxToken("TLength",5,[v]); }
		public static function TNode(s : String) : FbxToken { return new FbxToken("TNode",1,[s]); }
		public static function TString(s : String) : FbxToken { return new FbxToken("TString",4,[s]); }
		public static var __constructs__ : Array = ["TIdent","TNode","TInt","TFloat","TString","TLength","TBraceOpen","TBraceClose","TColon","TEof"];
	}
}
