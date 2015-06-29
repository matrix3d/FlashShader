package as3Shader {
	/**
	 * ...
	 * @author lizhi
	 */
	public class Var 
	{
		public static const TYPE_C:int = 1;
		public static const TYPE_T:int = 2;
		public static const TYPE_VA:int = 3;
		public static const TYPE_V:int = 4;
		public static const TYPE_FS:int = 5;
		public static const TYPE_OC:int = 6;
		public static const TYPE_OP:int = 7;
		
		public var index:int;
		public var type:int;
		public var component:Object;
		public var componentOffset:int;
		
		public var data:Object;
		public var constLenght:int = 1;
		public var used:Boolean = false;
		public function Var(type:int,index:int=0) {
			this.type = type;
			this.index = index;
		}
		public function c(value:Object,offset:int=0):Var {
			var v:Var = new Var(type, index);
			if (component) {
				if (component is String&&value is String) {
					var v0:String = value as String;
					var v1:String = component as String;
					var value2:String = "";
					for (var i:int = 0; i < v0.length;i++ ) {
						value2 += v1.charAt((v0.charCodeAt(i)-"x".charCodeAt(0))%v1.length);
					}
					value = value2;
				}else {
					throw "error";
				}
			}
			v.component = value;
			v.componentOffset = offset;
			v.constLenght = constLenght;
			return v;
		}
		
		public function toString():String {
			return [type, index] + "";
		}
		public function get x():Var {return c("x");}
public function get xx():Var {return c("xx");}
public function get xxx():Var {return c("xxx");}
public function get xxxx():Var {return c("xxxx");}
public function get xxxy():Var {return c("xxxy");}
public function get xxxz():Var {return c("xxxz");}
public function get xxxw():Var {return c("xxxw");}
public function get xxy():Var {return c("xxy");}
public function get xxyx():Var {return c("xxyx");}
public function get xxyy():Var {return c("xxyy");}
public function get xxyz():Var {return c("xxyz");}
public function get xxyw():Var {return c("xxyw");}
public function get xxz():Var {return c("xxz");}
public function get xxzx():Var {return c("xxzx");}
public function get xxzy():Var {return c("xxzy");}
public function get xxzz():Var {return c("xxzz");}
public function get xxzw():Var {return c("xxzw");}
public function get xxw():Var {return c("xxw");}
public function get xxwx():Var {return c("xxwx");}
public function get xxwy():Var {return c("xxwy");}
public function get xxwz():Var {return c("xxwz");}
public function get xxww():Var {return c("xxww");}
public function get xy():Var {return c("xy");}
public function get xyx():Var {return c("xyx");}
public function get xyxx():Var {return c("xyxx");}
public function get xyxy():Var {return c("xyxy");}
public function get xyxz():Var {return c("xyxz");}
public function get xyxw():Var {return c("xyxw");}
public function get xyy():Var {return c("xyy");}
public function get xyyx():Var {return c("xyyx");}
public function get xyyy():Var {return c("xyyy");}
public function get xyyz():Var {return c("xyyz");}
public function get xyyw():Var {return c("xyyw");}
public function get xyz():Var {return c("xyz");}
public function get xyzx():Var {return c("xyzx");}
public function get xyzy():Var {return c("xyzy");}
public function get xyzz():Var {return c("xyzz");}
public function get xyzw():Var {return c("xyzw");}
public function get xyw():Var {return c("xyw");}
public function get xywx():Var {return c("xywx");}
public function get xywy():Var {return c("xywy");}
public function get xywz():Var {return c("xywz");}
public function get xyww():Var {return c("xyww");}
public function get xz():Var {return c("xz");}
public function get xzx():Var {return c("xzx");}
public function get xzxx():Var {return c("xzxx");}
public function get xzxy():Var {return c("xzxy");}
public function get xzxz():Var {return c("xzxz");}
public function get xzxw():Var {return c("xzxw");}
public function get xzy():Var {return c("xzy");}
public function get xzyx():Var {return c("xzyx");}
public function get xzyy():Var {return c("xzyy");}
public function get xzyz():Var {return c("xzyz");}
public function get xzyw():Var {return c("xzyw");}
public function get xzz():Var {return c("xzz");}
public function get xzzx():Var {return c("xzzx");}
public function get xzzy():Var {return c("xzzy");}
public function get xzzz():Var {return c("xzzz");}
public function get xzzw():Var {return c("xzzw");}
public function get xzw():Var {return c("xzw");}
public function get xzwx():Var {return c("xzwx");}
public function get xzwy():Var {return c("xzwy");}
public function get xzwz():Var {return c("xzwz");}
public function get xzww():Var {return c("xzww");}
public function get xw():Var {return c("xw");}
public function get xwx():Var {return c("xwx");}
public function get xwxx():Var {return c("xwxx");}
public function get xwxy():Var {return c("xwxy");}
public function get xwxz():Var {return c("xwxz");}
public function get xwxw():Var {return c("xwxw");}
public function get xwy():Var {return c("xwy");}
public function get xwyx():Var {return c("xwyx");}
public function get xwyy():Var {return c("xwyy");}
public function get xwyz():Var {return c("xwyz");}
public function get xwyw():Var {return c("xwyw");}
public function get xwz():Var {return c("xwz");}
public function get xwzx():Var {return c("xwzx");}
public function get xwzy():Var {return c("xwzy");}
public function get xwzz():Var {return c("xwzz");}
public function get xwzw():Var {return c("xwzw");}
public function get xww():Var {return c("xww");}
public function get xwwx():Var {return c("xwwx");}
public function get xwwy():Var {return c("xwwy");}
public function get xwwz():Var {return c("xwwz");}
public function get xwww():Var {return c("xwww");}
public function get y():Var {return c("y");}
public function get yx():Var {return c("yx");}
public function get yxx():Var {return c("yxx");}
public function get yxxx():Var {return c("yxxx");}
public function get yxxy():Var {return c("yxxy");}
public function get yxxz():Var {return c("yxxz");}
public function get yxxw():Var {return c("yxxw");}
public function get yxy():Var {return c("yxy");}
public function get yxyx():Var {return c("yxyx");}
public function get yxyy():Var {return c("yxyy");}
public function get yxyz():Var {return c("yxyz");}
public function get yxyw():Var {return c("yxyw");}
public function get yxz():Var {return c("yxz");}
public function get yxzx():Var {return c("yxzx");}
public function get yxzy():Var {return c("yxzy");}
public function get yxzz():Var {return c("yxzz");}
public function get yxzw():Var {return c("yxzw");}
public function get yxw():Var {return c("yxw");}
public function get yxwx():Var {return c("yxwx");}
public function get yxwy():Var {return c("yxwy");}
public function get yxwz():Var {return c("yxwz");}
public function get yxww():Var {return c("yxww");}
public function get yy():Var {return c("yy");}
public function get yyx():Var {return c("yyx");}
public function get yyxx():Var {return c("yyxx");}
public function get yyxy():Var {return c("yyxy");}
public function get yyxz():Var {return c("yyxz");}
public function get yyxw():Var {return c("yyxw");}
public function get yyy():Var {return c("yyy");}
public function get yyyx():Var {return c("yyyx");}
public function get yyyy():Var {return c("yyyy");}
public function get yyyz():Var {return c("yyyz");}
public function get yyyw():Var {return c("yyyw");}
public function get yyz():Var {return c("yyz");}
public function get yyzx():Var {return c("yyzx");}
public function get yyzy():Var {return c("yyzy");}
public function get yyzz():Var {return c("yyzz");}
public function get yyzw():Var {return c("yyzw");}
public function get yyw():Var {return c("yyw");}
public function get yywx():Var {return c("yywx");}
public function get yywy():Var {return c("yywy");}
public function get yywz():Var {return c("yywz");}
public function get yyww():Var {return c("yyww");}
public function get yz():Var {return c("yz");}
public function get yzx():Var {return c("yzx");}
public function get yzxx():Var {return c("yzxx");}
public function get yzxy():Var {return c("yzxy");}
public function get yzxz():Var {return c("yzxz");}
public function get yzxw():Var {return c("yzxw");}
public function get yzy():Var {return c("yzy");}
public function get yzyx():Var {return c("yzyx");}
public function get yzyy():Var {return c("yzyy");}
public function get yzyz():Var {return c("yzyz");}
public function get yzyw():Var {return c("yzyw");}
public function get yzz():Var {return c("yzz");}
public function get yzzx():Var {return c("yzzx");}
public function get yzzy():Var {return c("yzzy");}
public function get yzzz():Var {return c("yzzz");}
public function get yzzw():Var {return c("yzzw");}
public function get yzw():Var {return c("yzw");}
public function get yzwx():Var {return c("yzwx");}
public function get yzwy():Var {return c("yzwy");}
public function get yzwz():Var {return c("yzwz");}
public function get yzww():Var {return c("yzww");}
public function get yw():Var {return c("yw");}
public function get ywx():Var {return c("ywx");}
public function get ywxx():Var {return c("ywxx");}
public function get ywxy():Var {return c("ywxy");}
public function get ywxz():Var {return c("ywxz");}
public function get ywxw():Var {return c("ywxw");}
public function get ywy():Var {return c("ywy");}
public function get ywyx():Var {return c("ywyx");}
public function get ywyy():Var {return c("ywyy");}
public function get ywyz():Var {return c("ywyz");}
public function get ywyw():Var {return c("ywyw");}
public function get ywz():Var {return c("ywz");}
public function get ywzx():Var {return c("ywzx");}
public function get ywzy():Var {return c("ywzy");}
public function get ywzz():Var {return c("ywzz");}
public function get ywzw():Var {return c("ywzw");}
public function get yww():Var {return c("yww");}
public function get ywwx():Var {return c("ywwx");}
public function get ywwy():Var {return c("ywwy");}
public function get ywwz():Var {return c("ywwz");}
public function get ywww():Var {return c("ywww");}
public function get z():Var {return c("z");}
public function get zx():Var {return c("zx");}
public function get zxx():Var {return c("zxx");}
public function get zxxx():Var {return c("zxxx");}
public function get zxxy():Var {return c("zxxy");}
public function get zxxz():Var {return c("zxxz");}
public function get zxxw():Var {return c("zxxw");}
public function get zxy():Var {return c("zxy");}
public function get zxyx():Var {return c("zxyx");}
public function get zxyy():Var {return c("zxyy");}
public function get zxyz():Var {return c("zxyz");}
public function get zxyw():Var {return c("zxyw");}
public function get zxz():Var {return c("zxz");}
public function get zxzx():Var {return c("zxzx");}
public function get zxzy():Var {return c("zxzy");}
public function get zxzz():Var {return c("zxzz");}
public function get zxzw():Var {return c("zxzw");}
public function get zxw():Var {return c("zxw");}
public function get zxwx():Var {return c("zxwx");}
public function get zxwy():Var {return c("zxwy");}
public function get zxwz():Var {return c("zxwz");}
public function get zxww():Var {return c("zxww");}
public function get zy():Var {return c("zy");}
public function get zyx():Var {return c("zyx");}
public function get zyxx():Var {return c("zyxx");}
public function get zyxy():Var {return c("zyxy");}
public function get zyxz():Var {return c("zyxz");}
public function get zyxw():Var {return c("zyxw");}
public function get zyy():Var {return c("zyy");}
public function get zyyx():Var {return c("zyyx");}
public function get zyyy():Var {return c("zyyy");}
public function get zyyz():Var {return c("zyyz");}
public function get zyyw():Var {return c("zyyw");}
public function get zyz():Var {return c("zyz");}
public function get zyzx():Var {return c("zyzx");}
public function get zyzy():Var {return c("zyzy");}
public function get zyzz():Var {return c("zyzz");}
public function get zyzw():Var {return c("zyzw");}
public function get zyw():Var {return c("zyw");}
public function get zywx():Var {return c("zywx");}
public function get zywy():Var {return c("zywy");}
public function get zywz():Var {return c("zywz");}
public function get zyww():Var {return c("zyww");}
public function get zz():Var {return c("zz");}
public function get zzx():Var {return c("zzx");}
public function get zzxx():Var {return c("zzxx");}
public function get zzxy():Var {return c("zzxy");}
public function get zzxz():Var {return c("zzxz");}
public function get zzxw():Var {return c("zzxw");}
public function get zzy():Var {return c("zzy");}
public function get zzyx():Var {return c("zzyx");}
public function get zzyy():Var {return c("zzyy");}
public function get zzyz():Var {return c("zzyz");}
public function get zzyw():Var {return c("zzyw");}
public function get zzz():Var {return c("zzz");}
public function get zzzx():Var {return c("zzzx");}
public function get zzzy():Var {return c("zzzy");}
public function get zzzz():Var {return c("zzzz");}
public function get zzzw():Var {return c("zzzw");}
public function get zzw():Var {return c("zzw");}
public function get zzwx():Var {return c("zzwx");}
public function get zzwy():Var {return c("zzwy");}
public function get zzwz():Var {return c("zzwz");}
public function get zzww():Var {return c("zzww");}
public function get zw():Var {return c("zw");}
public function get zwx():Var {return c("zwx");}
public function get zwxx():Var {return c("zwxx");}
public function get zwxy():Var {return c("zwxy");}
public function get zwxz():Var {return c("zwxz");}
public function get zwxw():Var {return c("zwxw");}
public function get zwy():Var {return c("zwy");}
public function get zwyx():Var {return c("zwyx");}
public function get zwyy():Var {return c("zwyy");}
public function get zwyz():Var {return c("zwyz");}
public function get zwyw():Var {return c("zwyw");}
public function get zwz():Var {return c("zwz");}
public function get zwzx():Var {return c("zwzx");}
public function get zwzy():Var {return c("zwzy");}
public function get zwzz():Var {return c("zwzz");}
public function get zwzw():Var {return c("zwzw");}
public function get zww():Var {return c("zww");}
public function get zwwx():Var {return c("zwwx");}
public function get zwwy():Var {return c("zwwy");}
public function get zwwz():Var {return c("zwwz");}
public function get zwww():Var {return c("zwww");}
public function get w():Var {return c("w");}
public function get wx():Var {return c("wx");}
public function get wxx():Var {return c("wxx");}
public function get wxxx():Var {return c("wxxx");}
public function get wxxy():Var {return c("wxxy");}
public function get wxxz():Var {return c("wxxz");}
public function get wxxw():Var {return c("wxxw");}
public function get wxy():Var {return c("wxy");}
public function get wxyx():Var {return c("wxyx");}
public function get wxyy():Var {return c("wxyy");}
public function get wxyz():Var {return c("wxyz");}
public function get wxyw():Var {return c("wxyw");}
public function get wxz():Var {return c("wxz");}
public function get wxzx():Var {return c("wxzx");}
public function get wxzy():Var {return c("wxzy");}
public function get wxzz():Var {return c("wxzz");}
public function get wxzw():Var {return c("wxzw");}
public function get wxw():Var {return c("wxw");}
public function get wxwx():Var {return c("wxwx");}
public function get wxwy():Var {return c("wxwy");}
public function get wxwz():Var {return c("wxwz");}
public function get wxww():Var {return c("wxww");}
public function get wy():Var {return c("wy");}
public function get wyx():Var {return c("wyx");}
public function get wyxx():Var {return c("wyxx");}
public function get wyxy():Var {return c("wyxy");}
public function get wyxz():Var {return c("wyxz");}
public function get wyxw():Var {return c("wyxw");}
public function get wyy():Var {return c("wyy");}
public function get wyyx():Var {return c("wyyx");}
public function get wyyy():Var {return c("wyyy");}
public function get wyyz():Var {return c("wyyz");}
public function get wyyw():Var {return c("wyyw");}
public function get wyz():Var {return c("wyz");}
public function get wyzx():Var {return c("wyzx");}
public function get wyzy():Var {return c("wyzy");}
public function get wyzz():Var {return c("wyzz");}
public function get wyzw():Var {return c("wyzw");}
public function get wyw():Var {return c("wyw");}
public function get wywx():Var {return c("wywx");}
public function get wywy():Var {return c("wywy");}
public function get wywz():Var {return c("wywz");}
public function get wyww():Var {return c("wyww");}
public function get wz():Var {return c("wz");}
public function get wzx():Var {return c("wzx");}
public function get wzxx():Var {return c("wzxx");}
public function get wzxy():Var {return c("wzxy");}
public function get wzxz():Var {return c("wzxz");}
public function get wzxw():Var {return c("wzxw");}
public function get wzy():Var {return c("wzy");}
public function get wzyx():Var {return c("wzyx");}
public function get wzyy():Var {return c("wzyy");}
public function get wzyz():Var {return c("wzyz");}
public function get wzyw():Var {return c("wzyw");}
public function get wzz():Var {return c("wzz");}
public function get wzzx():Var {return c("wzzx");}
public function get wzzy():Var {return c("wzzy");}
public function get wzzz():Var {return c("wzzz");}
public function get wzzw():Var {return c("wzzw");}
public function get wzw():Var {return c("wzw");}
public function get wzwx():Var {return c("wzwx");}
public function get wzwy():Var {return c("wzwy");}
public function get wzwz():Var {return c("wzwz");}
public function get wzww():Var {return c("wzww");}
public function get ww():Var {return c("ww");}
public function get wwx():Var {return c("wwx");}
public function get wwxx():Var {return c("wwxx");}
public function get wwxy():Var {return c("wwxy");}
public function get wwxz():Var {return c("wwxz");}
public function get wwxw():Var {return c("wwxw");}
public function get wwy():Var {return c("wwy");}
public function get wwyx():Var {return c("wwyx");}
public function get wwyy():Var {return c("wwyy");}
public function get wwyz():Var {return c("wwyz");}
public function get wwyw():Var {return c("wwyw");}
public function get wwz():Var {return c("wwz");}
public function get wwzx():Var {return c("wwzx");}
public function get wwzy():Var {return c("wwzy");}
public function get wwzz():Var {return c("wwzz");}
public function get wwzw():Var {return c("wwzw");}
public function get www():Var {return c("www");}
public function get wwwx():Var {return c("wwwx");}
public function get wwwy():Var {return c("wwwy");}
public function get wwwz():Var {return c("wwwz");}
public function get wwww():Var {return c("wwww");}
		
	}

}