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
		private var nodes:Array=[];
		public function TestShader() 
		{
		}
		
		
		override public function initNode():void 
		{
			view.background = 0x999999;
			//[Embed(source = "assets/stoneBlocksNormal.png")]
			//[Embed(source="assets/normal.png")]
			[Embed(source="assets/WxkHQ.jpg")]
			var normalc:Class;
			
			var nt:TextureSet = new TextureSet((new normalc as Bitmap).bitmapData);
			
			var shapes:Array = [Teapot.teapot(), Meshs.cube(2, 2, 2), Meshs.sphere(15, 15, 1)];
			var materials:Array = [];
			var m:Material =new Material(new GLShader(new MyVertexShader,new MyFragmentShader));
			m.normalmapTexture = nt;
			m.reflectTexture = skyBoxTexture;
			materials.push(m);
			m =new Material(new GLShader(new MyVertexShader,new MyFragmentShader));
			m.normalMapAble = true;
			m.normalmapTexture = nt;
			m.reflectTexture = skyBoxTexture;
			materials.push(m);
			m =new Material(new GLShader(new MyVertexShader,new MyFragmentShader));
			m.normalMapAble = true;
			m.normalmapTexture = nt;
			materials.push(m);
			
			for (var i:int = 0; i < shapes.length;i++ ){
				for (var j:int = 0; j < materials.length;j++ ){
					
					var node:Node3D = new Node3D;
					view.scene.addChild(node);
					nodes.push(node);
					node.drawable = shapes[i];
					node.material = materials[j];
					node.x = 3 * (i-(shapes.length-1)/2);
					node.y = 3 * (j - (materials.length - 1) / 2);
					if (i==0){
						node.y -= 1;
						node.setScale(.7, .7, .7);
					}
				}
				
			}
			
			addSky();
		}
		
		override public function enterFrame(e:Event):void 
		{
			for each(var node:Node3D in nodes){
				//node.rotationY += .3;
			}
			//cube.rotationX+=.5;
			super.enterFrame(e);
		}
		
	}

}

	import adobe.utils.CustomActions;
	import as3Shader.AS3Shader;
	import as3Shader.Var;
	import flash.display3D.Context3DProgramType;
	import gl3d.core.Light;
	import gl3d.core.shaders.GLAS3Shader;
	import gl3d.core.Material;
	import gl3d.core.shaders.GLShader;
	import gl3d.shaders.PhongGLShader;
	import gl3d.shaders.PhongVertexShader;
	
	//https://rendermeapangolin.wordpress.com/2015/04/27/ocean-modelisation-gerstner/
	class MyVertexShader extends GLAS3Shader
	{
		public var posV:Var;
		public function MyVertexShader() 
		{
			
			super(Context3DProgramType.VERTEX);
			
		}
		
		public function hfactor(V:Var):Var
		{
			return mul(2 * 0.001 * 7.065 , pow(V, 2.5));
		}

		public function wfactor(V:Var):Var
		{
			return mul(div(9.8 , V) , Math.sqrt(2.0/3.0));
		}

		public function kfactor(V:Var):Var
		{
			var w:Var = wfactor(V);
			return div(mul(w,w),9.8);
		}

		public function main():void
		{
			var dpos:Var = mov(buffPos());
			mul(dpos.xyz, 10, dpos.xyz);
			var windspeed:Var = mov(8);
			var time:Var = div(mov(uniformTime()),1000);
			var h:Var = hfactor(windspeed);
			var k:Var = kfactor(windspeed);
			var w:Var = wfactor(windspeed);

			mov( mul(neg(h) , cos(sub(mul(k,dpos.x) , mul(w,time.x)))),dpos.y);    
			add(dpos.x , mul(h , sin(sub(mul(k,dpos.x) , mul(w,time)))),dpos.x);
		   
			mul(dpos.xyz, 1 / 10, dpos.xyz);
			
			var wpos:Var = m44(dpos, uniformModel());
			var vp:Var = m44(m44( wpos,uniformView()), uniformPerspective());
			mov(vp, op);
			
			posV = varying();
			mov(wpos, posV);
		}
		
		override public function build():void 
		{
			main();
		}
	}
	class MyFragmentShader extends GLAS3Shader
	{
		public function MyFragmentShader() 
		{
			super(Context3DProgramType.FRAGMENT);
		}

		override public function build():void 
		{
			var mvs:MyVertexShader = vs as MyVertexShader;
			var dx:Var = ddx(mvs.posV);
			var dy:Var = ddy(mvs.posV);
			var norm:Var = add(mul(nrm(crs(dx, dy)),.5),.5);
			oc = norm;
		}
	}
	
	//光照
	/*class MyVertexShader extends GLAS3Shader
	{
		public var lightVary:Var;
		public var normalVary:Var;
		public var viewVary:Var;
		public var uvVary:Var;
		public function MyVertexShader() 
		{
			
			super(Context3DProgramType.VERTEX);
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
			var viewVec:Var = nrm(sub(uniformCameraPos(),mpos));
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
		private var mvs:MyVertexShader;
		public function MyFragmentShader() 
		{
			super(Context3DProgramType.FRAGMENT);
		}

		override public function build():void 
		{
			mvs = vs as MyVertexShader;
			var lightVec:Var = nrm(mvs.lightVary);
			var viewVec:Var = nrm(mvs.viewVary);
			if (material.normalMapAble){
				var normapMap:Var = tex(mul(mvs.uvVary,1), samplerNormalmap(), null, material.normalmapTexture.flags);
				normapMap = add(normapMap, normapMap);
				normapMap = sub(normapMap, 1);
				var normal:Var = nrm(normapMap);
			}else{
				normal = nrm(mvs.normalVary);
			}
			
			//r =2n(n.l)-l;
			var reflectedLightVec:Var = mul(normal, dp3(normal, lightVec));
			reflectedLightVec = sub(add(reflectedLightVec,reflectedLightVec), lightVec);
			
			var color:Var = sat(dp3(lightVec, normal));
			color = add(color, pow(sat(dp3(reflectedLightVec, viewVec)), 10));
			
			if (material.reflectTexture){
				//http://developer.download.nvidia.com/CgTutorial/cg_tutorial_chapter07.html
				var cosI:Var = dp3(normal, viewVec);
				var reflectedViewVec:Var = mul(normal, cosI);
				reflectedViewVec = sub(add(reflectedViewVec,reflectedViewVec), viewVec);
				var reflectColor:Var = tex(reflectedViewVec, samplerReflect(), null, material.reflectTexture.flags);
				
				var eta:Number = 1 / 1.3;
				var cosT2:Var = sub(1, mul(eta * eta, (sub(1,add(cosI,cosI)))));
				var t:Var = sub(mul(sub(mul(eta,cosI),sqt(abs(cosT2))),normal),mul(eta,viewVec));
				var refractedVec:Var = mul(t, sge(cosT2, 0));
				var refractColor:Var = tex(refractedVec, samplerReflect(), null, material.reflectTexture.flags);
				
				//reflectColor = mov([1, 0, 0, 1]);
				//refractColor = mov([1, 1, 1, 1]);
				
				color = mix(color,mix(refractColor,reflectColor,mix(.3,1,pow(sub(1,cosI),5))),1);				
			}
			mov(color,oc);
		}
	}*/
	
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
	

