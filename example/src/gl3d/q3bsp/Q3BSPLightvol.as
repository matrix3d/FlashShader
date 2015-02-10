package gl3d.q3bsp 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class Q3BSPLightvol 
	{
		/*Lightvols make up a 3D grid whose dimensions are:

nx = floor(models[0].maxs[0] / 64) - ceil(models[0].mins[0] / 64) + 1
ny = floor(models[0].maxs[1] / 64) - ceil(models[0].mins[1] / 64) + 1
nz = floor(models[0].maxs[2] / 128) - ceil(models[0].mins[2] / 128) + 1
lightvol

ubyte[3] ambient	Ambient color component. RGB.
ubyte[3] directional	Directional color component. RGB.
ubyte[2] dir	Direction to light. 0=phi, 1=theta.*/
		/**
		 * The lightvols lump stores a uniform grid of lighting information used to illuminate non-map objects. 
		 */
		public function Q3BSPLightvol() 
		{
			
		}
		
	}

}