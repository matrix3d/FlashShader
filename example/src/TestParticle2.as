package 
{
	import flash.display.BlendMode;
	import flash.geom.Vector3D;
	import gl3d.core.Drawable;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.meshs.Meshs;
	import gl3d.meshs.Teapot;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestParticle2 extends BaseExample
	{
		
		public function TestParticle2() 
		{
			
		}
		
		override public function initNode():void 
		{
			
			var shape:Drawable = Meshs.plane(.005);//Meshs.cube(.1,.1,.1)//Teapot.teapot();
			var pvshape:Drawable = Teapot.teapot(10);
			view.scene.addChild(craeteParticle(shape,pvshape,pvshape.pos.data.length/3));
		}
		
		private function craeteParticle(shape:Drawable,pvshape:Drawable,count:int):Node3D 
		{
			var node:Node3D = new Node3D;
			node.randomTime = true;
			//node.scaleFromTo = new Vector3D(10.2, 1);
			material = new Material;
			material.blendMode = BlendMode.ADD;
			material.isBillbard = true;
			material.isStretched = false;
			node.material = material;
			//node.setScale(.1, .1, .1);
			
			var newpos:Vector.<Number> = new Vector.<Number>;
			var newpvpos:Vector.<Number> = new Vector.<Number>;
			var newpvnorm:Vector.<Number> = new Vector.<Number>;
			var newindex:Vector.<uint> = new Vector.<uint>;
			
			var slen:int = shape.pos.data.length / 3;
			var ilen:int = shape.index.data.length;
			for (var i:int = 0; i < count;i++ ){
				for (var j:int = 0; j < slen; j++ ){
					newpos[(i*slen+j)*3]=(shape.pos.data[j*3]);
					newpos[(i*slen+j)*3+1]=(shape.pos.data[j*3+1]);
					newpos[(i * slen + j) * 3 + 2] = (shape.pos.data[j * 3 + 2]);
					
					newpvpos[(i * slen + j) * 3] = pvshape.pos.data[(i*3)%pvshape.pos.data.length];
					newpvpos[(i * slen + j) * 3+1] = pvshape.pos.data[(i*3+1)%pvshape.pos.data.length];
					newpvpos[(i * slen + j) * 3 + 2] = pvshape.pos.data[(i * 3 + 2) % pvshape.pos.data.length];
					
					newpvnorm[(i * slen + j) * 3] = pvshape.norm.data[(i*3)%pvshape.pos.data.length]/3;
					newpvnorm[(i * slen + j) * 3+1] = pvshape.norm.data[(i*3+1)%pvshape.pos.data.length]/3;
					newpvnorm[(i * slen + j) * 3+2] = pvshape.norm.data[(i*3+2)%pvshape.pos.data.length]/3;
				}
				for (j = 0; j < ilen;j++ ){
					newindex[i * ilen + j] = shape.index.data[j]+slen*i;
				}
			}
			node.drawable = Meshs.createDrawable(newindex, newpos);
			node.drawable.randomStep = slen;
			node.posVelocityDrawable = Meshs.createDrawable(newindex, newpvpos, null, newpvnorm);
			node.posVelocityDrawable.autoNormal = false;
			return node;
		}
	}

}