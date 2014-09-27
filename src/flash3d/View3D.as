package flash3d {
	import flash.display.Graphics;
	import flash.geom.Point;
	/**
	 * ...
	 * @author lizhi
	 */
	public class View3D 
	{
		public var nodes:Vector.<Node3D> = new Vector.<Node3D>;
		public var fl:Number = 3;
		public var scale:Number = 100;
		public var offset:Point = new Point(200, 200);
		public function View3D() 
		{
			
		}
		
		public function render(g:Graphics):void {
			g.clear();
			g.lineStyle(0);
			var faces:Array = [];
			for each(var node:Node3D in nodes) {
				for each(var face:Face3D in node.fs) {
					face.out.length = face.vs.length;
					face.scale = 0;
					for (var i:int = 0; i < face.vs.length;i++ ) {
						var vc:V3D = face.vs[i].clone();
						vc.x *= node.scale.x;
						vc.y *= node.scale.y;
						vc.z *= node.scale.z;
						vc.rot(node.rot.x, node.rot.y, node.rot.z);
						vc.x += node.pos.x;
						vc.y += node.pos.y;
						vc.z += node.pos.z;
						vc.w = scale / (vc.z + fl);
						vc.x *= vc.w;
						vc.y *= vc.w;
						vc.x += offset.x;
						vc.y += offset.y;
						face.scale+= vc.w;
						face.out[i] = vc;
						g.drawCircle(vc.x, vc.y, vc.w / 10);
					}
					faces.push(face);
				}
			}
			faces.sortOn("scale", Array.NUMERIC);
			for each(face in faces) {
				for (i = 0; i < face.ins.length;i+=3 ) {
					var v0:V3D = face.out[face.ins[i]];
					var v1:V3D = face.out[face.ins[i+1]];
					var v2:V3D = face.out[face.ins[i + 2]];
					g.beginFill(face.color,.5);
					g.moveTo(v0.x, v0.y);
					g.lineTo(v1.x, v1.y);
					g.lineTo(v2.x, v2.y);
					g.lineTo(v0.x, v0.y);
				}
			}
		}
		
	}

}