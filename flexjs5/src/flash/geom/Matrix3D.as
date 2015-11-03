package flash.geom
{
   [Version("10")]
   public class Matrix3D extends Object
   {
       
      public function Matrix3D(v:Vector.<Number> = null)
      {
         super();
         this.ctor(v);
      }
      
     public static function interpolate(param1:Matrix3D, param2:Matrix3D, param3:Number) : Matrix3D{return null}
      
     private function ctor(param1:Vector.<Number>) : void{}
      
     public function clone() : Matrix3D{return null}
      
     public function copyToMatrix3D(param1:Matrix3D) : void{}
      
     public function get rawData() : Vector.<Number>{return null}
      
     public function set rawData(param1:Vector.<Number>) : void{}
      
     public function append(param1:Matrix3D) : void{}
      
     public function prepend(param1:Matrix3D) : void{}
      
     public function invert() : Boolean{return false}
      
     public function identity() : void{}
      
     public function decompose(param1:String = "eulerAngles") : Vector.<Vector3D>{return null}
      
     public function recompose(param1:Vector.<Vector3D>, param2:String = "eulerAngles") : Boolean{return false}
      
     public function get position() : Vector3D{return null}
      
     public function set position(param1:Vector3D) : void{}
      
     public function appendTranslation(param1:Number, param2:Number, param3:Number) : void{}
      
     public function appendRotation(param1:Number, param2:Vector3D, param3:Vector3D = null) : void{}
      
     public function appendScale(param1:Number, param2:Number, param3:Number) : void{}
      
     public function prependTranslation(param1:Number, param2:Number, param3:Number) : void{}
      
     public function prependRotation(param1:Number, param2:Vector3D, param3:Vector3D = null) : void{}
      
     public function prependScale(param1:Number, param2:Number, param3:Number) : void{}
      
     public function transformVector(param1:Vector3D) : Vector3D{return null}
      
     public function deltaTransformVector(param1:Vector3D) : Vector3D{return null}
      
     public function transformVectors(param1:Vector.<Number>, param2:Vector.<Number>) : void{}
      
     public function get determinant() : Number{return 0}
      
     public function transpose() : void{}
      
     public function pointAt(param1:Vector3D, param2:Vector3D = null, param3:Vector3D = null) : void{}
      
     public function interpolateTo(param1:Matrix3D, param2:Number) : void{}
      
     public function copyFrom(param1:Matrix3D) : void{}
      
     public function copyRawDataTo(param1:Vector.<Number>, param2:uint = 0, param3:Boolean = false) : void{}
      
     public function copyRawDataFrom(param1:Vector.<Number>, param2:uint = 0, param3:Boolean = false) : void{}
      
     public function copyRowTo(param1:uint, param2:Vector3D) : void{}
      
     public function copyColumnTo(param1:uint, param2:Vector3D) : void{}
      
     public function copyRowFrom(param1:uint, param2:Vector3D) : void{}
      
     public function copyColumnFrom(param1:uint, param2:Vector3D) : void{}
   }
}
