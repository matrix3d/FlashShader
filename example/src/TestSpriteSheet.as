package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import gl3d.core.Camera3D;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.TextureSet;
	import gl3d.meshs.Meshs;
	import gl3d.meshs.Teapot;
	import gl3d.util.Matrix3DUtils;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestSpriteSheet extends BaseExample
	{
		private var c2d:Camera3D=new Camera3D;
		private var node:Node3D = new Node3D;
		private var shadowNode:Node3D = new Node3D;
		private var quatShadowNode:Node3D = new Node3D;
		private var quat:Node3D;
		private var obj:Object;
		private var p:Number = 0;
		private var loader:Loader;
		private var cube:Node3D;
		public function TestSpriteSheet() 
		{
			
		}
		override protected function stage_resize(e:Event = null):void 
		{
			super.stage_resize(e);
			c2d.perspective.orthoOffCenterLH( 0, stage.stageWidth, 0, stage.stageHeight, -1000, 1000);
		}
		override public function initNode():void 
		{
			cube = new Node3D;
			cube.y = .5;
			cube.drawable = Teapot.teapot();
			cube.material = new Material;
			view.scene.addChild(cube);
			shadowNode = new Node3D;
			shadowNode.material = cube.material;
			shadowNode.drawable = cube.drawable;
			view.scene.addChild(shadowNode);
			
			[Embed(source = "assets/fight.dat", mimeType = "application/octet-stream")]var c:Class;
			var b:ByteArray = new c as ByteArray;
			b.inflate();
			obj = b.readObject();
			var bmd:Object = obj.info.tex;
			view.background = 0x999999;
			quat = new Node3D;
			quat.material = new Material;
			quat.material.uvMuler = [.5, .5];
			quat.material.uvAdder = [.5, .5];
			quat.material.materialCamera = c2d;
			quat.material.lightAble = false;
			quat.material.castShadow = false;
			view.scene.addChild(quatShadowNode);
			view.scene.addChild(node);
			node.addChild(quat);
			
			quat.material.diffTexture = new TextureSet(bmd, false,true, false, false,true,null);
			quat.material.blendModel = BlendMode.LAYER;
			var r:Number = 1;
			var vs:Vector.<Number> = Vector.<Number>([0, 0, 0, r, 0, 0, 0, r, 0, r, r, 0]);
			var uv:Vector.<Number> = Vector.<Number>([0, 1, 1, 1, 0, 0, 1, 0]);
			var ins:Vector.<uint>=Vector.<uint>([0, 1, 2, 1, 3, 2]);
			quat.drawable = Meshs.createDrawable(ins, vs, uv);
			
			//quatShadowNode.drawable = quat.drawable;
			//quatShadowNode.material = quat.material;
			//quatShadowNode.material = new Material;
			//quatShadowNode.material.materialCamera = c2d;
			
		}
		
		override public function enterFrame(e:Event):void 
		{
			node.x = mouseX;
			node.y = stage.stageHeight - mouseY;
			if(quat){
				if (int(p)>=(obj.ts.length)){
					p = 0;
				}
				var t:Object = obj.ts[int(p)];
				p += .1;
				quat.scaleX = t.w;
				quat.scaleY = t.h;
				quat.material.uvMuler[0] = t.w / obj.info.tw;
				quat.material.uvMuler[1] = t.h / obj.info.th;
				quat.material.uvAdder[0] = t.x / obj.info.tw;
				quat.material.uvAdder[1] = t.y / obj.info.th;
				quat.x = t.fx - obj.info.w / 2;
				quat.y = -t.h -t.fy + obj.info.h / 2;
			}
			
			//cube.y = (mouseY / stage.stageWidth - .5)*10
			
			var light:Vector3D = new Vector3D(1, 2, -3);
			light.normalize();
			//var proj:Vector.<Number> = makeShadowProj(light, new Vector3D(0,40,40),light);
			var proj:Vector.<Number> = shadow(new Vector3D(0,1,0,.8),light);
			var matr:Matrix3D = new Matrix3D(proj);
			matr.prepend(cube.world);
			shadowNode.matrix = matr;
			
			matr = new Matrix3D(proj);
			matr.prepend(quat.world);
			quatShadowNode.world = matr;
			super.enterFrame(e);
		}
		/**
		 * @see ftp://ftp.sgi.com/opengl/contrib/blythe/advanced99/notes/node192.html
		 * @param	p
		 * @param	l
		 * @return
		 */
		public static function shadow(p:Vector3D,l:Vector3D):Vector.<Number>{
			var d:Number = p.x * l.x + p.y * l.y + p.z * l.z + p.w * l.w;
			return new <Number>[
			-p.x * l.x + d  ,-p.x * l.y      ,-p.x * l.z      ,-p.x * l.w  ,
			-p.y * l.x      ,-p.y * l.y + d  ,-p.y * l.z      ,-p.y * l.w  ,
			-p.z * l.x      ,-p.z * l.y      ,-p.z * l.z + d  ,-p.z * l.w  ,
			-p.w * l.x      ,-p.w * l.y      ,-p.w * l.z      ,-p.w * l.w + d
			];
		}
	}
}