package gl3d.core
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import gl3d.core.skin.Skin;
	import gl3d.ctrl.Ctrl;
	import gl3d.pick.AS3Picking;
	import gl3d.pick.Picking;
	import gl3d.util.Matrix3DUtils;
	
	/**
	 * ...
	 * @author lizhi
	 */
	public class Node3D
	{
		public var parent:Node3D;
		public var _world:Matrix3D = new Matrix3D;
		public var _world2local:Matrix3D = new Matrix3D;
		private var _matrix:Matrix3D = new Matrix3D;
		public var children:Vector.<Node3D> = new Vector.<Node3D>;
		public var renderChildren:Vector.<Node3D> = new Vector.<Node3D>;
		public var drawable:Drawable;
		public var material:Material;
		public var name:String;
		public var picking:Picking = new AS3Picking;
		public var controllers:Vector.<Ctrl>;
		public var skin:Skin;
		public var type:String;
		public var copyfrom:Node3D;
		private var dirty:Boolean = true;
		private var dirtyInv:Boolean = true;
		
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
			n.updateTransforms(true);
		}
		
		public function removeChild(n:Node3D):void
		{
			var i:int = children.indexOf(n);
			if (i != -1) children.splice(i, 1);
			n.parent = null;
			n.updateTransforms(true);
		}
		
		public function update(view:View3D, material:Material = null):void
		{
			if (controllers)
			{
				for each (var c:Ctrl in controllers)
				{
					c.update(view.time);
				}
			}
			if (material || this.material)
			{
				(material || this.material).draw(this, view);
			}
			for each (var child:Node3D in renderChildren)
			{
				child.update(view, material);
			}
		}
		
		public function get x():Number
		{
			this._matrix.copyColumnTo(3, _temp0);
			return _temp0.x;
		}
		
		public function set x(val:Number):void
		{
			this._matrix.copyColumnTo(3, _temp0);
			_temp0.x = val;
			this._matrix.copyColumnFrom(3, _temp0);
			this.updateTransforms(true);
		}
		
		public function get y():Number
		{
			this._matrix.copyColumnTo(3, _temp0);
			return _temp0.y;
		}
		
		public function set y(val:Number):void
		{
			this._matrix.copyColumnTo(3, _temp0);
			_temp0.y = val;
			this._matrix.copyColumnFrom(3, _temp0);
			this.updateTransforms(true);
		}
		
		public function get z():Number
		{
			this._matrix.copyColumnTo(3, _temp0);
			return _temp0.z;
		}
		
		public function set z(val:Number):void
		{
			this._matrix.copyColumnTo(3, _temp0);
			_temp0.z = val;
			this._matrix.copyColumnFrom(3, _temp0);
			this.updateTransforms(true);
		}
		
		public function set scaleX(val:Number):void
		{
			Matrix3DUtils.scaleX(this._matrix, val);
			this.updateTransforms(true);
		}
		
		public function set scaleY(val:Number):void
		{
			Matrix3DUtils.scaleY(this._matrix, val);
			this.updateTransforms(true);
		}
		
		public function set scaleZ(val:Number):void
		{
			Matrix3DUtils.scaleZ(this._matrix, val);
			this.updateTransforms(true);
		}
		
		public function get scaleX():Number
		{
			return Matrix3DUtils.getRight(this._matrix, _temp0).length;
		}
		
		public function get scaleY():Number
		{
			return Matrix3DUtils.getUp(this._matrix, _temp0).length;
		}
		
		public function get scaleZ():Number
		{
			return Matrix3DUtils.getDir(this._matrix, _temp0).length;
		}
		
		public function setRotation(x:Number, y:Number, z:Number):void
		{
			Matrix3DUtils.setRotation(this._matrix, x, y, z);
			this.updateTransforms(true);
		}
		
		public function getRotation(local:Boolean = true, out:Vector3D = null):Vector3D
		{
			if (out == null)
			{
				out = new Vector3D();
			}
			out = Matrix3DUtils.getRotation(local ? this._matrix : this.world, out);
			return out;
		}
		
		public function get rotationX():Number
		{
			return getRotation(true, _temp0).x;
		}
		
		public function set rotationX(val:Number):void
		{
			getRotation(true, _temp0);
			setRotation(val, _temp0.y, _temp0.z);
		}
		
		public function get rotationY():Number
		{
			return getRotation(true, _temp0).y;
		}
		
		public function set rotationY(val:Number):void
		{
			getRotation(true, _temp0);
			setRotation(_temp0.x, val, _temp0.z);
		}
		
		public function get rotationZ():Number
		{
			return getRotation(true, _temp0).z;
		}
		
		public function set rotationZ(val:Number):void
		{
			getRotation(true, _temp0);
			setRotation(_temp0.x, _temp0.y, val);
		}
		
		public function get world():Matrix3D
		{
			if (dirty)
			{
				_matrix.copyToMatrix3D(_world);
				if (parent && parent.parent)
				{
					_world.append(parent.world);
				}
				dirty = false;
				dirtyInv = true;
			}
			return _world;
		}
		
		public function get world2local():Matrix3D
		{
			if (dirty || dirtyInv)
			{
				_world2local.copyFrom(world);
				_world2local.invert();
				dirtyInv = false;
			}
			return _world2local;
		}
		
		public function get matrix():Matrix3D
		{
			return _matrix;
		}
		
		public function set matrix(value:Matrix3D):void
		{
			_matrix = value;
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
			dirty = true;
		}
		
		public function rayMeshTest(rayOrigin:Vector3D, rayDirection:Vector3D, pixelPos:Vector3D = null):Boolean
		{
			if (picking)
			{
				return picking.pick(this, rayOrigin, rayDirection, pixelPos);
			}
			return false;
		}
		
		public function clone(addRender:Boolean = false):Node3D
		{
			var node:Node3D = new Node3D;
			node.copyfrom = this;
			node.drawable = drawable;
			node.material = material;
			node.matrix = matrix.clone();
			node.skin = skin;
			for each (var child:Node3D in children)
			{
				if (child.type != "JOINT")
					node.addChild(child.clone(addRender));
			}
			if (addRender && drawable)
			{
				renderChildren.push(node);
			}
			return node;
		}
	}

}