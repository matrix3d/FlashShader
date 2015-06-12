package gl3d.util
{
   import flash.geom.*;
   
   public class Matrix3DUtils extends Object
   {
      
      public function Matrix3DUtils()
      {
         super();
      }
      
      private static var _raw:Vector.<Number> = new Vector.<Number>(16,true);
      
      private static var _toRad:Number = Math.PI / 180;
      
      private static var _toAng:Number = 180 / Math.PI;
      
      private static var _vector:Vector3D = new Vector3D();
      
      private static var _right:Vector3D = new Vector3D();
      
      private static var _up:Vector3D = new Vector3D();
      
      private static var _dir:Vector3D = new Vector3D();
      
      private static var _scale:Vector3D = new Vector3D();
      
      private static var _pos:Vector3D = new Vector3D();
      
      private static var _x:Number;
      
      private static var _y:Number;
      
      private static var _z:Number;
      
      public static function getRight(m:Matrix3D, out:Vector3D = null) : Vector3D
      {
         if(!out)
         {
            out = new Vector3D();
         }
         m.copyColumnTo(0,out);
         return out;
      }
      
      public static function getUp(m:Matrix3D, out:Vector3D = null) : Vector3D
      {
         if(!out)
         {
            out = new Vector3D();
         }
         m.copyColumnTo(1,out);
         return out;
      }
      
      public static function getDir(m:Matrix3D, out:Vector3D = null) : Vector3D
      {
         if(!out)
         {
            out = new Vector3D();
         }
         m.copyColumnTo(2,out);
         return out;
      }
      
      public static function getLeft(m:Matrix3D, out:Vector3D = null) : Vector3D
      {
         if(!out)
         {
            out = new Vector3D();
         }
         m.copyColumnTo(0,out);
         out.negate();
         return out;
      }
      
      public static function getDown(m:Matrix3D, out:Vector3D = null) : Vector3D
      {
         if(!out)
         {
            out = new Vector3D();
         }
         m.copyColumnTo(1,out);
         out.negate();
         return out;
      }
      
      public static function getBackward(m:Matrix3D, out:Vector3D = null) : Vector3D
      {
         if(!out)
         {
            out = new Vector3D();
         }
         m.copyColumnTo(2,out);
         out.negate();
         return out;
      }
      
      public static function getPosition(m:Matrix3D, out:Vector3D = null) : Vector3D
      {
         if(!out)
         {
            out = new Vector3D();
         }
         m.copyColumnTo(3,out);
         return out;
      }
      
      public static function getScale(m:Matrix3D, out:Vector3D = null) : Vector3D
      {
         if(!out)
         {
            out = new Vector3D();
         }
         m.copyColumnTo(0,_right);
         m.copyColumnTo(1,_up);
         m.copyColumnTo(2,_dir);
         out.x = _right.length;
         out.y = _up.length;
         out.z = _dir.length;
         return out;
      }
      
      public static function setPosition(m:Matrix3D, x:Number, y:Number, z:Number, smooth:Number = 1) : void
      {
         if(smooth == 1)
         {
            _vector.setTo(x,y,z);
            _vector.w = 1;
            m.copyColumnFrom(3,_vector);
         }
         else
         {
            m.copyColumnTo(3,_pos);
            _pos.x = _pos.x + (x - _pos.x) * smooth;
            _pos.y = _pos.y + (y - _pos.y) * smooth;
            _pos.z = _pos.z + (z - _pos.z) * smooth;
            m.copyColumnFrom(3,_pos);
         }
      }
      
      public static function setOrientation(m:Matrix3D, dir:Vector3D, up:Vector3D = null, smooth:Number = 1) : void
      {
         getScale(m,_scale);
         if(up == null)
         {
            if((dir.x == 0) && (Math.abs(dir.y) == 1) && (dir.z == 0))
            {
               up = Vector3D.Z_AXIS;
            }
            else
            {
               up = Vector3D.Y_AXIS;
            }
         }
         if(smooth != 1)
         {
            getDir(m,_dir);
            _dir.x = _dir.x + (dir.x - _dir.x) * smooth;
            _dir.y = _dir.y + (dir.y - _dir.y) * smooth;
            _dir.z = _dir.z + (dir.z - _dir.z) * smooth;
            dir = _dir;
            getUp(m,_up);
            _up.x = _up.x + (up.x - _up.x) * smooth;
            _up.y = _up.y + (up.y - _up.y) * smooth;
            _up.z = _up.z + (up.z - _up.z) * smooth;
            up = _up;
         }
         dir.normalize();
         var rVec:Vector3D = up.crossProduct(dir);
         rVec.normalize();
         var uVec:Vector3D = dir.crossProduct(rVec);
         rVec.scaleBy(_scale.x);
         uVec.scaleBy(_scale.y);
         dir.scaleBy(_scale.z);
         setVectors(m,rVec,uVec,dir);
      }
      
      public static function setNormalOrientation(m:Matrix3D, normal:Vector3D, smooth:Number = 1) : void
      {
         if((normal.x == 0) && (normal.y == 0) && (normal.z == 0))
         {
            return;
         }
         getScale(m,_scale);
         getDir(m,_dir);
         if(smooth != 1)
         {
            getUp(m,_up);
            _up.x = _up.x + (normal.x - _up.x) * smooth;
            _up.y = _up.y + (normal.y - _up.y) * smooth;
            _up.z = _up.z + (normal.z - _up.z) * smooth;
            normal = _up;
         }
         normal.normalize();
         var dir:Vector3D = Math.abs(_dir.dotProduct(normal)) == 1?getRight(m,_right):_dir;
         var rVec:Vector3D = normal.crossProduct(dir);
         rVec.normalize();
         var dVec:Vector3D = rVec.crossProduct(normal);
         rVec.scaleBy(_scale.x);
         normal.scaleBy(_scale.y);
         dVec.scaleBy(_scale.z);
         setVectors(m,rVec,normal,dVec);
      }
      
      private static function setVectors(m:Matrix3D, right:Vector3D, up:Vector3D, dir:Vector3D) : void
      {
         right.w = 0;
         up.w = 0;
         dir.w = 0;
         m.copyColumnFrom(0,right);
         m.copyColumnFrom(1,up);
         m.copyColumnFrom(2,dir);
      }
      
      public static function lookAt(m:Matrix3D, x:Number, y:Number, z:Number, up:Vector3D = null, smooth:Number = 1) : void
      {
         m.copyColumnTo(3,_pos);
         _vector.x = x - _pos.x;
         _vector.y = y - _pos.y;
         _vector.z = z - _pos.z;
         setOrientation(m,_vector,up,smooth);
      }
      
      public static function setTranslation(m:Matrix3D, x:Number = 0, y:Number = 0, z:Number = 0, local:Boolean = true) : void
      {
         if(local)
         {
            m.prependTranslation(x,y,z);
         }
         else
         {
            m.appendTranslation(x,y,z);
         }
      }
      
      public static function translateX(m:Matrix3D, distance:Number, local:Boolean = true) : void
      {
         m.copyColumnTo(3,_pos);
         m.copyColumnTo(0,_right);
         if(local)
         {
            _pos.x = _pos.x + distance * _right.x;
            _pos.y = _pos.y + distance * _right.y;
            _pos.z = _pos.z + distance * _right.z;
         }
         else
         {
            _pos.x = _pos.x + distance;
         }
         m.copyColumnFrom(3,_pos);
      }
      
      public static function translateY(m:Matrix3D, distance:Number, local:Boolean = true) : void
      {
         m.copyColumnTo(3,_pos);
         m.copyColumnTo(1,_up);
         if(local)
         {
            _pos.x = _pos.x + distance * _up.x;
            _pos.y = _pos.y + distance * _up.y;
            _pos.z = _pos.z + distance * _up.z;
         }
         else
         {
            _pos.y = _pos.y + distance;
         }
         m.copyColumnFrom(3,_pos);
      }
      
      public static function translateZ(m:Matrix3D, distance:Number, local:Boolean = true) : void
      {
         m.copyColumnTo(3,_pos);
         m.copyColumnTo(2,_dir);
         if(local)
         {
            _pos.x = _pos.x + distance * _dir.x;
            _pos.y = _pos.y + distance * _dir.y;
            _pos.z = _pos.z + distance * _dir.z;
         }
         else
         {
            _pos.z = _pos.z + distance;
         }
         m.copyColumnFrom(3,_pos);
      }
      
      public static function translateAxis(m:Matrix3D, distance:Number, axis:Vector3D) : void
      {
         m.copyColumnTo(3,_pos);
         _pos.x = _pos.x + distance * axis.x;
         _pos.y = _pos.y + distance * axis.y;
         _pos.z = _pos.z + distance * axis.z;
         m.copyColumnFrom(3,_pos);
      }
      
      public static function setScale(m:Matrix3D, x:Number, y:Number, z:Number, smooth:Number = 1) : void
      {
         getScale(m,_scale);
         _x = _scale.x;
         _y = _scale.y;
         _z = _scale.z;
         _scale.x = _scale.x + (x - _scale.x) * smooth;
         _scale.y = _scale.y + (y - _scale.y) * smooth;
         _scale.z = _scale.z + (z - _scale.z) * smooth;
         _right.scaleBy(_scale.x / _x);
         _up.scaleBy(_scale.y / _y);
         _dir.scaleBy(_scale.z / _z);
         setVectors(m,_right,_up,_dir);
      }
      
      public static function scaleX(m:Matrix3D, scale:Number) : void
      {
         m.copyColumnTo(0,_right);
         _right.normalize();
         _right.x = _right.x * scale;
         _right.y = _right.y * scale;
         _right.z = _right.z * scale;
         m.copyColumnFrom(0,_right);
      }
      
      public static function scaleY(m:Matrix3D, scale:Number) : void
      {
         m.copyColumnTo(1,_up);
         _up.normalize();
         _up.x = _up.x * scale;
         _up.y = _up.y * scale;
         _up.z = _up.z * scale;
         m.copyColumnFrom(1,_up);
      }
      
      public static function scaleZ(m:Matrix3D, scale:Number) : void
      {
         m.copyColumnTo(2,_dir);
         _dir.normalize();
         _dir.x = _dir.x * scale;
         _dir.y = _dir.y * scale;
         _dir.z = _dir.z * scale;
         m.copyColumnFrom(2,_dir);
      }
      
      public static function getRotation(m:Matrix3D, out:Vector3D = null) : Vector3D
      {
         out = out || new Vector3D();
         _vector = m.decompose(Orientation3D.EULER_ANGLES)[1];
         out.x = _vector.x * _toAng;
         out.y = _vector.y * _toAng;
         out.z = _vector.z * _toAng;
         return out;
      }
      
      public static function setRotation(m:Matrix3D, x:Number, y:Number, z:Number) : void
      {
         var v:Vector.<Vector3D> = m.decompose(Orientation3D.EULER_ANGLES);
         v[1].x = x * _toRad;
         v[1].y = y * _toRad;
         v[1].z = z * _toRad;
         m.recompose(v,Orientation3D.EULER_ANGLES);
      }
      
      public static function rotateX(m:Matrix3D, angle:Number, local:Boolean = true, pivotPoint:Vector3D = null) : void
      {
         rotateAxis(m,angle,local?getRight(m,_vector):Vector3D.X_AXIS,pivotPoint);
      }
      
      public static function rotateY(m:Matrix3D, angle:Number, local:Boolean = true, pivotPoint:Vector3D = null) : void
      {
         rotateAxis(m,angle,local?getUp(m,_vector):Vector3D.Y_AXIS,pivotPoint);
      }
      
      public static function rotateZ(m:Matrix3D, angle:Number, local:Boolean = true, pivotPoint:Vector3D = null) : void
      {
         rotateAxis(m,angle,local?getDir(m,_vector):Vector3D.Z_AXIS,pivotPoint);
      }
      
      public static function rotateAxis(m:Matrix3D, angle:Number, axis:Vector3D, pivotPoint:Vector3D = null) : void
      {
         _vector.x = axis.x;
         _vector.y = axis.y;
         _vector.z = axis.z;
         _vector.normalize();
         m.copyColumnTo(3,_pos);
         m.appendRotation(angle,_vector,pivotPoint || _pos);
      }
      
      public static function transformVector(m:Matrix3D, vector:Vector3D, out:Vector3D = null) : Vector3D
      {
         if(!out)
         {
            out = new Vector3D();
         }
         var x:Number = vector.x;
         var y:Number = vector.y;
         var z:Number = vector.z;
         m.copyRawDataTo(_raw);
         out.x = x * _raw[0] + y * _raw[4] + z * _raw[8] + _raw[12];
         out.y = x * _raw[1] + y * _raw[5] + z * _raw[9] + _raw[13];
         out.z = x * _raw[2] + y * _raw[6] + z * _raw[10] + _raw[14];
         return out;
      }
      
      public static function deltaTransformVector(m:Matrix3D, vector:Vector3D, out:Vector3D = null) : Vector3D
      {
         if(!out)
         {
            out = new Vector3D();
         }
         var x:Number = vector.x;
         var y:Number = vector.y;
         var z:Number = vector.z;
         m.copyRawDataTo(_raw);
         out.x = x * _raw[0] + y * _raw[4] + z * _raw[8];
         out.y = x * _raw[1] + y * _raw[5] + z * _raw[9];
         out.z = x * _raw[2] + y * _raw[6] + z * _raw[10];
         return out;
      }
      
      public static function invert(m:Matrix3D, out:Matrix3D = null) : Matrix3D
      {
         if(!out)
         {
            out = new Matrix3D();
         }
         out.copyFrom(m);
         out.invert();
         return out;
      }
      
      public static function equal(a:Matrix3D, b:Matrix3D) : Boolean
      {
         var v0:Vector.<Number> = a.rawData;
         var v1:Vector.<Number> = b.rawData;
         var i:int = 0;
         while(i < 16)
         {
            if(v0[i] != v1[i])
            {
               return false;
            }
            i++;
         }
         return true;
      }
      
      private static var _scaleSrc:Vector3D = new Vector3D();
      
      private static var _scaleDest:Vector3D = new Vector3D();
      
      public static function interpolateTo(src:Matrix3D, dest:Matrix3D, percent:Number) : void
      {
         var sx:* = NaN;
         var sy:* = NaN;
         var sz:* = NaN;
         src.copyRawDataTo(_raw);
         _right.x = _raw[0];
         _right.y = _raw[1];
         _right.z = _raw[2];
         _up.x = _raw[4];
         _up.y = _raw[5];
         _up.z = _raw[6];
         _dir.x = _raw[8];
         _dir.y = _raw[9];
         _dir.z = _raw[10];
         _scaleSrc.x = _right.length;
         _scaleSrc.y = _up.length;
         _scaleSrc.z = _dir.length;
         sx = 1 / _scaleSrc.x;
         sy = 1 / _scaleSrc.y;
         sz = 1 / _scaleSrc.z;
         _raw[0] = _raw[0] * sx;
         _raw[1] = _raw[1] * sx;
         _raw[2] = _raw[2] * sx;
         _raw[4] = _raw[4] * sy;
         _raw[5] = _raw[5] * sy;
         _raw[6] = _raw[6] * sy;
         _raw[8] = _raw[8] * sz;
         _raw[9] = _raw[9] * sz;
         _raw[10] = _raw[10] * sz;
         src.copyRawDataFrom(_raw);
         dest.copyRawDataTo(_raw);
         _right.x = _raw[0];
         _right.y = _raw[1];
         _right.z = _raw[2];
         _up.x = _raw[4];
         _up.y = _raw[5];
         _up.z = _raw[6];
         _dir.x = _raw[8];
         _dir.y = _raw[9];
         _dir.z = _raw[10];
         _scaleDest.x = _right.length;
         _scaleDest.y = _up.length;
         _scaleDest.z = _dir.length;
         sx = 1 / _scaleDest.x;
         sy = 1 / _scaleDest.y;
         sz = 1 / _scaleDest.z;
         _raw[0] = _raw[0] * sx;
         _raw[1] = _raw[1] * sx;
         _raw[2] = _raw[2] * sx;
         _raw[4] = _raw[4] * sy;
         _raw[5] = _raw[5] * sy;
         _raw[6] = _raw[6] * sy;
         _raw[8] = _raw[8] * sz;
         _raw[9] = _raw[9] * sz;
         _raw[10] = _raw[10] * sz;
         dest.copyRawDataFrom(_raw);
         src.interpolateTo(dest,percent);
         _scaleSrc.x = _scaleSrc.x + (_scaleDest.x - _scaleSrc.x) * percent;
         _scaleSrc.y = _scaleSrc.y + (_scaleDest.y - _scaleSrc.y) * percent;
         _scaleSrc.z = _scaleSrc.z + (_scaleDest.z - _scaleSrc.z) * percent;
         src.prependScale(_scaleSrc.x,_scaleSrc.y,_scaleSrc.z);
         dest.prependScale(_scaleDest.x,_scaleDest.y,_scaleDest.z);
      }
      
      public static function resetPosition(m:Matrix3D) : void
      {
         setPosition(m,0,0,0);
      }
      
      public static function resetRotation(m:Matrix3D) : void
      {
         setRotation(m,0,0,0);
      }
      
      public static function resetScale(m:Matrix3D) : void
      {
         setScale(m,1,1,1);
      }
      
      public static function buildOrthoProjection(left:Number, right:Number, bottom:Number, top:Number, near:Number, far:Number, out:Matrix3D = null) : Matrix3D
      {
         var scaleX:* = NaN;
         var scaleY:* = NaN;
         var scaleZ:* = NaN;
         var offsX:* = NaN;
         var offsY:* = NaN;
         var offsZ:* = NaN;
         if(out == null)
         {
            out = new Matrix3D();
         }
         scaleX = 2 / (right - left);
         scaleY = 2 / (top - bottom);
         scaleZ = 1 / (far - near);
         offsX = -0.5 * (right + left) * scaleX;
         offsY = -0.5 * (top + bottom) * scaleY;
         offsZ = -near * scaleZ;
         _raw[0] = scaleX;
         _raw[5] = scaleY;
         _raw[10] = scaleZ;
         _raw[12] = offsX;
         _raw[13] = offsY;
         _raw[14] = offsZ;
         _raw[1] = _raw[2] = _raw[4] = _raw[6] = _raw[8] = _raw[9] = _raw[3] = _raw[7] = _raw[11] = 0;
         _raw[15] = 1;
         out.copyRawDataFrom(_raw);
         return out;
      }
   }
}
