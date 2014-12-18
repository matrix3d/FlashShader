package gl3d.eightssedt 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class Grid 
	{
		private var WIDTH:int;
		private var HEIGHT:int;
		private var grid:Vector.<Vector.<Point>> = new Vector.<Vector.<Point>>;
		
		public function Grid(WIDTH:int,HEIGHT:int) 
		{
			this.HEIGHT = HEIGHT;
			this.WIDTH = WIDTH;
			for (var y:int = 0; y < HEIGHT;y++ ) {
				grid[y] = new Vector.<Point>(WIDTH);
			}
		}
		
		public static var EMPTY:Point = empty;
		public function Get(x:int, y:int):Point {
			if ( x >= 0 && y >= 0 && x < WIDTH && y < HEIGHT )
				return grid[y][x];
			else
				return EMPTY;
		}
		
		public function Put( x:int, y:int, p:Point ):void
		{
			grid[y][x] = p;
		}

		private var help:Point = new Point(0,0);
		public function Compare(p:Point, x:int, y:int, offsetx:int, offsety:int ):void
		{
			var other:Point = Get(  x + offsetx, y + offsety );
			help.dx = other.dx;
			help.dy = other.dy;
			other = help;
			other.dx += offsetx;
			other.dy += offsety;

			if (other.DistSq() < p.DistSq()) {
				p.dx = other.dx;
				p.dy = other.dy;
			}
		}

		public function GenerateSDF():void
		{
			// Pass 0
			for (var y:int=0;y<HEIGHT;y++)
			{
				for (var x:int=0;x<WIDTH;x++)
				{
					var p:Point = Get(x, y );
					Compare(p, x, y, -1,  0 );
					Compare(p, x, y,  0, -1 );
					Compare(p, x, y, -1, -1 );
					Compare(p, x, y,  1, -1 );
				}

				for (x=WIDTH-1;x>=0;x--)
				{
					p = Get( x, y );
					Compare( p, x, y, 1, 0 );
				}
			}

			// Pass 1
			for (y=HEIGHT-1;y>=0;y--)
			{
				for (x=WIDTH-1;x>=0;x--)
				{
					p = Get(  x, y );
					Compare(  p, x, y,  1,  0 );
					Compare(  p, x, y,  0,  1 );
					Compare(  p, x, y, -1,  1 );
					Compare(  p, x, y,  1,  1 );
				}

				for (x=0;x<WIDTH;x++)
				{
					p = Get(  x, y );
					Compare( p, x, y, -1, 0 );
				}
			}
		}
		
		static public function get inside():Point 
		{
			return new Point( 0, 0 );
		}
		
		static public function get empty():Point 
		{
			return new Point( 9999, 9999 );
		}
	}

}