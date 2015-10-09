package gl3d.parser.fbx {
	public final class FbxProp  {
		
		public var tag : String;
		public var index : int;
		public var params : Array;
		public static const __isenum : Boolean = true;
		public function FbxProp( t : String, index : int, p : Array = null ) : void { this.tag = t; this.index = index; this.params = p; }
		public static function PFloat(v : Number) : FbxProp { return new FbxProp("PFloat",1,[v]); }
		public static function PFloats(v : Array) : FbxProp { return new FbxProp("PFloats",5,[v]); }
		public static function PIdent(i : String) : FbxProp { return new FbxProp("PIdent",3,[i]); }
		public static function PInt(v : int) : FbxProp { return new FbxProp("PInt",0,[v]); }
		public static function PInts(v : Array) : FbxProp { return new FbxProp("PInts",4,[v]); }
		public static function PString(v : String) : FbxProp { return new FbxProp("PString",2,[v]); }
		public static var __constructs__ : Array = ["PInt","PFloat","PString","PIdent","PInts","PFloats"];
	}
}
