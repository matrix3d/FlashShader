package 
{
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import gl3d.core.Light;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.TextureSet;
	import gl3d.core.shaders.GLShader;
	import gl3d.meshs.Meshs;
	import gl3d.meshs.Teapot;
	import gl3d.util.Stats;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestShader extends BaseExample
	{
		private var cube:Node3D;
		public function TestShader() 
		{
		}
		
		
		override public function initNode():void 
		{
			addChild(new Stats(view));
			addSky();
			/*var m:Matrix3D = new Matrix3D;
			m.appendScale(100, 100, 100);
			m.appendTranslation(100, 100, 100);
			
			var v:Matrix3D = new Matrix3D;
			v.appendTranslation(0, 0, -100);
			v.invert();
			
			var p:Vector3D = new Vector3D(0,0,100);
			var mp:Vector3D = m.transformVector(p);
			trace(mp);
			trace(mp.subtract(new Vector3D(0,0,-100)));
			var camera2light:Vector3D = v.transformVector(m.transformVector(p));
			trace(camera2light);
			
			return*/
			
			view.background = 0x999999;
			cube = new Node3D;
			cube.drawable = 
			//Meshs.cube();
			Meshs.sphere(15,15,3)
			//Teapot.teapot();
			cube.material = new Material(new MyShader());
			cube.material.normalMapAble = true;
			
			[Embed(source = "assets/stoneBlocksNormal.png")]var normalc:Class;
			
			cube.material.normalmapTexture = new TextureSet((new normalc as Bitmap).bitmapData);
			
			view.scene.addChild(cube);
		}
		
		override public function enterFrame(e:Event):void 
		{
			cube.rotationY+=.3;
			//cube.rotationX+=.5;
			super.enterFrame(e);
		}
		
	}

}

	import as3Shader.AS3Shader;
	import as3Shader.Var;
	import flash.display3D.Context3DProgramType;
	import gl3d.core.Light;
	import gl3d.core.shaders.GLAS3Shader;
	import gl3d.core.Material;
	import gl3d.core.shaders.GLShader;
	import gl3d.shaders.PhongGLShader;
	import gl3d.shaders.PhongVertexShader;
	/**
	 * ...
	 * @author lizhi
	 */
	class MyShader extends GLShader
	{
		public function MyShader() 
		{
		}
		
		override public function getFragmentShader(material:Material):GLAS3Shader {
			return new MyFragmentShader(material,vs as MyVertexShader);
		}
		
		override public function getVertexShader(material:Material):GLAS3Shader 
		{
			return new MyVertexShader(material);
		}
	}
	
	//光照
	class MyVertexShader extends GLAS3Shader
	{
		private var material:Material;
		public var lightVary:Var;
		public var normalVary:Var;
		public var viewVary:Var;
		public var uvVary:Var;
		public function MyVertexShader(material:Material) 
		{
			
			super(Context3DProgramType.VERTEX);
			this.material = material;
		}

		override public function build():void 
		{
			var m:Var = uniformModel();
			var v:Var = uniformView();
			var p:Var = uniformPerspective();
			
			var pos:Var = buffPos();
			var mpos:Var = m44(pos, m);
			var vpos:Var = m44(mpos, v);
			var ppos:Var = m44(vpos, p);
			
			op = ppos;
			
			lightVary = varying();
			if(!material.normalMapAble){
				normalVary = varying();
			}
			viewVary = varying();
			
			var lightPos:Var = uniformLightPos(0);
			var normal:Var = buffNorm();
			
			var lightVec:Var= nrm(sub(lightPos, mpos));
			var viewVec:Var = nrm(neg(vpos));
			var normalWorld:Var= nrm(m33(normal, m));
			
			if (material.normalMapAble){
				var tangent:Var = nrm(m33(buffTangent(),m));
				var binormal:Var = nrm((crs(tangent, normalWorld)));
				lightVec = vec3(dp3(lightVec,tangent),dp3(lightVec,binormal),dp3(lightVec,normalWorld));
				viewVec = vec3(dp3(viewVec, tangent), dp3(viewVec, binormal), dp3(viewVec, normalWorld));
				uvVary = varying();
				mov(buffUV(), uvVary);
			}
			
			mov(lightVec, lightVary);
			mov(viewVec, viewVary);
			if(!material.normalMapAble){
				mov(normalWorld, normalVary);
			}
		}
	}
	class MyFragmentShader extends GLAS3Shader
	{
		private var vs:MyVertexShader;
		private var material:Material;
		public function MyFragmentShader(material:Material,vs:MyVertexShader) 
		{
			super(Context3DProgramType.FRAGMENT);
			this.material = material;
			this.vs = vs;
		}

		override public function build():void 
		{
			if (material.normalMapAble){
				var normapMap:Var = tex(mul(vs.uvVary,5), samplerNormalmap(), null, material.normalmapTexture.flags);
				normapMap = add(normapMap, normapMap);
				normapMap = sub(normapMap, 1);
				var normal:Var = nrm(normapMap);
			}else{
				normal = vs.normalVary;
			}
			
			//r =2n(n.l)-l;
			var a:Var = mul(normal, dp3(normal, vs.lightVary));
			var reflectedLightVec:Var = sub(add(a,a), vs.lightVary);
			
			var color:Var = sat(dp3(nrm(vs.lightVary), nrm(normal)));
			color=add(color,pow(sat(dp3(nrm(reflectedLightVec), nrm(vs.viewVary))), 100));
			mov(color,oc);
		}
	}
	
	//ddx ddy 法线
	/*class MyVertexShader extends GLAS3Shader
	{
		public var posV:Var;
		public function MyVertexShader() 
		{
			
			super(Context3DProgramType.VERTEX);
			
		}

		override public function build():void 
		{
			var pos:Var=m44(buffPos(), uniformModel())
			op = m44(m44(pos, uniformView()), uniformPerspective());
			
			posV = varying();
			mov(pos, posV);
		}
	}
	class MyFragmentShader extends GLAS3Shader
	{
		private var vs:MyVertexShader;
		public function MyFragmentShader(vs:MyVertexShader) 
		{
			super(Context3DProgramType.FRAGMENT);
			this.vs = vs;
			
		}

		override public function build():void 
		{
			var dx:Var = ddx(vs.posV);
			var dy:Var = ddy(vs.posV);
			var norm:Var = add(mul(nrm(crs(dx, dy)),.5),.5);
			oc = norm;
		}
	}*/
	
	//cell shader
	/*class MyVertexShader extends GLAS3Shader
	{
		public var norm:Var;
		public function MyVertexShader() 
		{
			
			super(Context3DProgramType.VERTEX);
			
		}

		override public function build():void 
		{
			op = m44(m44(m44(buffPos(), uniformModel()), uniformView()), uniformPerspective());
			
			norm = varying();
			var n:Var = nrm(m33(m33(m33(buffNorm(), uniformModel()),uniformView()),uniformPerspective()));
			mov(n, norm);
		}
	}
	class MyFragmentShader extends GLAS3Shader
	{
		private var vs:MyVertexShader;
		
		public function MyFragmentShader(vs:MyVertexShader) 
		{
			super(Context3DProgramType.FRAGMENT);
			this.vs = vs;
			
		}

		override public function build():void 
		{
			sge(abs(dp3(vs.norm,[0,0,1])),.5, oc);
		}
	}*/
	

