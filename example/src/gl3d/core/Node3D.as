package gl3d.core
{
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import gl3d.core.skin.Skin;
	import gl3d.ctrl.Ctrl;
	import gl3d.pick.AS3Picking;
	import gl3d.pick.Picking;
	import gl3d.util.Matrix3DUtils;
	import gl3d.util.Utils;
	
	/**
	 * ...
	 * @author lizhi
	 */
	public class Node3D
	{
		private static var _toRad:Number = Math.PI / 180;
		
		private static var _toAng:Number = 180 / Math.PI;
		public var parent:Node3D;
		public var _world:Matrix3D = new Matrix3D;
		public var _world2local:Matrix3D = new Matrix3D;
		private var _matrix:Matrix3D = new Matrix3D;
		public var children:Vector.<Node3D> = new Vector.<Node3D>;
		public var mask:Node3D;
		public var scissorRectangle:Rectangle;
		public var renderChildren:Vector.<Node3D> = new Vector.<Node3D>;
		public var drawable:Drawable;
		public var posVelocityDrawable:Drawable;//粒子的位置速度drawable
		public var material:MaterialBase;
		public var name:String;
		public var picking:Picking = new AS3Picking;
		public var controllers:Vector.<Ctrl>;
		public var skin:Skin;
		public var type:String;
		private var _scale:Vector3D = new Vector3D(1, 1, 1);
		private var _rotation:Vector3D = new Vector3D;
		private var _position:Vector3D = new Vector3D;
		private var trs: Vector.<Vector3D> = Vector.<Vector3D>([_position,_rotation,_scale]);
		private var dirtyMatrix:Boolean = false;
		private var dirtyWrold:Boolean = false;
		private var dirtyInv:Boolean = false;
		private var dirtyRotScale:Boolean = false;
		public var visible:Boolean = true;
		
		//粒子属性
		public var startTime:int = 0;//动画开始的时间
		public var randomTime:Boolean = false;
		public var lifeTimeRange:Vector3D = new Vector3D(1000, 1000);//生命周期范围
		public var scaleFromTo:Vector3D;
		public var rotationStartAndSpeed:Vector3D;
		public var randomAxis:Boolean;
		public var rotationAxis:Vector3D;
		
		private static var _temp0:Vector3D = new Vector3D();
		
		private static var _temp1:Vector3D = new Vector3D();
		
		private static var _temp2:Vector3D = new Vector3D();
		
		public function Node3D(name:String = null)
		{
			this.name = name;
		}
		
		public function addChild(n:Node3D):void
		{
			if (n.parent)
			{
				n.parent.removeChild(n);
			}
			children.push(n);
			n.parent = this;
			if (n==this){
				throw "error"
			}
			n.updateTransforms(true);
		}
		
		public function removeChild(n:Node3D):void
		{
			var i:int = children.indexOf(n);
			if (i != -1) {
				children.splice(i, 1);
				n.parent = null;
				n.updateTransforms(true);
			}
		}
		
		public function update(view:View3D, material:MaterialBase = null):void
		{
			//trace(name,Utils.getID(this),(this.material&&this.material.diffTexture)?Utils.getID(this.material.diffTexture.texture):null);
			//if(visible){
				if (controllers)
				{
					for each (var c:Ctrl in controllers)
					{
						if(c){
							c.update(view.time,this);
						}
					}
				}
				if (scissorRectangle){
					view.renderer.gl3d.setScissorRectangle(scissorRectangle);
				}
				if (mask){
					Mask.startMask(view, mask);
				}
				if (material || this.material)
				{
					(material || this.material).draw(this, view);
				}
				for each (var child:Node3D in renderChildren)
				{
					child.update(view, material);
				}
				if (mask){
					Mask.stopMask(view, mask);
				}
			//}
		}
		
		public function getPosition(out:Vector3D=null):Vector3D{
			out = out || new Vector3D;
			out.copyFrom(_position);
			return out;
		}
		
		public function setPosition(x:Number,y:Number,z:Number):void{
			_position.setTo(x, y, z);
			matrix.copyColumnFrom(3, _position);
			updateTransforms(true);
			dirtyMatrix = true;
		}
		
		public function get x():Number
		{
			return _position.x;
			//matrix.copyColumnTo(3, _temp0);
			//return _temp0.x;
		}
		
		public function set x(val:Number):void
		{
			matrix.copyColumnTo(3, _position);
			_position.x = val;
			matrix.copyColumnFrom(3, _position);
			updateTransforms(true);
		}
		
		public function get y():Number
		{
			return _position.y;
			//matrix.copyColumnTo(3, _temp0);
			//return _temp0.y;
		}
		
		public function set y(val:Number):void
		{
			matrix.copyColumnTo(3, _position);
			_position.y = val;
			matrix.copyColumnFrom(3, _position);
			updateTransforms(true);
		}
		
		public function get z():Number
		{
			return _position.z;
			//matrix.copyColumnTo(3, _temp0);
			//return _temp0.z;
		}
		
		public function set z(val:Number):void
		{
			matrix.copyColumnTo(3, _position);
			_position.z = val;
			matrix.copyColumnFrom(3, _position);
			updateTransforms(true);
		}
		
		public function set scaleX(val:Number):void
		{
			decompose();
			_scale.x = val;
			//Matrix3DUtils.scaleX(this._matrix, val);
			updateTransforms(true);
			dirtyMatrix = true;
			//dirtyRotScale = true;
		}
		
		public function set scaleY(val:Number):void
		{
			decompose();
			_scale.y = val;
			//Matrix3DUtils.scaleY(this._matrix, val);
			updateTransforms(true);
			dirtyMatrix = true;
		}
		
		public function set scaleZ(val:Number):void
		{
			decompose();
			_scale.z = val;
			//Matrix3DUtils.scaleZ(this._matrix, val);
			updateTransforms(true);
			//dirtyRotScale = true;
			dirtyMatrix = true;
		}
		
		public function get scaleX():Number
		{
			decompose();
			return _scale.x;
			//return Matrix3DUtils.getRight(this._matrix, _temp0).length;
		}
		
		public function get scaleY():Number
		{
			decompose();
			return _scale.y;
			//return Matrix3DUtils.getUp(this._matrix, _temp0).length;
		}
		
		public function get scaleZ():Number
		{
			decompose();
			return _scale.z;
			//return Matrix3DUtils.getDir(this._matrix, _temp0).length;
		}
		public function setScale(x:Number, y:Number, z:Number):void
		{
			decompose();
			_scale.setTo(x,y,z);
			updateTransforms(true);
			dirtyMatrix = true;
		}
		
		public function getScale(out:Vector3D=null):Vector3D
		{
			out = out || new Vector3D;
			decompose();
			out.copyFrom(_scale);
			return out;
		}
		public function setRotation(x:Number, y:Number, z:Number):void
		{
			decompose();
			_rotation.setTo(x*_toRad, y*_toRad, z*_toRad);
			updateTransforms(true);
			dirtyMatrix = true;
		}
		
		public function getRotation(out:Vector3D=null):Vector3D
		{
			out = out || new Vector3D;
			decompose();
			out.setTo(_rotation.x*_toAng,_rotation.y*_toAng,_rotation.z*_toAng);
			return out;
		}
		
		public function get rotationX():Number
		{
			decompose();
			return _rotation.x*_toAng;
		}
		
		public function set rotationX(val:Number):void
		{
			decompose();
			_rotation.x = val*_toRad;
			updateTransforms(true);
			dirtyMatrix = true;
		}
		
		public function get rotationY():Number
		{
			decompose();
			return _rotation.y*_toAng;
		}
		
		public function set rotationY(val:Number):void
		{
			decompose();
			_rotation.y = val*_toRad;
			updateTransforms(true);
			dirtyMatrix = true;
		}
		
		public function get rotationZ():Number
		{
			decompose();
			return _rotation.z*_toAng;
		}
		
		public function set rotationZ(val:Number):void
		{
			decompose();
			_rotation.z = val*_toRad;
			updateTransforms(true);
			dirtyMatrix = true;
		}
		
		public function get world():Matrix3D
		{
			if (dirtyWrold)
			{
				matrix.copyToMatrix3D(_world);
				if (parent)
				{
					_world.append(parent.world);
				}
				dirtyWrold = false;
				dirtyInv = true;
			}
			return _world;
		}
		
		public function set world(value:Matrix3D):void
		{
			_matrix.copyFrom(value);
			if(parent)
			_matrix.append(parent.world2local);
			matrix = _matrix;
		}
		
		public function get world2local():Matrix3D
		{
			if (dirtyWrold || dirtyInv)
			{
				_world2local.copyFrom(world);
				_world2local.invert();
				dirtyInv = false;
			}
			return _world2local;
		}
		
		public function get matrix():Matrix3D
		{
			recompose();
			return _matrix;
		}
		
		public function set matrix(value:Matrix3D):void
		{
			_matrix = value;
			dirtyRotScale = true;
			_matrix.copyColumnTo(3, _position);
			updateTransforms(true);
		}
		
		public function updateTransforms(includeChildren:Boolean = false):void
		{
			if (includeChildren)
			{
				for each (var c:Node3D in children)
				{
					c.updateTransforms(true);
				}
			}
			dirtyWrold = true;
		}
		
		private function decompose():void{
			if (dirtyRotScale){
				dirtyRotScale = false;
				Matrix3DUtils.decompose(matrix, null, trs);
			}
		}
		
		private function recompose():void{
			if (dirtyMatrix){
				dirtyMatrix = false;
				_matrix.recompose(trs);
			}
		}
		
		public function rayMeshTest(rayOrigin:Vector3D, rayDirection:Vector3D, pixelPos:Vector3D = null):Boolean
		{
			if (picking)
			{
				return picking.pick(this, rayOrigin, rayDirection, pixelPos);
			}
			return false;
		}
		
		public function clone():Node3D
		{
			var clzn:String = getQualifiedClassName(this);
			var clz:Class = getDefinitionByName(clzn) as Class;
			var node:Node3D = new clz as Node3D;
			//node.copyfrom = this;
			node.drawable = drawable;
			node.name = name;
			node.type = type;
			node.material = material;
			node.matrix = matrix.clone();
			if (controllers){
				node.controllers = new Vector.<Ctrl>;
				for each(var c:Ctrl in controllers){
					node.controllers.push(c.clone());
				}
			}
			
			if(skin){
				node.skin = skin.clone();
			}
			for each (var child:Node3D in children)
			{
				//if (child.type != "JOINT")
					node.addChild(child.clone(/*addRender*/));
			}
			return node;
		}
		
		public function dispose():void {
			
		}
	}

}