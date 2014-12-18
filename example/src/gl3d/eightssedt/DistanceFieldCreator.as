package gl3d.eightssedt 
{
	import flash.display.BitmapData;
	/**
	 * ...
	 * @author lizhi
	 */
	public class DistanceFieldCreator 
	{
		
		public function DistanceFieldCreator() 
		{
			
		}
		
		public static function create(bmd:BitmapData):BitmapData {
			var width:int = bmd.width;
			var height:int = bmd.height;
			
			var pixs:Vector.<uint> = new Vector.<uint>;
			for( var y:int=0;y<height;y++ )
			{
				for ( var x:int=0;x<width;x++ )
				{
					var c:int = bmd.getPixel32(x, y) >>> 24;
					c = 0xff - c;
					var col32:uint = (c) | (c << 8) | (c << 16) | (c << 24);
					pixs.push(col32);
				}
			}
			var rbmd:BitmapData = new BitmapData(width, height, true, 0);
			rbmd.setVector(rbmd.rect, pixs);
			return rbmd;
		}
		
		public static function create8ssedt(bmd:BitmapData):BitmapData {
			
			var WIDTH:int = bmd.width;
			var HEIGHT:int = bmd.height;
			var grid:Grid = new Grid(WIDTH, HEIGHT);
			for( var y:int=0;y<HEIGHT;y++ )
			{
				for ( var x:int=0;x<WIDTH;x++ )
				{
					// Points inside get marked with a dx/dy of zero.
					// Points outside get marked with an infinitely large distance.
					var col:uint = bmd.getPixel(x, y) & 0xff;
					if (col==0) {
						grid.Put( x, y, Grid.empty );
					}else if (col==0xff) {
						grid.Put(x, y, Grid.inside);
					}else{
						
					}
					if ( col > 128 )
					{
						grid.Put( x, y, Grid.empty );
					} else {
						grid.Put(  x, y, Grid.inside );
					}
				}
			}
			// Generate the SDF.
			grid.GenerateSDF( );
			
			var pixs:Vector.<uint> = new Vector.<uint>;
			// Render out the results.
			for(  y=0;y<HEIGHT;y++ )
			{
				for (  x=0;x<WIDTH;x++ )
				{
					// Calculate the actual distance from the dx/dy
					var dist:int =  Math.sqrt( grid.Get( x, y ).DistSq() ) ;

					// Clamp and scale it, just for display purposes.
					var c:int = 0xff - dist * 0xff / 10;
					
					if ( c < 0 ) c = 0;
					if ( c > 255 ) c = 255;
					var col32:uint = (c) | (c << 8) | (c << 16) | (c << 24);
					pixs.push(col32);
				}
			}
			var rbmd:BitmapData = new BitmapData(WIDTH, HEIGHT, true, 0);
			rbmd.setVector(rbmd.rect, pixs);
			return rbmd;
		}
		
	}

}