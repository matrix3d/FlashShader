package 
{
	import com.adobe.utils.extended.AGALMiniAssembler;
	import flash.display.Sprite;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProfile;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DRenderMode;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flShader.FlShader;
	
	/**
	 * http://codeflow.org/entries/2012/aug/02/easy-wireframe-display-with-barycentric-coordinates/
	 * http://arieln.com/blog/2014/08/new-wireframe-rendering-using-ddx-and-ddy/
	 * http://volgogradetzzz.blogspot.com/2012/06/wireframe-shader.html 
	 * @author lizhi
	 */
	[SWF(frameRate=60,width=400,height=400)]
	public class Agal2Drawline extends Sprite 
	{
		private var ibuf:IndexBuffer3D;
		private var context:Context3D;
		private var modelMatr:Matrix3D = new Matrix3D;
		private var tempMatr:Matrix3D = new Matrix3D;
		public function Agal2Drawline():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, stage_context3dCreate);
			stage.stage3Ds[0].requestContext3D(Context3DRenderMode.AUTO,Context3DProfile.STANDARD);
		}
		
		private function stage_context3dCreate(e:Event):void 
		{
			context = stage.stage3Ds[0].context3D;
			
			var program:Program3D = context.createProgram();
			var assembler:AGALMiniAssembler = new AGALMiniAssembler;
			var max:int = 1000;
			var c:int = max;
			var time:int = getTimer();
			while(c-->0){
			var vshader:FlShader = new VShader;
			var fshader:FlShader = new FShader;
			var vcode:String = vshader.code;
			var fcode:String = fshader.code;
			}
			trace(getTimer()-time);
			/*trace("vcode");
			trace(vcode);
			trace("fcode");
			trace(fcode);*/
			c = max;
			time = getTimer();
			while(c-->0){
			assembler.assemble(Context3DProgramType.VERTEX,
					vcode
					,2
				),
				assembler.assemble(Context3DProgramType.FRAGMENT,
					fcode
					,2
				)
			}
			trace(getTimer()-time);
			program.upload(
				assembler.assemble(Context3DProgramType.VERTEX,
					vcode
					,2
				),
				assembler.assemble(Context3DProgramType.FRAGMENT,
					fcode
					,2
				)
			);
			
			//pos
			var posVData:Vector.<Number> = Vector.<Number>([
				0, 0, 0,
				.5, .5, 0,
				0, .5, 0
				]);
			var posVBuf:VertexBuffer3D = context.createVertexBuffer(posVData.length/3, 3);
			posVBuf.uploadFromVector(posVData, 0, posVData.length/3);
			
			//tp target position
			var tpVData:Vector.<Number> = Vector.<Number>([
				1, 0, 0,
				0, 1, 0,
				0, 0, 1
				]);
			var tpVBuf:VertexBuffer3D = context.createVertexBuffer(tpVData.length/3, 3);
			tpVBuf.uploadFromVector(tpVData, 0, tpVData.length/3);
			
			
			
			var idata:Vector.<uint> = Vector.<uint>(
				[0,1,2]
			);
			ibuf = context.createIndexBuffer(idata.length);
			ibuf.uploadFromVector(idata, 0, idata.length);
			
			context.configureBackBuffer(400, 400, 0);
			context.setCulling(Context3DTriangleFace.NONE);
			context.enableErrorChecking = true;
			context.setProgram(program);
			context.setVertexBufferAt(0, posVBuf, 0, Context3DVertexBufferFormat.FLOAT_3);
			context.setVertexBufferAt(1, tpVBuf, 0, Context3DVertexBufferFormat.FLOAT_3);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([1, 2, 3, .5]));
			
			
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		private function enterFrame(e:Event):void 
		{
			//modelMatr.appendRotation(1, Vector3D.X_AXIS);
			modelMatr.appendRotation(2, Vector3D.Z_AXIS);
			modelMatr.appendRotation(2, Vector3D.Y_AXIS);
			tempMatr.copyFrom(modelMatr);
			tempMatr.appendTranslation(0, 0, 1000);
			tempMatr.appendScale(1,1, 1 / 5000);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, tempMatr, true);
			context.clear();
			context.drawTriangles(ibuf);
			context.present();
		}
		
		private function logByte(byte:ByteArray):void {
			var arr:Array = [];
			for (var i:int = 0; i < byte.length;i++ ) {
				arr.push(byte[i])
			}
			trace("logByte");
			trace("len",byte.length);
			trace(arr);
		}
		
	}
	
}
import flash.display3D.Context3DProgramType;
import flShader.FlShader;
import flShader.Var;

class VShader extends FlShader {
	public function VShader() 
	{
		super(Context3DProgramType.VERTEX);
		m44(VA(), C(), op);
		mov(VA(1), null, V());
	/*	"m44 op,va0,vc0\n"
		+"mov v0 va1"*/
	}
}

class FShader extends FlShader {
	public function FShader() 
	{
		super(Context3DProgramType.FRAGMENT);
		var v0:Var = V();
		var fc0:Var = C();
		var fwidth:Var = add(abs(ddx(v0)), abs(ddy(v0)));
		var x:Var = sat(div(v0, fwidth));
		var smoothstep:Var= mul(mul(x, x), sub(fc0.z, mul(fc0.y, x)));
		var c:Var =sub(fc0.x,min(min(smoothstep.x,smoothstep.y),smoothstep.z))
		mov(c.x, null, oc);
		
		/*//fwidth abs( ddx( v ) ) + abs( ddy( v ) );
		"ddx ft0,v0\n"				//ft0 = ddx( v0)
		+"abs ft0,ft0\n"			//ft0 = abs(ft0)
		+"ddy ft1,v0\n"				//ft1 = ddy(v0)
		+"abs ft1,ft1\n"			//ft1 = abs(ft1)
		+"add ft0,ft0,ft1\n"		//ft0 = ft0 + ft1
		
		//smoothstep( float3(0), fwidth( iTP ), iTP );
		//http://en.wikipedia.org/wiki/Smoothstep
		// Scale, bias and saturate x to 0..1 range
		//x = sat((x - edge0)/(edge1 - edge0)); 
		// Evaluate polynomial
		//return x*x*(3 - 2*x);
		
		// edge0 = 0
		// x = sat(x/edge1);
		+"div ft0,v0,ft0\n"			//ft0 = v0 / ft0
		+"sat ft0,ft0\n"			//ft0 = sat(ft0)
		+"mul ft2,fc0.yyy,ft0\n"	//ft2 = 2*ft0		
		+"sub ft2,fc0.zzz,ft2\n"	//ft2 = 3 - ft2
		+"mul ft2,ft0,ft2\n"		//ft2 = ft0 * ft2
		+"mul ft0,ft0,ft2\n"		//ft0 = ft0 * ft2
		
		//float4( 1 - min(min(a3.x, a3.y), a3.z).xxx, 0 ) * 0.5;
		+"min ft0.x,ft0.x,ft0.y\n"
		+"min ft0.x,ft0.x,ft0.z\n"
		+"sub ft0.x,fc0.x,ft0.x\n"
		+"mul ft0.x,ft0.x,fc0.z\n"
		+"mov oc,ft0.xxx",*/
	}
}