package gl3d.q3bsp 
{
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Q3BSPEntity 
	{
		public var properties:Object = { };
		/**
		 * The entities lump stores game-related map information, including information about the map name, weapons, health, armor, triggers, spawn points, lights, and .md3 models to be placed in the map.
		 * @param	entityString
		 */
		public function Q3BSPEntity(entityString:String)
		{
			this.parseProperties(entityString);
		}

		/**
		 * Parses the string representation of an entity into an associative array.
		 * @see Bsp.loadEntities().
		 */
		public function parseProperties(entityString:String):void
		{
			var end:int = -1;
			while(true)
			{
				var begin:int = entityString.indexOf('"', end + 1);
				if(begin == -1)
					break;
				end = entityString.indexOf('"', begin + 1);
				
				var key:String = entityString.substring(begin + 1, end);
				
				begin = entityString.indexOf('"', end + 1);
				end = entityString.indexOf('"', begin + 1);
				
				var valueString:String = entityString.substring(begin + 1, end);
				var value:Object;
				switch(key) {
					case 'origin':
						var valueArr:Array= valueString.split(" ");
						value = new Vector3D(
								parseFloat(valueArr[0]),
								parseFloat(valueArr[1]),
								parseFloat(valueArr[2])
							);
						break;
					case 'angle':
						value = parseFloat(valueString);
						break;
					default:
						value = valueString;
						break;
				}
				this.properties[key] = value;
			}
		}
		
	}

}