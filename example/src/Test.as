package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix3D;
	import flash.geom.Orientation3D;
	import gl3d.core.Drawable;
	import gl3d.core.DrawableSource;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.TextureSet;
	import gl3d.parser.obj.OBJParser;
	import gl3d.util.Utils;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Test extends BaseExample
	{
		
		public function Test() 
		{
		}
		
		override public function initNode():void 
		{
			var obj:String =
			<![CDATA[
# Blender v2.73 (sub 0) OBJ File: ''
# www.blender.org
mtllib untitled.mtl
o Cube
v 1.000000 -1.000000 -1.000000
v 1.000000 -1.000000 1.000000
v -1.000000 -1.000000 1.000000
v -1.000000 -1.000000 -1.000000
v 1.000000 1.000000 -0.999999
v 0.999999 1.000000 1.000001
v -1.000000 1.000000 1.000000
v -1.000000 1.000000 -1.000000
vt 0.000000 0.000000
vt 1.000000 0.000000
vt 1.000000 1.000000
vt 0.000000 1.000000
usemtl Material
s off
f 1/1 2/2 3/3 4/4
f 5/1 8/2 7/3 6/4
f 1/1 5/2 6/3 2/4
f 2/1 6/2 7/3 3/4
f 3/1 7/2 8/3 4/4
f 5/1 1/2 4/3 8/4
			]]>;
			var objp:OBJParser = new OBJParser(obj,true);
			view.scene.addChild(objp.target);
			objp.target.children[0].material.diffTexture = texture;
		}
	}

}