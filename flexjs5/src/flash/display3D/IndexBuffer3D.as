package flash.display3D
{
   import flash.utils.ByteArray;
   
   public final class IndexBuffer3D extends Object
   {
       public var count:int;
	   public var buff:WebGLBuffer;
      public function IndexBuffer3D()
      {
         super();
      }
      
     public function uploadFromVector(param1:Vector.<uint>, param2:int, param3:int) : void{}
      
     public function uploadFromByteArray(param1:ByteArray, param2:int, param3:int, param4:int) : void{}
      
     public function dispose() : void{}
   }
}
