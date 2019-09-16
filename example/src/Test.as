package 
{
	import com.bit101.utils.MinimalConfigurator;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import gl3d.core.InstanceMaterial;
	import gl3d.core.Light;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.View3D;
	import gl3d.ctrl.ArcBallCtrl;
	import gl3d.meshs.Meshs;
	import flash.events.Event;
	import gl3d.meshs.Teapot;
	import gl3d.parser.a3ds.A3DSParser;
	import gl3d.util.Stats;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Test extends Sprite
	{
		public function Test() 
		{
			onChange();
		}
		public function onChange(a:String="dddd") : void
		{
			trace(a);
		}
	}

}