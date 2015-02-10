package ui 
{
	import flash.external.ExternalInterface;
	CONFIG::air {
		import flash.html.HTMLLoader;
	}
	/**
	 * 本机弹出框
	 * @author lizhi
	 */
	public class Alert 
	{
		private static var htmlloader:Object;
        public static function alert(message:String):void
        {
			doJS("alert",message);
        }
     
        public static function confirm(message:String):Boolean
        {
            return doJS("confirm",message) as Boolean;
        }
   
        public static function prompt(message:String,defaultVal:String=""):String
        {
            return doJS("prompt",message, defaultVal) as String;
        }
		
		public static function init():void {
			CONFIG::air {
				if (htmlloader == null) {
					try {
						htmlloader = new HTMLLoader;
					}catch (err:Error) {
					
					}
				}
			}
		}
		
		public static function doJS(fname:String, ...args:Array):Object {
			init();
			var ret:Object;
			if (htmlloader) {
				ret = htmlloader.window[fname].apply(null, args);
			}else if (ExternalInterface.available) {
				var arr:Array = [];
				arr.push(fname);
				arr = arr.concat(args);
				ret = ExternalInterface.call.apply(null,arr);
			}else {
				var err:Error = new Error(args);
				err.name = fname;
				//throw err;
			}
			return ret;
		}
	}

}