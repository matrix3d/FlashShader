package gl3d.core {
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Vector3D;
	import flShader.FlShader;
	import gl3d.meshs.Meshs;
	import gl3d.shaders.GLShader;
	import gl3d.shaders.PhongGLShader;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Material 
	{
		public var lightAble:Boolean = true;
		public var ambientAble:Boolean = true;
		public var specularAble:Boolean = true;
		public var ambient:Vector.<Number> = Vector.<Number>([.1, .1, .1, .1]);
		public var specularPower:Number = 50;
		public var shininess:Number = 1;
		
		public var view:View3D;
		public var camera:Camera3D;
		public var node:Node3D;
		public var textureSets:Vector.<TextureSet>=new Vector.<TextureSet>;
		public var color:Vector.<Number> = Vector.<Number>([1, 1, 1, 1]);
		public var alpha:Number = 1;
		private var _wireframeAble:Boolean = false;
		public var isDistanceField:Boolean = false;
		public var wireframeColor:Vector.<Number> = Vector.<Number>([.5, 0, .5, 0]);
		public var invalid:Boolean = true;
		private var _normalMapAble:Boolean;
		public var shader:GLShader;
		
		
		public function Material() 
		{
			shader = new PhongGLShader();
		}
		
		public function draw(node:Node3D,view:View3D):void {
			this.view = view;
			this.camera = view.camera;
			this.node = node;
			if (node.drawable&&shader) {
				var context:Context3D = view.context;
				if (wireframeAble) {
					if (node.unpackedDrawable==null) {
						node.unpackedDrawable = Meshs.unpack(node.drawable);
					}
					node.unpackedDrawable.update(context);
				}
				node.drawable.update(context);
				if (textureSets) {
					for each(var textureSet:TextureSet in textureSets) {
						textureSet.update(view);
					}
				}
				if (invalid) {
					shader.invalid = true;
					invalid = false;
				}
				shader.preUpdate(this);
				shader.update(this);
			}
		}
		
		public function get normalMapAble():Boolean 
		{
			return _normalMapAble;
		}
		
		public function set normalMapAble(value:Boolean):void 
		{
			_normalMapAble = value;
		}
		
		public function get wireframeAble():Boolean 
		{
			return _wireframeAble;
		}
		
		public function set wireframeAble(value:Boolean):void 
		{
			_wireframeAble = value;
			invalid = true;
		}
	}
}

