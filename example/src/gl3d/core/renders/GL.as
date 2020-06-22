package gl3d.core.renders 
{
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DFillMode;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.textures.CubeTexture;
	//import flash.display3D.textures.RectangleTexture;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.display3D.VertexBuffer3D;
	import gl3d.core.shaders.GLShader;
	import gl3d.util.Utils;
	//import flash.display3D.textures.VideoTexture;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import gl3d.core.IndexBufferSet;
	/**
	 * ...
	 * @author lizhi
	 */
	public class GL 
	{
		
		public var customFillMode:String;
		public var customSourceFactor:String;
		public var customDestinationFactor:String;
		public var context:Context3D;
		
		public var lastBuffMaxIndex:int = 0;
		public var nowBuffMaxIndex:int = 0;
		public var lastTexMaxIndex:int = 0;
		public var nowTexMaxIndex:int = 0;
		public var drawTriangleCounter:int = 0;
		public var drawCounter:int = 0;
		private var tempvec4:Vector.<Number> = new Vector.<Number>(4);
		private var currentTextures:Object = { };
		private var currentVBufs:Object = { };
		public function GL(context:Context3D) 
		{
			this.context = context;
		}
		
		public function clear(red : Number = 0, green : Number = 0, blue : Number = 0, alpha : Number = 1, depth : Number = 1, stencil : uint = 0, mask : uint = 0xFFFFFFFF) : void {
			beginDraw();
			GLShader.LastMaterial = null;
			currentTextures = {};
			currentVBufs = {};
			context.clear(red, green, blue, alpha, depth, stencil, mask);
		}
		public function configureBackBuffer(width : int, height : int, antiAlias : int, enableDepthAndStencil : Boolean = true, wantsBestResolution : Boolean = false) : void {
			context.configureBackBuffer(width, height, antiAlias, enableDepthAndStencil/*, wantsBestResolution*/);
		}
		public function createCubeTexture(size : int, format : String, optimizeForRenderToTexture : Boolean, streamingLevels : int = 0) : CubeTexture {
			return context.createCubeTexture(size, format, optimizeForRenderToTexture/*, streamingLevels*/);
		}
		public function createIndexBuffer(numIndices : int, bufferUsage:String) : IndexBuffer3D {
			if (context.createIndexBuffer.length==2){
				return context.createIndexBuffer(numIndices,bufferUsage);
			}
			return context.createIndexBuffer(numIndices);
		}
		public function createProgram() : Program3D {
			return context.createProgram();
		}
		
		public function createRectangleTexture (width:int, height:int, format:String, optimizeForRenderToTexture:Boolean) : TextureBase {
			return context.createRectangleTexture(width, height, format, optimizeForRenderToTexture);
		}

		public function createTexture(width : int, height : int, format : String, optimizeForRenderToTexture : Boolean, streamingLevels : int = 0) : Texture {
			return context.createTexture(width, height, format||Context3DTextureFormat.BGRA, optimizeForRenderToTexture/*, streamingLevels*/);
		}
		
		public function createVideoTexture() :Object/*VideoTexture*/ {
			return context.createVideoTexture();
		}
		
		public function createVertexBuffer(numVertices : int, data32PerVertex : int, bufferUsage:String) : VertexBuffer3D {
			if (context.createVertexBuffer.length==3){
				return context.createVertexBuffer(numVertices, data32PerVertex,bufferUsage);
			}
			return context.createVertexBuffer(numVertices, data32PerVertex);
		}
		public function dispose(recreate : Boolean = true) : void {
			context.dispose(recreate);
		}
		public function drawToBitmapData(destination : BitmapData) : void {
			beginDraw();
			context.drawToBitmapData(destination);
		}
		public function drawTriangles(indexBuffer : IndexBufferSet, firstIndex : int = 0, numTriangles : int = -1, isBeginDraw:Boolean = true) : void {
			if(isBeginDraw)
			beginDraw();
			indexBuffer.update(this);
			if(numTriangles==-1){
				drawTriangleCounter += indexBuffer.data.length / 3;
			}else{
				drawTriangleCounter += numTriangles;
			}
			drawCounter++;
			context.drawTriangles(indexBuffer.buff, firstIndex, numTriangles);
		}
		public function drawToBitmapDataInstance(destination : BitmapData) : void {
			context.drawToBitmapData(destination);
		}
		public function beginDraw():void {
			while (nowBuffMaxIndex < lastBuffMaxIndex ) {
				setVertexBufferAtInternal(++nowBuffMaxIndex, null);
			}
			while (nowTexMaxIndex < lastTexMaxIndex ) {
				setTextureInternal(++nowTexMaxIndex, null);
			}
			lastBuffMaxIndex = nowBuffMaxIndex;
			lastTexMaxIndex = nowTexMaxIndex;
			nowBuffMaxIndex = nowTexMaxIndex = -1;
		}
		
		public function present() : void {
			context.present();
		}
		public function setBlendFactors(sourceFactor : String, destinationFactor : String) : void {
			context.setBlendFactors(customSourceFactor||sourceFactor, customDestinationFactor||destinationFactor);
		}
		public function setColorMask(red : Boolean, green : Boolean, blue : Boolean, alpha : Boolean) : void {
			context.setColorMask(red, green, blue, alpha);
		}
		public function setCulling(triangleFaceToCull : String) : void {
			context.setCulling(triangleFaceToCull);
		}
		public function setDepthTest(depthMask : Boolean, passCompareMode : String) : void {
			context.setDepthTest(depthMask, passCompareMode);
		}
		public function setProgram(program : Program3D) : void {
			context.setProgram(program);
		}
		public function setProgramConstantsFromByteArray(programType : String, firstRegister : int, numRegisters : int, data : ByteArray, byteArrayOffset : uint) : void {
			context.setProgramConstantsFromByteArray(programType, firstRegister, numRegisters, data, byteArrayOffset);
		}
		public function setProgramConstantsFromMatrix(programType : String, firstRegister : int, matrix : Matrix3D, transposedMatrix : Boolean = false) : void {
			context.setProgramConstantsFromMatrix(programType, firstRegister, matrix, transposedMatrix);
		}
		public function setProgramConstantsFromVector(programType : String, firstRegister : int, data : Vector.<Number>, numRegisters : int = -1) : void {
			context.setProgramConstantsFromVector(programType, firstRegister, data, numRegisters);
		}
		
		public function setFillMode(fillMode:String):void 
		{
			//context["setFillMode"](customFillMode||fillMode);
		}
		public function setProgramConstantsFromVector3D(programType : String, firstRegister : int, data : Vector3D) : void {
			tempvec4[0] = data.x;
			tempvec4[1] = data.y;
			tempvec4[2] = data.z;
			tempvec4[3] = data.w;
			context.setProgramConstantsFromVector(programType, firstRegister, tempvec4);
		}
		public function setProgramConstantsFromXYZW(programType : String, firstRegister : int, x:Number=0,y:Number=0,z:Number=0,w:Number=0) : void {
			tempvec4[0] = x;
			tempvec4[1] = y;
			tempvec4[2] = z;
			tempvec4[3] = w;
			context.setProgramConstantsFromVector(programType, firstRegister, tempvec4);
		}
		public function setRenderToBackBuffer() : void {
			context.setRenderToBackBuffer();
		}
		public function setRenderToTexture(texture : TextureBase, enableDepthAndStencil : Boolean = false, antiAlias : int = 0, surfaceSelector : int = 0) : void {
			context.setRenderToTexture(texture, enableDepthAndStencil, antiAlias, surfaceSelector);
		}
		public function setSamplerStateAt(sampler : int, wrap : String, filter : String, mipfilter : String) : void {
			//context.setSamplerStateAt(sampler, wrap, filter, mipfilter);
		}
		public function setScissorRectangle(rectangle : Rectangle) : void {
			context.setScissorRectangle(rectangle);
		}
		public function setStencilActions(triangleFace : String, compareMode : String, actionOnBothPass : String, actionOnDepthFail : String, actionOnDepthPassStencilFail : String) : void {
			context.setStencilActions(triangleFace, compareMode, actionOnBothPass, actionOnDepthFail, actionOnDepthPassStencilFail);
		}
		public function setStencilReferenceValue(referenceValue : uint, readMask : uint = 255, writeMask : uint = 255) :void {
			context.setStencilReferenceValue(referenceValue, readMask, writeMask);
		}
		public function setTextureAt(sampler : int, texture : TextureBase) : void {
			setTextureInternal(sampler, texture);
			if (nowTexMaxIndex < sampler) nowTexMaxIndex = sampler;
		}
		private  function setTextureInternal(sampler : int, texture : TextureBase):void{
			/*if (texture){
				trace(sampler, Utils.getID(texture));
			}*/
			if (currentTextures[sampler] != texture) {
				currentTextures[sampler] = texture;
				context.setTextureAt(sampler, texture);
			}
		}
		public function setVertexBufferAt(index : int, buffer : VertexBuffer3D, bufferOffset : int = 0, format : String="float4") : void {
			setVertexBufferAtInternal(index, buffer, bufferOffset, format);
			if (nowBuffMaxIndex < index) nowBuffMaxIndex = index;
		}
		private  function setVertexBufferAtInternal(sampler:int, buffer : VertexBuffer3D, bufferOffset : int = 0, format : String=null):void{
			if (currentVBufs[sampler] != buffer) {
				currentVBufs[sampler] = buffer;
				context.setVertexBufferAt(sampler, buffer,bufferOffset,format);
			}
		}
		
		public function get driverInfo():String 
		{
			return context.driverInfo;
		}
		
		public function get enableErrorChecking():Boolean {
			return context.enableErrorChecking;
		}
		public function set enableErrorChecking(v:Boolean):void {
			context.enableErrorChecking=v;
		}
	}

}