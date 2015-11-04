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
	   private var canvas:HTMLCanvasElement;
	   private var gl:WebGLRenderingContext;
       
      public function Context3D()
      {
         super();
		 canvas = document.createElement("canvas") as HTMLCanvasElement;
		document.body.appendChild(canvas);
		gl = (canvas.getContext("webgl")||canvas.getContext("experimental-webgl")) as WebGLRenderingContext;
			
      }
      
     public static function get supportsVideoTexture() : Boolean{return false}
      
     public function get driverInfo() : String{return null}
      
     public function dispose(param1:Boolean = true) : void{}
      
     public function get enableErrorChecking() : Boolean{return false}
      
     public function set enableErrorChecking(param1:Boolean) : void{}
      
     public function configureBackBuffer(width:int, height:int, antiAlias:int, enableDepthAndStencil:Boolean=true, wantsBestResolution:Boolean=false) : void { 
		canvas.width = width;
		canvas.height = height;
		gl.viewport(0, 0, width, height);
		 if(enableDepthAndStencil){
			gl.enable(WebGLRenderingContext.DEPTH_TEST);
			gl.enable(WebGLRenderingContext.STENCIL_TEST);
		 }else{
			gl.disable(WebGLRenderingContext.DEPTH_TEST);
			gl.disable(WebGLRenderingContext.STENCIL_TEST);
		 }
	 }
      
     public function clear(red:Number = 0, green:Number = 0, blue:Number = 0, alpha:Number = 1, depth:Number = 1, stencil:uint = 0, mask:uint = 4294967295) : void {
		gl.clearColor(red, green, blue, alpha);
		gl.clearDepth(depth);
		gl.clearStencil(stencil);
		gl.clear(WebGLRenderingContext.COLOR_BUFFER_BIT | WebGLRenderingContext.DEPTH_BUFFER_BIT);
	 }
      
     public function drawTriangles(indexBuffer:IndexBuffer3D, firstIndex:int=0, numTriangles:int=-1) : void{
		gl.bindBuffer(WebGLRenderingContext.ELEMENT_ARRAY_BUFFER, indexBuffer.buff);
		gl.drawElements(WebGLRenderingContext.TRIANGLES, numTriangles<0?indexBuffer.count:numTriangles*3, WebGLRenderingContext.UNSIGNED_SHORT, firstIndex*2);
	 }
      
     public function present() : void{}
      
     public function setProgram(program:Program3D) : void{
		 gl.useProgram(program.program);
	 }
      
     public function setProgramConstantsFromVector(programType:String, firstRegister:int, data:Vector.<Number>, numRegisters:int = -1) : void {
		
	 }
      
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
