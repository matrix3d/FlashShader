package gl3d.core {
	import flash.display3D.Context3D;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.getQualifiedClassName;
	import gl3d.core.skin.Skin;
	import gl3d.ctrl.Ctrl;
	import gl3d.pick.AS3Picking;
	import gl3d.pick.Picking;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Node3D 
	{
		public var parent:Node3D;
		public var _world:Matrix3D = new Matrix3D;
		public var _world2local:Matrix3D = new Matrix3D;
		public var _matrix:Matrix3D = new Matrix3D;
		public var children:Vector.<Node3D> = new Vector.<Node3D>;
		public var drawable:Drawable3D;
		public var unpackedDrawable:Drawable3D;
		public var material:Material;
		public var name:String;
		public var trs:Vector.<Vector3D> = Vector.<Vector3D>([new Vector3D(), new Vector3D(), new Vector3D(1, 1, 1)]);
		public var picking:Picking = new AS3Picking;
		public var controllers:Vector.<Ctrl>;
		public var skin:Skin;
		public var type:String;
		public var copyfrom:Node3D;
		public function Node3D(name:String=null) 
		{
			this.name = name;
		}
		
		public function addChild(n:Node3D):void {
			if (n.parent) {
				n.parent.removeChild(n);
			}
			children.push(n);
			n.parent = this;
		}
		
		public function removeChild(n:Node3D):void {
			var i:int = children.indexOf(n);
			if (i != -1) children.splice(i, 1);
			n.parent = null;
		}
		
		public function update(view:View3D):void {
			if (controllers) {
				for each(var c:Ctrl in controllers) {
					c.update();
				}
			}
			if (material) {
				material.draw(this,view);
			}
		}
		
		public function get matrix():Matrix3D 
		{
			return _matrix;
		}
		
		public function set matrix(value:Matrix3D):void 
		{
			_matrix.copyFrom(value);
			trs=value.decompose();
		}
		
		public function recompose():void {
			_matrix.recompose(trs);
		}
		
		public function get x():Number 
		{
			return trs[0].x;
		}
		
		public function set x(value:Number):void 
		{
			trs[0].x = value;
			recompose()
		}
		
		public function get y():Number 
		{
			return trs[0].y;
		}
		
		public function set y(value:Number):void 
		{
			trs[0].y = value;
			recompose()
		}
		
		public function get z():Number 
		{
			return trs[0].z;
		}
		
		public function set z(value:Number):void 
		{
			trs[0].z = value;
			recompose()
		}
		
		public function get rotationX():Number 
		{
			return trs[1].x;
		}
		
		public function set rotationX(value:Number):void 
		{
			trs[1].x = value;
			recompose()
		}
		
		public function get rotationY():Number 
		{
			return trs[1].y;
		}
		
		public function set rotationY(value:Number):void 
		{
			trs[1].y = value;
			recompose()
		}
		
		public function get rotationZ():Number 
		{
			return trs[1].z;
		}
		
		public function set rotationZ(value:Number):void 
		{
			trs[1].z = value;
			recompose()
		}
		
		public function get scaleX():Number 
		{
			return trs[2].x;
		}
		
		public function set scaleX(value:Number):void 
		{
			trs[2].x = value;
			recompose()
		}
		
		public function get scaleY():Number 
		{
			return trs[2].y;
		}
		
		public function set scaleY(value:Number):void 
		{
			trs[2].y = value;
			recompose()
		}
		
		public function get scaleZ():Number 
		{
			return trs[2].z;
		}
		
		public function set scaleZ(value:Number):void 
		{
			trs[2].z = value;
			recompose()
		}
		
		public function get world():Matrix3D 
		{
			_world.copyFrom(_matrix);
			if (parent) {
				_world.append(parent.world);
			}
			return _world;
		}
		
		public function get world2local():Matrix3D 
		{
			_world2local.copyFrom(world);
			_world2local.invert();
			return _world2local;
		}
		
		public function rayMeshTest( rayOrigin:Vector3D, rayDirection:Vector3D,pixelPos:Vector3D=null ):Boolean
		{
			if (picking) {
				return picking.pick(this,rayOrigin, rayDirection, pixelPos);
			}
			return false;
		}
		
		public function toString():String {
			return getQualifiedClassName(this).split("::")[1]+":"+name;
		}
		
		public function clone():Node3D {
			var node:Node3D = new Node3D;
			node.copyfrom = this;
			node.drawable = drawable;
			node.material = material;
			node.matrix = matrix.clone();
			node.skin = skin;
			for each(var child:Node3D in children) {
				if(child.type!="JOINT")
				node.addChild(child.clone());
			}
			return node;
		}
	}

}