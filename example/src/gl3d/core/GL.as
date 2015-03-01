package gl3d.core 
{
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.textures.CubeTexture;
	import flash.display3D.textures.RectangleTexture;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author lizhi
	 */
	public class GL 
	{
		private var context:Context3D;
		
		public var lastBuffMaxIndex:int = 0;
		public var nowBuffMaxIndex:int = 0;
		public var lastTexMaxIndex:int = 0;
		public var nowTexMaxIndex:int = 0;
		public function GL(context:Context3D) 
		{
			this.context = context;
		}
		
		public function clear(red : Number = 0, green : Number = 0, blue : Number = 0, alpha : Number = 1, depth : Number = 1, stencil : uint = 0, mask : uint = 0xFFFFFFFF) : void {
			context.clear(red, green, blue, alpha, depth, stencil, mask);
		}
		public function configureBackBuffer(width : int, height : int, antiAlias : int, enableDepthAndStencil : Boolean = true, wantsBestResolution : Boolean = false) : void {
			context.configureBackBuffer(width, height, antiAlias, enableDepthAndStencil/*, wantsBestResolution*/);
		}
		public function createCubeTexture(size : int, format : String, optimizeForRenderToTexture : Boolean, streamingLevels : int = 0) : CubeTexture {
			return context.createCubeTexture(size, format, optimizeForRenderToTexture/*, streamingLevels*/);
		}
		public function createIndexBuffer(numIndices : int) : IndexBuffer3D {
			return context.createIndexBuffer(numIndices);
		}
		public function createProgram() : Program3D {
			return context.createProgram();
		}
		
		public function createRectangleTexture (width:int, height:int, format:String, optimizeForRenderToTexture:Boolean) : RectangleTexture {
			return context.createRectangleTexture(width, height, format, optimizeForRenderToTexture);
		}

		public function createTexture(width : int, height : int, format : String, optimizeForRenderToTexture : Boolean, streamingLevels : int = 0) : Texture {
			return context.createTexture(width, height, format, optimizeForRenderToTexture/*, streamingLevels*/);
		}
		public function createVertexBuffer(numVertices : int, data32PerVertex : int) : VertexBuffer3D {
			return context.createVertexBuffer(numVertices, data32PerVertex);
		}
		public function dispose(recreate : Boolean = true) : void {
			context.dispose(recreate);
		}
		public function drawToBitmapData(destination : BitmapData) : void {
			beginDraw();
			context.drawToBitmapData(destination);
		}
		public function drawTriangles(indexBuffer : IndexBuffer3D, firstIndex : int = 0, numTriangles : int = -1) : void {
			beginDraw();
			context.drawTriangles(indexBuffer, firstIndex, numTriangles);
		}
		public function drawToBitmapDataInstance(destination : BitmapData) : void {
			context.drawToBitmapData(destination);
		}
		public function drawTrianglesInstance(indexBuffer : IndexBuffer3D, firstIndex : int = 0, numTriangles : int = -1) : void {
			context.drawTriangles(indexBuffer, firstIndex, numTriangles);
		}
		public function beginDraw():void {
			while (nowBuffMaxIndex < lastBuffMaxIndex ) {
				context.setVertexBufferAt(++nowBuffMaxIndex, null);
			}
			while (nowTexMaxIndex < lastTexMaxIndex ) {
				context.setTextureAt(++nowTexMaxIndex, null);
			}
			lastBuffMaxIndex = nowBuffMaxIndex;
			lastTexMaxIndex = nowTexMaxIndex;
			nowBuffMaxIndex = nowTexMaxIndex = -1;
		}
		
		public function present() : void {
			context.present();
		}
		public function setBlendFactors(sourceFactor : String, destinationFactor : String) : void {
			context.setBlendFactors(sourceFactor, destinationFactor);
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
			context.setTextureAt(sampler, texture);
			if (nowTexMaxIndex < sampler) nowTexMaxIndex = sampler;
		}
		public function setVertexBufferAt(index : int, buffer : VertexBuffer3D, bufferOffset : int = 0, format : String="float4") : void {
			context.setVertexBufferAt(index, buffer, bufferOffset, format);
			if (nowBuffMaxIndex < index) nowBuffMaxIndex = index;
		}
		
		public function get driverInfo():String 
		{
			return context.driverInfo;
		}
		
	}

}