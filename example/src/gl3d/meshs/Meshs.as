package gl3d.meshs 
{
	import flash.display.BitmapData;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix;
	import flash.geom.Vector3D;
	import gl3d.core.Drawable3D;
	import gl3d.core.IndexBufferSet;
	import gl3d.core.VertexBufferSet;
	import gl3d.util.Utils;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Meshs 
	{
		
		public function Meshs() 
		{
			
		}
		public static function billboard():Drawable3D
		{
			var vs:Vector.<Number> = new Vector.<Number>(4 * 3);
			var uv:Vector.<Number> = Vector.<Number>([0, 0, 1, 0, 0, 1, 1, 1]);
			var ins:Vector.<uint>=Vector.<uint>([0, 1, 2, 1, 3, 2]);
			return createDrawable(ins, vs, uv, null);
		}
		
		public static function plane(r:Number=1):Drawable3D
		{
			var vs:Vector.<Number> = Vector.<Number>([-r, -r, 0, r, -r, 0, -r, r, 0, r, r, 0]);
			var uv:Vector.<Number> = Vector.<Number>([0, 1, 1, 1, 0, 0, 1, 0]);
			var ins:Vector.<uint>=Vector.<uint>([0, 1, 2, 1, 3, 2]);
			return createDrawable(ins, vs, uv, null);
		}
		
		public static function sphere(w:Number = 20, h:Number = 20):Drawable3D {
			var ins:Vector.<uint> = new Vector.<uint>;
			var vs:Vector.<Number> = new Vector.<Number>;
			var uv:Vector.<Number> = new Vector.<Number>;
			for (var i:int = 0; i <= h; i++ ) {
				var roti:Number = Math.PI / h * i -Math.PI/2;
				for (var j:int = 0; j <= w;j++ ) {
					var rotj:Number = Math.PI * 2 / w*j;
					vs.push(Math.cos(rotj)*Math.cos(roti), Math.sin(roti), Math.sin(rotj)*Math.cos(roti));
					uv.push(j / w, i / h);
					var ni:int = vs.length/3 - 1;
					if (i>0&&j>0) {
						ins.push(ni, ni - 1, ni - w-1, ni - 1, ni - w - 2, ni - w-1);
					}
				}
			}
			return createDrawable(ins, vs,uv, vs);
		}
		
		public static function test():Drawable3D {
			return createDrawable(Vector.<uint>([1,0,2]), Vector.<Number>([1,1,0,1,0,0,0,1,0]), null, null);
		}
		public static function cube(width:Number=1,heigth:Number=1,depth:Number=1):Drawable3D {
			var hw:Number = width / 2;
			var hh:Number = heigth / 2;
			var hd:Number = depth / 2;
			return createDrawable(
				Vector.<uint>([
					0, 1, 2, 0, 2, 3,
					4, 6, 5, 4, 7, 6,
					8, 10, 9, 8, 11, 10,
					12, 13, 14, 12, 14, 15,
					16, 17, 18, 16, 18, 19,
					20, 22, 21, 20, 23, 22
					]),
				Vector.<Number>([
					hw, hh, hd, hw, -hh, hd, -hw, -hh, hd, -hw, hh, hd,
					hw, hh, -hd, hw, -hh, -hd, -hw, -hh, -hd, -hw, hh, -hd,
					hw, hh, hd, hw, hh, -hd, -hw, hh, -hd, -hw, hh, hd,
					hw, -hh, hd, hw, -hh, -hd, -hw, -hh, -hd, -hw, -hh, hd,
					hw, hh, hd, hw, hh, -hd, hw, -hh, -hd, hw, -hh, hd,
					-hw, hh, hd, -hw, hh, -hd, -hw, -hh, -hd, -hw, -hh, hd
				]),
				Vector.<Number>([
					1, 0, 1, 1, 0, 1, 0, 0,
					1, 0, 1, 1, 0, 1, 0, 0,
					1, 0, 1, 1, 0, 1, 0, 0,
					1, 0, 1, 1, 0, 1, 0, 0,
					1, 0, 1, 1, 0, 1, 0, 0,
					1, 0, 1, 1, 0, 1, 0, 0
				]),
				Vector.<Number>([
					0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1,
					0, 0, -1, 0, 0, -1, 0, 0, -1, 0, 0, -1,
					0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0,
					0, -1, 0, 0, -1, 0, 0, -1, 0, 0, -1, 0,
					1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0,
					-1, 0, 0, -1, 0, 0, -1, 0, 0, -1, 0, 0
				])
			);
		}
		
		public static function terrainData(w:int = 64, scale:Vector3D = null, sbmd:BitmapData=null, tempbmd:BitmapData=null):Vector.<Number> {
			var vin:Vector.<Number> = new Vector.<Number>;
            var bmd:BitmapData =tempbmd|| new BitmapData(w, w,true,0);
			if(sbmd==null){
				bmd.perlinNoise(35, 35, 3, 0, true, true);
			}else {
				bmd.draw(sbmd, new Matrix(w/sbmd.width,0,0,w/sbmd.height),null,null,null,true);
			}
			bmd.lock();
            for (var y:int = 0; y < w;y++ ) {
                for (var x:int = 0; x < w; x++ ) {
					var px:Number = (x / (w-1) - .5);
					var py:Number = ((0xff & bmd.getPixel(x, y)) / 0xff - .5)*.1;
					var pz:Number=(y / (w-1) - .5)
                    if (scale) {
						px *= scale.x;
						py *= scale.y;
						pz *= scale.z;
					}
					vin.push(px,py ,pz );
                }
            }
			bmd.unlock();
			if(tempbmd==null)
			bmd.dispose();
			return vin;
		}
		
		public static function terrain(w:int=64,scale:Vector3D=null,sbmd:BitmapData=null,tempbmd:BitmapData=null):Drawable3D {
			var ins:Vector.<uint> = new Vector.<uint>;
			var vin:Vector.<Number> = new Vector.<Number>;
			var uv:Vector.<Number> = new Vector.<Number>;
            var bmd:BitmapData =tempbmd|| new BitmapData(w, w,true,0);
			if(sbmd==null){
				bmd.perlinNoise(35, 35, 3, 0, true, true);
			}else {
				bmd.draw(sbmd, new Matrix(w/sbmd.width,0,0,w/sbmd.height),null,null,null,true);
			}
            for (var y:int = 0; y < w;y++ ) {
                for (var x:int = 0; x < w; x++ ) {
					var px:Number = (x / (w-1) - .5);
					var py:Number = ((0xff & bmd.getPixel(x, y)) / 0xff - .5)*.1;
					var pz:Number=(y / (w-1) - .5)
                    if (scale) {
						px *= scale.x;
						py *= scale.y;
						pz *= scale.z;
					}
					vin.push(px,py ,pz );
                    uv.push(x/(w-1),y/(w-1));
                    if (x!=w-1&&y!=w-1) {
                        ins.push(y * w + x, y * w + x + 1, (y + 1) * w + x);
                        ins.push(y * w + x + 1, (y + 1) * w + 1 + x, (y + 1) * w + x);
                    }
                }
            }
			var drawable:Drawable3D = createDrawable(ins, vin, uv,null);
			if(tempbmd==null)
			bmd.dispose();
			return drawable;
		}
		
		public static function teapot(divs:uint = 10):Drawable3D {
			return Teapot.teapot(divs);
		}
		
		
		public static function createDrawable(index:Vector.<uint>,pos:Vector.<Number>,uv:Vector.<Number>,norm:Vector.<Number>,tangent:Vector.<Number>=null):Drawable3D {
			var drawable:Drawable3D = new Drawable3D;
			if(index)
			drawable.index = new IndexBufferSet(index);
			if(pos)
			drawable.pos = new VertexBufferSet(pos,3);
			if(uv)
			drawable.uv = new VertexBufferSet(uv, 2);
			if(norm)
			drawable.norm = new VertexBufferSet(norm, 3);
			if(tangent)
			drawable.tangent = new VertexBufferSet(tangent, 3);
			return drawable;
		}
		
		public static function unpack(drawable:Drawable3D):Drawable3D {
			var newDrawable:Drawable3D = new Drawable3D;
			var idata:Vector.<uint> = drawable.index.data;
			newDrawable.index = new IndexBufferSet(new Vector.<uint>());
			var vbnames:Array = ["pos","uv","norm","joints","weights"];
			for (var i:int = 0; i < idata.length; i += 3 ) {
				newDrawable.index.data.push(i,i+1,i+2);
				for each(var name:String in vbnames) {
					var vb:VertexBufferSet = drawable[name];
					if (vb) {
						var newvb:VertexBufferSet = newDrawable[name];
						if(newvb==null)
						newvb = newDrawable[name] = new VertexBufferSet(new Vector.<Number>(idata.length * vb.data32PerVertex), vb.data32PerVertex);
						var d:int=vb.data32PerVertex
						for (var j:int = 0; j < d; j++) {
							newvb.data[i * d+j] = vb.data[idata[i]*d+j];
							newvb.data[(i+1) * d+j] = vb.data[idata[i+1]*d+j];
							newvb.data[(i+2) * d+j] = vb.data[idata[i+2]*d+j];
						}
						
					}
				}
			}
			return newDrawable;
		}
		
		public static function removeDuplicatedVertices(drawable:Drawable3D):void {
			var posdata:Vector.<Number> = drawable.pos.data;
			//var uvdata:Vector.<Number> = drawable.uv.data;
			var hashToNewVertexId:Object = { };
			var oldVertexIdToNewVertexId:Array = [];
			var newVertexCount:int = 0;
			var newVertexId:uint = 0;
			for (var i:int = 0; i < posdata.length/3;i++ ) {
				var hash:String = posdata[i*3] + "," + posdata[i*3 + 1] + "," + posdata[i*3 + 2]/*+"," + uvdata[i*2]+"," + uvdata[i*2+1]*/;
				var index:Object = hashToNewVertexId[hash];
				if (index==null) {
					newVertexId = newVertexCount++;
					hashToNewVertexId[hash] = newVertexId;
					if (newVertexId!=i) {
						posdata[newVertexId*3] = posdata[i*3];
						posdata[newVertexId*3+1] = posdata[i*3+1];
						posdata[newVertexId*3+2] = posdata[i*3+2];
						//uvdata[newVertexId*2] = uvdata[i*2];
						//uvdata[newVertexId*2+1] = uvdata[i*2+1];
					}
				}else {
					newVertexId = uint(index);
				}
				oldVertexIdToNewVertexId[i] = newVertexId;
			}
			posdata.length = newVertexCount * 3;
			//uvdata.length = newVertexCount * 2;
			
			var idata:Vector.<uint> = drawable.index.data;
			for (i = 0; i < idata.length;i++ ) {
				idata[i] = oldVertexIdToNewVertexId[idata[i]];
			}
		}
		
		public static function computeUV(drawable:Drawable3D):VertexBufferSet {
			var normal:Vector.<Number> = drawable.pos.data;
			var uv:Vector.<Number> = new Vector.<Number>();
			for (var i:int = 0,len:int=normal.length/3; i < len;i++ ) {
				var x:Number = normal[3 * i];
				var y:Number = normal[3 * i + 1];
				var z:Number = normal[3 * i + 2];
				var msg:Number = Math.sqrt(x * x + y * y + z * z);
				if(msg!=0){
					x /= msg;
					y /= msg;
					z /= msg;
				}
				var u:Number = Math.atan2(z, x) / Math.PI / 2+.5;
				var v:Number = Math.asin(y) / Math.PI + .5;
				uv.push(u, v);
			}
			return new VertexBufferSet(uv, 2);
		}
		public static function computeNormal(drawable:Drawable3D):VertexBufferSet
		{
			var norm:Vector.<Number> = new Vector.<Number>(drawable.pos.data.length);
			var vin:Vector.<Number> = drawable.pos.data;
			var idata:Vector.<uint> = drawable.index.data;
			for (var i:int = 0; i < idata.length;i+=3 ) {
				var i0:int = idata[i]*3;
				var i1:int = idata[i + 1]*3;
				var i2:int = idata[i + 2]*3;
				var x0:Number = vin[i0 ];
				var y0:Number = vin[i0 +1];
				var z0:Number = vin[i0 +2];
				var x1:Number = vin[i1];
				var y1:Number = vin[i1+1];
				var z1:Number = vin[i1+2];
				var x2:Number = vin[i2];
				var y2:Number = vin[i2+1];
				var z2:Number = vin[i2+2];
				var nx:Number = (y0 - y2) * (z0 - z1) - (z0 - z2) * (y0 - y1);
				var ny:Number = (z0 - z2) * (x0 - x1) - (x0 - x2) * (z0 - z1);
				var nz:Number = (x0 - x2) * (y0 - y1) - (y0 - y2) * (x0 - x1);
				norm[i0] += nx;
				norm[i1] += nx;
				norm[i2] += nx;
				norm[i0+1] += ny;
				norm[i1+1] += ny;
				norm[i2+1] += ny;
				norm[i0+2] += nz;
				norm[i1+2] += nz;
				norm[i2 + 2] += nz;
			}
			for (i = 0; i < norm.length;i+=3 ) {
				nx = norm[i];
				ny = norm[i+1];
				nz = norm[i+2];
				var distance:Number = Math.sqrt(nx * nx + ny * ny + nz * nz);
				norm[i] /= distance;
				norm[i+1] /= distance;
				norm[i + 2] /= distance;
			}
			return new VertexBufferSet(norm,3);
		}
		
		public static function computeTangent(drawable:Drawable3D) : VertexBufferSet
		{
			var tangent:Vector.<Number> = new Vector.<Number>(drawable.pos.data.length);
			var vin:Vector.<Number> = drawable.pos.data;
			var uv:Vector.<Number> = drawable.uv.data;
			var idata:Vector.<uint> = drawable.index.data;
			for (var i:int = 0; i < idata.length; i+=3)
			{
				var i0:int = idata[i]*3;
				var i1:int = idata[i + 1]*3;
				var i2:int = idata[i + 2]*3;
				var x0:Number = vin[i0 ];
				var y0:Number = vin[i0 +1];
				var z0:Number = vin[i0 +2];
				var x1:Number = vin[i1];
				var y1:Number = vin[i1+1];
				var z1:Number = vin[i1+2];
				var x2:Number = vin[i2];
				var y2:Number = vin[i2+1];
				var z2:Number = vin[i2 + 2];
				
				var uvi0:int = idata[i]*2;
				var uvi1:int = idata[i + 1]*2;
				var uvi2:int = idata[i + 2]*2;
				var u0:Number = uv[uvi0];
				var v0:Number = uv[uvi0+1];
				var u1:Number = uv[uvi1];
				var v1:Number = uv[uvi1+1];
				var u2:Number = uv[uvi2];
				var v2:Number = uv[uvi2+1];
				
				var v0v2	: Number 	= v0 - v2;
				var v1v2 	: Number 	= v1 - v2;
				var coef 	: Number 	= (u0 - u2) * v1v2 - (u1 - u2) * v0v2;
				
				if (coef == 0.)
					coef = 1.;
				else
					coef = 1. / coef;
				
				var tx 	: Number 	= coef * (v1v2 * (x0 - x2) - v0v2 * (x1 - x2));
				var ty 	: Number 	= coef * (v1v2 * (y0 - y2) - v0v2 * (y1 - y2));
				var tz 	: Number 	= coef * (v1v2 * (z0 - z2) - v0v2 * (z1 - z2));
				
				tangent[i0] += tx;
				tangent[i1] += tx;
				tangent[i2] += tx;
				tangent[i0+1] += ty;
				tangent[i1+1] += ty;
				tangent[i2+1] += ty;
				tangent[i0+2] += tz;
				tangent[i1+2] += tz;
				tangent[i2+2] += tz;
			}
			
			for (i = 0; i < tangent.length; i+=3)
			{
				tx = tangent[i];
				ty = tangent[i+1];
				tz = tangent[i+2];
				
				var mag : Number = Math.sqrt(tx * tx + ty * ty + tz * tz);
				
				if (mag != 0.)
				{
					tx /= mag;
					ty /= mag;
					tz /= mag;
				}
				tangent[i] = tx;
				tangent[i+1] = ty;
				tangent[i+2] = tz;
			}
			return new VertexBufferSet(tangent,3);
		}
		
		public static function computeRandom(drawable:Drawable3D,step:int=4) : VertexBufferSet
		{
			var random:Vector.<Number> = new Vector.<Number>(drawable.pos.data.length/3*4);
			for (var i:int = 0; i < random.length/4; )
			{
				var r1:Number = Math.random();
				var r2:Number = Math.random();
				var r3:Number = Math.random();
				var r4:Number = Math.random();
				for (var j:int = 0; j < step; j++,i++ ) {
					random[i*4] = r1;
					random[i*4+1] = r2;
					random[i*4+2] = r3;
					random[i*4+3] = r4;
				}
				
			}
			return new VertexBufferSet(random, 4);
		}
		
		public static function computeSphereRandom(drawable:Drawable3D,step:int=4) : VertexBufferSet
		{
			var randomVec:Vector3D = new Vector3D;
			var random:Vector.<Number> = new Vector.<Number>(drawable.pos.data.length/3*4);
			for (var i:int = 0; i < random.length/4; )
			{
				Utils.randomSphere(randomVec);
				for (var j:int = 0; j < step; j++,i++ ) {
					random[i*4] = randomVec.x;
					random[i*4+1] = randomVec.y;
					random[i*4+2] = randomVec.z;
					random[i*4+3] = randomVec.w;
				}
			}
			return new VertexBufferSet(random, 4);
		}
		
		public static function computeTargetPosition(drawable:Drawable3D) : VertexBufferSet
		{
			var targetPosition:Vector.<Number> = new Vector.<Number>(drawable.pos.data.length);
			var idata:Vector.<uint> = drawable.index.data;
			for (var i:int = 0; i < idata.length; i+=3)
			{
				var j:int = idata[i] * 3;
				targetPosition[j++] = 0;
				targetPosition[j++] = 0;
				targetPosition[j] = 1;
				j = idata[i+1] * 3;
				targetPosition[j++] = 0;
				targetPosition[j++] = 1;
				targetPosition[j] = 0;
				j = idata[i+2] * 3;
				targetPosition[j++] = 1;
				targetPosition[j++] = 0;
				targetPosition[j] = 0;
			}
			return new VertexBufferSet(targetPosition, 3);
		}
		
		public static function computeIndex(drawable:Drawable3D) : IndexBufferSet
		{
			var index:Vector.<uint> = new Vector.<uint>;
			var numt:int = drawable.pos.data.length / 3 / 3;
			for (var i:int = 0; i < numt; i++)
			{
				index.push(i * 3, i * 3 + 1, i * 3 + 2);
			}
			return new IndexBufferSet(index);
		}
		
		/**
		 * 叠加一个drawable
		 * @param	drawable
		 * @param	value 叠加数
		 * @return
		 */
		public static function mul(drawable:Drawable3D,value:int=1):Drawable3D {
			var indexSource:Vector.<uint> = drawable.index.data;
			var posSource:Vector.<Number> = drawable.pos.data;
			var uvSource:Vector.<Number> = drawable.uv.data;
			var index:Vector.<uint> = new Vector.<uint>;
			var pos:Vector.<Number> = new Vector.<Number>;
			var uv:Vector.<Number> = new Vector.<Number>
			var ilen:int = indexSource.length;
			var plen:int = posSource.length / 3;
			for (var i:int = 0; i < value; i++ ) {
				for (var j:int = 0; j < ilen;j++ ) {
					index.push(indexSource[j] + i * plen);
				}
				var len:int;
				for (j = 0,len=posSource.length; j <len;j++ ) {
					pos.push(posSource[j]);
				}
				for (j = 0,len=uvSource.length; j <len;j++ ) {
					uv.push(uvSource[j]);
				}
			}
			return createDrawable(index, pos, uv, null);
		}
	}

}