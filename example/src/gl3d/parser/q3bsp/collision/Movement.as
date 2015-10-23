/*
 * movement.js
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
package gl3d.parser.q3bsp.collision 
{
	import flash.geom.Vector3D;
	import parser.Q3BSP.Q3BSP;
	import parser.Q3BSP.Q3BSPBrush;
	import parser.Q3BSP.Q3BSPBrushside;
	import parser.Q3BSP.Q3BSPLeaf;
	import parser.Q3BSP.Q3BSPNode;
	import parser.Q3BSP.Q3BSPPlane;
	import parser.Q3BSP.Q3BSPTexture;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Movement 
	{
		private var q3c:Q3BSPCollision;
		public var output:Q3BSPCollisionData;
		public function Movement(bsp:Q3BSP) 
		{
			q3c = new Q3BSPCollision(bsp);
		}
		
		/**
		 * Calculates a complete move through the bsp tree from start to end.
		 *
		 * @param start The start position of the movement. An object having at least an x, y, and z component.
		 * @param end The end position of the movement. An object having at least an x, y, and z component.
		 * @param collisionHull The hull of the bsp tree to use for collision detecting. 
		 * @return Returns the final position of the movement as Vector3D. @see Vector3D
		 */
		public function playerMove(start:Vector3D, end:Vector3D,radius:Number,slide:Boolean):Vector3D
		{
			output = null;
			if(start.equals( end))
				return end; // no move

			// create a default trace
			output = q3c.traceSphere(start, end,radius);

			// If the trace ratio is STILL 1.0, then we never collided and just return our end position
			if(output.ratio == 1.0)
				return end;
			else	// else COLLISION!!!!
			{
				// Set our new position to a position that is right up to the plane we collided with
				var d:Vector3D = end.subtract(start);
				d.scaleBy(output.ratio);
				var newPosition:Vector3D = start.add(d);

				if(slide){
					// Get the distance vector from the wanted end point to the actual new position 
					// The distance we have to travel backward from the original end position to the collision point)
					var missingMove:Vector3D = end.subtract( newPosition);

					// Get the distance we need to travel backwards from the end position to the new slide position.
					// (The position we arrive when we collide with a plane and slide along it with the remaining momentum)
					// This is a distance along the normal of the plane we collided with.
					var distance:Number = missingMove.dotProduct(output.plane.normal);

					// Get the final end position that we will end up (after collision and sliding along the plane).
					var nc:Vector3D = output.plane.normal.clone();
					nc.scaleBy(distance);
					var endPosition:Vector3D = end.subtract(nc);

					// Since we got a new position after sliding, we need to make sure
					// that the new sliding position doesn't collide with anything else.
					output = q3c.traceSphere(newPosition, endPosition, radius);
					endPosition = endPosition.subtract(newPosition);
					endPosition.scaleBy(output.ratio);
					newPosition = endPosition.add(newPosition);
				}
				
				// Return the new position
				return newPosition;
			}
		}
	}

}