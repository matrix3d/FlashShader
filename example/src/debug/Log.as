package debug 
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.Socket;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Log 
	{
		private static var _textField:TextField;
		private static var buff:String = "";
		static private var socket:Socket;
		public static var onConnect:Function;
		public function Log() 
		{
		}
		
		static public function init():void {
			textField;
		}
		
		static public function get textField():TextField 
		{
			if (_textField == null) {
				try { 
					Security.allowDomain("*");
				}
				catch (e:Error) { }
				_textField = new TextField;
				_textField.autoSize = "left";
				_textField.defaultTextFormat = new TextFormat(null, 40);
				socket = new Socket("192.168.1.250", 400);
				socket.addEventListener(IOErrorEvent.IO_ERROR, socket_ioError);
				socket.addEventListener(Event.CONNECT, socket_connect);
			}
			return _textField;
		}
		
		static public function log(...args):void {
			textField.appendText("\n")
			textField.appendText(args+"");
			
			buff += args + "\n";
			if (socket.connected) {
				send();
			}
		}
		
		private static function socket_ioError(e:IOErrorEvent):void 
		{
			trace(e);
		}
		
		private static function socket_connect(e:Event):void 
		{
			if (onConnect != null) {
				onConnect();
			}
			send();
		}
		
		private static function send():void {
			if(buff.length){
				socket.writeMultiByte(buff, "utf-8");
				socket.flush();
				buff = "";
			}
		}
		
	}

}