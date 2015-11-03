package flash.events
{
   import flash.net.*;
   
   [Event(name="deactivate",type="flash.events.Event")]
   [Event(name="activate",type="flash.events.Event")]
   public class EventDispatcher
   {
       
      public function EventDispatcher(target:EventDispatcher = null)
      {
         super();
         this.ctor(target);
      }
      
      private static function trimHeaderValue(headerValue:String) : String
      {
         var currChar:String = null;
         var indexOfFirstValueChar:uint = 0;
         var headerValueLen:uint = headerValue.length;
         var done:Boolean = false;
         while(indexOfFirstValueChar < headerValueLen && !done)
         {
            currChar = headerValue.charAt(indexOfFirstValueChar);
            done = currChar != " " && currChar != "\t";
            if(!done)
            {
               indexOfFirstValueChar++;
            }
         }
         var indexOfLastValueChar:uint = headerValueLen;
         done = false;
         while(indexOfLastValueChar > indexOfFirstValueChar && !done)
         {
            currChar = headerValue.charAt(indexOfLastValueChar - 1);
            done = currChar != " " && currChar != "\t";
            if(!done)
            {
               indexOfLastValueChar--;
            }
         }
         return headerValue.substring(indexOfFirstValueChar,indexOfLastValueChar);
      }
      
     private function ctor(param1:EventDispatcher) : void{}
      
     public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void{}
      
     public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void{}
      
      public function dispatchEvent(event:Event) : Boolean
      {
         if(event.target)
         {
            return this.dispatchEventFunction(event.clone());
         }
         return this.dispatchEventFunction(event);
      }
      
     public function hasEventListener(param1:String) : Boolean{return false}
      
     public function willTrigger(param1:String) : Boolean{return false}
      
     private function dispatchEventFunction(param1:Event) : Boolean{return false}
      
     
   }
}
