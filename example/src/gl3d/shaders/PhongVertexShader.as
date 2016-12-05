package gl3d.shaders 
{
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.Texture;
	import as3Shader.AS3Shader;
	import as3Shader.Var;
	import gl3d.core.Fog;
	import gl3d.core.Light;
	import gl3d.core.shaders.GLAS3Shader;
	import gl3d.core.Material;
	import gl3d.core.TextureSet;
	import gl3d.core.skin.SkinAnimation;
	/**
	 * ...
	 * @author lizhi
	 */
	public class PhongVertexShader extends GLAS3Shader
	{
		private var material:Material;
		public var model:Var //= matrix();
		public var world2local:Var //= matrix();
		public var view:Var //= matrix();
		public var perspective:Var //= matrix();
		//public var lightPos:Var //= uniform();
		public var joints:Var;
		
		
		public var pos:Var //= buff();
		public var norm:Var //= buff();
		public var uv:Var //= buff();
		public var tangent:Var //= buff();
		public var targetPosition:Var //= buff();
		public var weight:Var //= buff();
		public var joint:Var //= buff();
		//public var weight2:Var //= buff();
		//public var joint2:Var //= buff();
		
		public var eyeDirectionVarying:Var = varying();
		public var posLightVaryings:Vector.<Var> = new Vector.<Var>;
		public var shadowLightPoss:Vector.<Var> = new Vector.<Var>;
		public var normVarying:Var = varying();
		public var tangentVarying:Var = varying();
		public var uvVarying:Var = varying();
		public var targetPositionVarying:Var = varying();
		public var reflected:Var = varying();
		public var modelPosVarying:Var = varying();
		public var opVarying:Var = varying();
		public function PhongVertexShader(material:Material) 
		{
			super(Context3DProgramType.VERTEX);
			this.material = material;
			
			pos = buffPos();
			norm = buffNorm();
			uv = buffUV();
			tangent = buffTangent();
			targetPosition = buffTargetPosition();
			weight = buffWeights();
			
			model = uniformModel();
			world2local = uniformWorld2Local();
			view = uniformView();
			perspective = uniformPerspective();
		}
		
		override public function build():void {
			var norm:Var = this.norm;
			var pos:Var = mov(this.pos);
			if (material.gpuSkin) {
				if (material.node.skin.useQuat) {
					joint = buffJoints();
					if (!material.node.skin.useHalfFloat){
						joint = mul(2,buffJoints());
					}
					joints = uniformJointsQuat(material.node.skin.joints.length,material.node.skin.useHalfFloat);
				}else {
					joint = mul(4,buffJoints());
					joints = uniformJointsMatrix(material.node.skin.joints.length);
				}
				var xyzw:String = "xyzw";
				for (var i:int = 0; i < material.node.skin.maxWeight; i++ ) {
					var c:String = xyzw.charAt(i % 4);
					var jw:Var = weight.c(c);
					if (material.node.skin.useQuat) {
						joint = joint.c(c);
						if (material.node.skin.useHalfFloat){
							var v:Var = mov(joints.c(joint));
							var h:Var = mul(v, SkinAnimation.sh);
							var l:Var = frc(h);
							h = sub(h, l);
							var jqt:Var = sub(mul(h, 40 / SkinAnimation.sh), 20);
							var jq:Var = sub(mul(l, 2 ), 1);
						}else{
							jq = joints.c(joint);
							jqt = joints.c(joint, 1);
						}
						var value:Var = mul(jw, q44(pos, jq,jqt));
					}else {
						joint = joint.c(c);
						var jm:Var = joints.c(joint);
						value = mul(jw, m44(pos, jm));
					}
					
					if (i==0) {
						var result:Var = value;
					}else {
						result = add(result, value);
					}
					if(material.lightAble){
						var valueNorm:Var = mul(jw, material.node.skin.useQuat?q33(norm,mov(jq)):m33(norm, jm));
						if (i==0) {
							var resultNorm:Var = valueNorm;
						}else {
							resultNorm = add(resultNorm, valueNorm);
						}
					}
				}
				pos = result;
				if (material.lightAble) {
					norm = nrm(resultNorm);
				}
			}
			
			if (material.node.scaleFromTo||(material.node.posVelocityDrawable&&material.node.posVelocityDrawable.norm)){
				var time:Var = div(sub(uniformTime(), mov(material.node.startTime)), material.node.lifeTimeRange.x);
				if (material.node.randomTime){
					add(time.x, buffRandom().w, time.x);
				}
				frc(time.x,time);
			}
			if (material.node.scaleFromTo){
				var size:Var = add(material.node.scaleFromTo.x, mul(time, material.node.scaleFromTo.y - material.node.scaleFromTo.x))
				mul(pos.xyz, size,pos.xyz);
			}
			//粒子位置和速度，放弃复杂的算法，直接用2个buff来实现，加速度，贝塞尔曲线用2个常量表示
			//曲线 颜色，缩放，速度
			
			if (material.node.posVelocityDrawable && material.node.posVelocityDrawable.norm){
				var velocity:Var = buffParticleNorm();
			}
			if(material.isBillbard){
				if (material.node.posVelocityDrawable && material.node.posVelocityDrawable.pos){
					var ppos:Var = mov(buffParticlePos());
				}else{
					ppos = mov([0,0,0,1]);
				}
				if (velocity){
					add(ppos.xyz, mul(time,velocity), ppos.xyz);
				}
				var worldPos:Var = m44(ppos, model);
				var viewPos:Var = m44(worldPos.xyzw, view);
				
				if (material.isStretched && velocity){
					var v2:Var = mul(velocity, velocity);
					var l2:Var = sqt(add(v2.x, v2.y));
					var nv:Var = div(velocity.xy, l2);
					var smy:Var = mul(pos.xyxy, nv.xyyx);
					var pos2:Var = mov([0, 0]);
					sub(smy.x, smy.y,pos2.x);
					add(smy.z, smy.w, pos2.y);
					//add(mul(10,pos2.xy),pos.xy,pos.xy);
					mul(10,pos2.xy,pos.xy);
					//add(pos.xyz,mul(1,q33(pos.xyz, velocity)).xyz,pos.xyz);
					//add(pos.xyz, mul2([pos.xyz,velocity.xyz, 100]), pos.xyz);
				}
				
				m33(pos.xyz, model, worldPos.xyz);
				add(viewPos.xyz, worldPos, viewPos.xyz);
			}else{
				//if (material.isStretched&&velocity){
				//	add(pos.xyz, mul2([pos.xyz,velocity.xyz, 100]), pos.xyz);
				//}
				if (material.node.posVelocityDrawable && material.node.posVelocityDrawable.pos){
					add(buffParticlePos().xyz, pos.xyz, pos.xyz);
				}
				if (velocity){
					add(pos.xyz, mul(time,velocity), pos.xyz);
				}
				worldPos = m44(pos, model);
				viewPos = m44(worldPos, view);
			}
			var opVar:Var = m44(viewPos, perspective);
			op = opVar;
			
			if (material.lightAble||material.reflectTexture) {
				var worldNorm:Var = nrm(m33(norm, model));
				if(material.specularAble||material.reflectTexture){
					if (material.normalMapAble) {
						var eyeDirection:Var = nrm(m33(neg(viewPos),world2local));
					}else {
						eyeDirection = nrm(neg(viewPos));
					}
					mov(eyeDirection, eyeDirectionVarying);
				}
				shadowLightPoss.length = material.view.lights.length;
				for (i = 0; i < material.view.lights.length; i++ ) {
					var light:Light = material.view.lights[i];
					var lightPos:Var = uniformLightPos(i);
					if (material.normalMapAble) {
						var posLight:Var = nrm(m33(sub(m44(mov(lightPos),view), viewPos),world2local));
					}else {
						posLight = nrm(sub(m44(mov(lightPos),view), viewPos));
					}
					var posLightVarying:Var = varying();
					posLightVaryings.push(posLightVarying);
					mov(posLight, posLightVarying);
					
					if (light.shadowMapEnabled&&material.receiveShadows) {
						var shadowLightPosVarying:Var = varying();
						shadowLightPoss[i] = shadowLightPosVarying;
						mov(m44(worldPos,uniformLightShadowCameraWorld(i)),shadowLightPosVarying);
					}
				}
				
				if (material.normalMapAble) {
					mov(nrm(m33(m33(worldNorm,view),world2local)),normVarying);
				}else {
					var viewNormal:Var = nrm(m33(worldNorm,view));
					mov(viewNormal, normVarying);
				}
				
				if (material.normalMapAble) {
					mov(tangent,tangentVarying)
				}
				if (material.reflectTexture) {
					var w2c:Var = nrm(sub(worldPos, uniformCameraPos()));
					//r=2n(n.l)-l
					mov(sub(w2c,mul2([2, worldNorm,dp3(worldNorm,w2c)])),reflected);
				}
			}
			
			if (material.diffTexture || material.normalMapAble) {
				var uv2:Var = uv;
				if (material.uvMuler){
					uv2 = mul(uniformUVMulAdder().xy, uv2);
				}
				if (material.uvAdder){
					uv2 = add(uniformUVMulAdder().zw, uv2);
				}
				mov(uv2, uvVarying);
			}
			if (material.wireframeAble) {
				mov(targetPosition,targetPositionVarying);
			}
			
			var needModelPos:Boolean = false;
			if(material.lightAble){
				for each(light in material.view.lights) {
					if (light.lightType==Light.POINT||light.lightType==Light.SPOT) {
						needModelPos = true;
					}
				}
			}
			if(material.fogAble){
				if (material.view.fog.mode!=Fog.FOG_NONE||needModelPos) {
					mov(worldPos, modelPosVarying);
				}
			}
			
			if (material.writeDepth) {
				mov(opVar, opVarying);
			}
		}
	}

}