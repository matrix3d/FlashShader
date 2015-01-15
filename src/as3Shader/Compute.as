package  as3Shader 
{
    
    /**
     * ...
     * @author lizhi
     */
    public class Compute
    {
        private var opPriority:Array;
        private var opArray:Array = [];
        public var opfuns:Array = [];
        private var numArray:Array = [];
        private var lastOp:String = "#";
        public function Compute() 
        {
            var ops:Array =        ["+", "-", "*", "/", "(", ")", "#"];
            var priority:Array = [                                               //0:>,1:<,2:=,3,null
                                    0, 0, 1, 1, 1, 0, 0,
                                    0, 0, 1, 1, 1, 0, 0,
                                    0, 0, 0, 0, 1, 0, 0,
                                    0, 0, 0, 0, 1, 0, 0,
                                    1, 1, 1, 1, 1, 2, 0,
                                    0, 0, 0, 0, 3, 0, 0,
                                    1, 1, 1, 1, 1, 3, 2
                                    ];
            opPriority = [];
            for (var i:int = 0; i < ops.length;i++ ) {
                var line:Array = [];
                opPriority[ops[i]] = line;
                for (var j:int = 0; j < ops.length;j++ ) {
                    line[ops[j]] = priority[i * ops.length + j];
                }
            }
            opfuns["+"] = add;
            opfuns["-"] = sub;
            opfuns["*"] = mul;
            opfuns["/"] = div;
        }
        
        public function count(str:String):Object {
            lastOp = "#";
            opArray = ["#"];
            numArray = [];
            var reg:RegExp =/[0-9]+\.?[0-9]*|[+,\-,*,\/,(,)]/g;
            var opreg:RegExp =/[+,\-,*,\/,(,)]/;
            var obj:Object;
            while ((obj=reg.exec(str))!=null) {
                var s:String = obj[0];
                if (opreg.test(s)) {
                    addOp(s);
                }else {
                    addNum(s);
                }
            }
            addOp("#");
            return numArray[0];
        }
        
        private function addOp(op:String):void { trace("op",op);
            var code:int = opPriority[lastOp][op];
            if (code == 0) {//运算
                opArray.pop();
                if(opfuns[lastOp])numArray.push(opfuns[lastOp].call(null,numArray.pop(),numArray.pop()));
                lastOp = opArray[opArray.length - 1];
                addOp(op);
            }else if (code==1) {//压入
                lastOp = op;
                opArray.push(op);
            }else {//op = ) 弹出 (
                opArray.pop();
                lastOp = opArray[opArray.length - 1];
            }
        }
        private function addNum(num:String):void { trace("num",num);
            numArray.push(num);
        }
        
        private function add(num1:String, num2:String):Object {
			trace(num1 +"+"+ num2+"\n");
            return "temp";
        }
        
        private function sub(num1:String, num2:String):Object {
            trace(num2 +"-" + num1 + "\n");
			return "temp";
        }
        
        private function mul(num1:String, num2:String):Object {
            trace( num1 +"*" + num2 + "\n");
			return "temp";
        }
        
        private function div(num1:String, num2:String):Object {
            trace(num2 +"/" + num1 + "\n");
			return "temp"
        }
    }

}