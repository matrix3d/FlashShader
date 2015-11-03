package flash.display
{
   import flash.events.EventDispatcher;
   import flash.geom.Rectangle;
   
   public class Sprite extends EventDispatcher
   {
       
	  public function get stage() : Stage{return null}
      public function Sprite()
      {
      }
	  public function get x() : Number{return 0}
      
     public function set x(param1:Number) : void{}
      
     public function get y() : Number{return 0}
      
     public function set y(param1:Number) : void{}
   }
}
