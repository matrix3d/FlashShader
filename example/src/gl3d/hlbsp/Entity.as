/*
 * entity.js
 * 
 * Copyright (c) 2012, Bernhard Manfred Gruber. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301  USA
 */

//'use strict';
package gl3d.hlbsp{

/**
 * Represents an entity in the bsp file.
 */
	public class Entity {
		public var properties:Object={};
		public function Entity(entityString:String)
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
				
				var value:String = entityString.substring(begin + 1, end);
				
				this.properties[key] = value;
			}
		}
	}
}