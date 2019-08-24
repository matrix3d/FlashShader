package  
{
	import com.bit101.components.PushButton;
	import com.bit101.components.VBox;
	import com.bit101.components.Window;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.net.FileReference;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.ByteArray;
	import gl3d.ctrl.FirstPersonCtrl;
	import gl3d.parser.hlbsp.Bsp;
	import gl3d.parser.hlbsp.BspFace;
	import gl3d.parser.hlbsp.BspMipTexture;
	import gl3d.parser.hlbsp.BspRender;
	import gl3d.parser.hlbsp.BspRenderNode;
	import gl3d.parser.hlbsp.Movement;
	import gl3d.parser.hlbsp.Wad;
	import gl3d.parser.q3bsp.Q3BSP;
	import gl3d.parser.q3bsp.render.PreRender;
	/**
	 * ...
	 * @author lizhi
	 */
	[SWF(backgroundColor='0xffffff',width='800',height='600')]
	public class TestBsp extends BaseExample
	{
		private var bsp:BspRenderNode;
		private var movement:Movement;
		private var image:Bitmap;
		private var file:FileReference = new FileReference;
		private var loadtype:int = 0;
		public function TestBsp() 
		{
			
		}
		
		override public function initNode():void {
			addSky();
			//[Embed(source = "assets/webgl.bsp", mimeType = "application/octet-stream")]var c:Class;
			[Embed(source = "assets/fy_iceworld.bsp", mimeType = "application/octet-stream")]var c:Class;
			//[Embed(source = "assets/de_dust2.bsp", mimeType = "application/octet-stream")]var c:Class;
			dobsp(new c as ByteArray);
			
			//[Embed(source = "assets/webgl.wad", mimeType = "application/octet-stream")]var tc:Class;
			/*[Embed(source = "assets/de_vegas.wad", mimeType = "application/octet-stream")]var tc:Class;
			var wad:Wad = new Wad;
			wad.open(new tc as ByteArray);
			bsp.bsp.loadedWads.push(wad);
			bsp.bsp.loadMissingTextures();*/
			
			//addChild(new Bitmap(wad.loadTexture("{webgl")));
			
			speed = .3;
			movementFunc = playerMove;
			
			/*[Embed(source = "assets/cityrush.bsp", mimeType = "application/octet-stream")]var q3c:Class;
			doq3bsp(new q3c as ByteArray);*/
		}
		
		override public function initCtrl():void 
		{
			fc = new FirstPersonCtrl(view.camera, stage);
			fc.speed = speed;
			fc.movementFunc = movementFunc;
			view.ctrls.push(fc);
		}
		
		public function playerMove(start:Vector3D, end:Vector3D):Vector3D
		{
			var model:Matrix3D = bsp.world.clone();
			model.invert();
			return bsp.world.transformVector(movement.playerMove(model.transformVector(start),model.transformVector(end)));
		}
		
		override public function initUI():void {
			super.initUI();
			//if (aui.parent) aui.parent.removeChild(aui);
			
			resetTexMenu();
			image = new Bitmap;
			image.x = 130;
			addChild(image);
			
			var vbox:VBox = new VBox(this, 5, 5);
			new PushButton(vbox, 0, 0, "loadbsp", loadbsp);
			new PushButton(vbox, 0, 0, "loadwad", loadwad);
			new PushButton(vbox, 0, 0, "tojson", function():void{
				var obj:Array = bsp.render.toOBJ();
				var fr:FileReference = new FileReference;
				fr.save(obj[0], "test.obj");
			});
			file.addEventListener(Event.SELECT, file_select);
			file.addEventListener(Event.COMPLETE, file_complete);
		}
		
		private function item_menuItemSelect(e:ContextMenuEvent):void 
		{
			var item:ContextMenuItem = e.currentTarget as ContextMenuItem;
			for (var i:int = 0; i < bsp.bsp.mipTextures.length;i++ ) {
				var b:BspMipTexture = bsp.bsp.mipTextures[i];
				if (b.name==item.caption) {
					image.bitmapData = bsp.bsp.textureLookup[i];
					return;
				}
			}
			if(bsp.bsp.lightmapLookup[item.caption])
			image.bitmapData = bsp.bsp.lightmapLookup[item.caption];
		}
		
		private function resetTexMenu():void {
			try{
				var con:ContextMenu = new ContextMenu;
				for each(var b:BspMipTexture in bsp.bsp.mipTextures) {
					var item:ContextMenuItem = new ContextMenuItem(b.name);
					con.customItems.push(item);
					item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, item_menuItemSelect);
				}
				for (var i:int = 0; i < bsp.bsp.faces.length;i++ ) {
					item = new ContextMenuItem(i+"");
					con.customItems.push(item);
					item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, item_menuItemSelect);
				}
				contextMenu = con;
			}catch(err:Error){}
		}
		
		private function loadbsp(e:Event):void {
			loadtype = 0;
			file.browse();
		}
		private function loadwad(e:Event):void {
			loadtype = 1;
			file.browse();
		}
		
		
		private function file_complete(e:Event):void 
		{
			var byte:ByteArray = file.data;
			if (loadtype==0) {//bsp
				dobsp(byte);
			}else {//wad
				dowad(byte);
			}
		}
		
		private function dobsp(b:ByteArray):void {
			if (bsp) {
				var ts:Array = bsp.bsp.loadedWads;
				if (bsp.parent) {
					bsp.parent.children.splice(bsp.parent.children.indexOf(bsp), 1);
				}
			}
			bsp = new BspRenderNode(b, view,true);
			view.scene.addChild(bsp);
			bsp.scaleX = bsp.scaleY = bsp.scaleZ = .1;
			bsp.scaleX *= -1;
			bsp.setRotation(-90,  0,0);
			if (ts) {
				bsp.bsp.loadedWads = bsp.bsp.loadedWads.concat(ts);
			}
			movement = movement || new Movement(null);
			movement.bsp = bsp.bsp;
			
			view.camera.z = view.camera.x = view.camera.y = 0;
			resetTexMenu();
		}
		
		private function doq3bsp(b:ByteArray):void {
			var pre:PreRender = new PreRender(new Q3BSP(b));
			view.scene.addChild(pre.target);
			view.camera.z = view.camera.x = view.camera.y = 0;
			
			pre.target.scaleX = pre.target.scaleY = pre.target.scaleZ = .1;
			pre.target.scaleX *= -1;
			pre.target.setRotation(  90,0,0);
		}
		
		private function dowad(b:ByteArray):void {
			var wad:Wad = new Wad;
			wad.open(b);
			bsp.bsp.loadedWads.push(wad);
			bsp.bsp.loadMissingTextures();
		}
		
		private function file_select(e:Event):void 
		{
			file.load();
		}
		
		override public function enterFrame(e:Event):void
		{
			super.enterFrame(e);
		}
		
	}

}