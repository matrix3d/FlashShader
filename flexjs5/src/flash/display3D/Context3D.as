package flash.display3D
{
   import flash.events.EventDispatcher;
   import flash.geom.Matrix3D;
   import flash.utils.ByteArray;
   import flash.display3D.textures.*;
   import flash.geom.Rectangle;
   import flash.display.BitmapData;
   
   public final class Context3D extends EventDispatcher
   {
       
      public function Context3D()
      {
         super();
      }
      
     public static function get supportsVideoTexture() : Boolean{return false}
      
     public function get driverInfo() : String{return null}
      
     public function dispose(param1:Boolean = true) : void{}
      
     public function get enableErrorChecking() : Boolean{return false}
      
     public function set enableErrorChecking(param1:Boolean) : void{}
      
     public function configureBackBuffer(param1:int, param2:int, param3:int, param4:Boolean = true, param5:Boolean = false, param6:Boolean = false) : void{}
      
     public function clear(param1:Number = 0.0, param2:Number = 0.0, param3:Number = 0.0, param4:Number = 1.0, param5:Number = 1.0, param6:uint = 0, param7:uint = 4.294967295E9) : void{}
      
     public function drawTriangles(param1:IndexBuffer3D, param2:int = 0, param3:int = -1) : void{}
      
     public function present() : void{}
      
     public function setProgram(param1:Program3D) : void{}
      
     public function setProgramConstantsFromVector(param1:String, param2:int, param3:Vector.<Number>, param4:int = -1) : void{}
      
     public function setProgramConstantsFromMatrix(param1:String, param2:int, param3:Matrix3D, param4:Boolean = false) : void{}
      
     public function setProgramConstantsFromByteArray(param1:String, param2:int, param3:int, param4:ByteArray, param5:uint) : void{}
      
     public function setVertexBufferAt(param1:int, param2:VertexBuffer3D, param3:int = 0, param4:String = "float4") : void{}
      
     public function setBlendFactors(param1:String, param2:String) : void{}
      
     public function setColorMask(param1:Boolean, param2:Boolean, param3:Boolean, param4:Boolean) : void{}
      
     public function setDepthTest(param1:Boolean, param2:String) : void{}
      
      public function setTextureAt(sampler:int, texture:TextureBase) : void
      {
         if(texture == null)
         {
            this.setTextureInternal(sampler,null);
         }
         else if(texture is Texture)
         {
            this.setTextureInternal(sampler,texture as Texture);
         }
         else if(texture is CubeTexture)
         {
            this.setCubeTextureInternal(sampler,texture as CubeTexture);
         }
         else if(texture is RectangleTexture)
         {
            this.setRectangleTextureInternal(sampler,texture as RectangleTexture);
         }
         else if(texture is VideoTexture)
         {
            this.setVideoTextureInternal(sampler,texture as VideoTexture);
         }
      }
      
      public function setRenderToTexture(texture:TextureBase, enableDepthAndStencil:Boolean = false, antiAlias:int = 0, surfaceSelector:int = 0, colorOutputIndex:int = 0) : void
      {
         var targetType:uint = 0;
         if(texture is Texture)
         {
            targetType = 1;
         }
         else if(texture is CubeTexture)
         {
            targetType = 2;
         }
         else if(texture is RectangleTexture)
         {
            targetType = 3;
         }
         else if(texture != null)
         {
            throw "texture argument not derived from TextureBase (can be Texture, CubeTexture, or if supported, RectangleTexture)";
         }
         this.setRenderToTextureInternal(texture,targetType,enableDepthAndStencil,antiAlias,surfaceSelector,colorOutputIndex);
      }
      
     public function setRenderToBackBuffer() : void{}
      
     private function setRenderToTextureInternal(param1:TextureBase, param2:int, param3:Boolean, param4:int, param5:int, param6:int) : void{}
      
	 public function setCulling(param1:String) : void{}
      
     public function setStencilActions(param1:String = "frontAndBack", param2:String = "always", param3:String = "keep", param4:String = "keep", param5:String = "keep") : void{}
      
     public function setStencilReferenceValue(param1:uint, param2:uint = 255, param3:uint = 255) : void{}
      
     public function setScissorRectangle(param1:Rectangle) : void{}
      
     public function createVertexBuffer(param1:int, param2:int, param3:String = "staticDraw") : VertexBuffer3D{return null}
      
     public function createIndexBuffer(param1:int, param2:String = "staticDraw") : IndexBuffer3D{return null}
      
     public function createTexture(param1:int, param2:int, param3:String, param4:Boolean, param5:int = 0) : Texture{return null}
      
     public function createCubeTexture(param1:int, param2:String, param3:Boolean, param4:int = 0) : CubeTexture{return null}
      
     public function createRectangleTexture(param1:int, param2:int, param3:String, param4:Boolean) : RectangleTexture{return null}
      
     public function createProgram() : Program3D{return null}
      
     public function drawToBitmapData(param1:BitmapData) : void{}
      
     public function setSamplerStateAt(param1:int, param2:String, param3:String, param4:String) : void{}
      
     public function get profile() : String{return null}
      
     private function setTextureInternal(param1:int, param2:Texture) : void{}
      
     private function setCubeTextureInternal(param1:int, param2:CubeTexture) : void{}
      
     private function setRectangleTextureInternal(param1:int, param2:RectangleTexture) : void{}
      
     private function setVideoTextureInternal(param1:int, param2:VideoTexture) : void{}
      
     public function get backBufferWidth() : int{return 0}
      
     public function get backBufferHeight() : int{return 0}
      
     public function get maxBackBufferWidth() : int{return 0}
      
     public function set maxBackBufferWidth(param1:int) : void{}
      
     public function get maxBackBufferHeight() : int{return 0}
      
     public function set maxBackBufferHeight(param1:int) : void{}
      
     public function createVideoTexture() : VideoTexture{return null}
   }
}
