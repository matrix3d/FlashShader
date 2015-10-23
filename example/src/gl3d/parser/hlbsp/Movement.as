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
package gl3d.parser.hlbsp 
{
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Movement 
	{
		 /** Defines the epsilon used for collision detection */
		public var EPSILON:Number = 0.03125 // 1/32
		public var bsp:Bsp;
		public var hull:int;
		public function Movement(bsp:Bsp) 
		{
			this.bsp = bsp;
			
		}
		
		/**
		 * Calculates a complete move through the bsp tree from start to end.
		 *
		 * @param start The start position of the movement. An object having at least an x, y, and z component.
		 * @param end The end position of the movement. An object having at least an x, y, and z component.
		 * @param collisionHull The hull of the bsp tree to use for collision detecting. 
		 * @return Returns the final position of the movement as Vector3D. @see Vector3D
		 */
		public function playerMove(start:Vector3D, end:Vector3D, collisionHull:int=0):Vector3D
		{
			hull = collisionHull;
			
			return traceLine(start, end);
		}

		//
		// The following code has been taken from mainly from the Quake 1 source code.
		//

		

		/**
		 * Traces a line inside the current clipping hull.
		 * @param start The start position of the movement. An object having at least an x, y, and z component.
		 * @param end The end position of the movement. An object having at least an x, y, and z component.
		 * @return Returns the final position of the movement as Vector3D. @see Vector3D
		 */
		public function traceLine(start:Vector3D, end:Vector3D):Vector3D
		{
			if(start.equals( end))
				return end; // no move

			// create a default trace
			var trace:Trace = new Trace();
			trace.allsolid = true;
			trace.plane = null;
			trace.ratio = 1.0;

			// We start with the first node (0), setting our start and end ratio to 0 and 1.
			// We will recursively go through all of the clipnodes and try to find collisions with their planes.
			recursiveHullCheck(bsp.models[0].headNodes[hull], 0.0, 1.0, start, end, trace);

			// If the trace ratio is STILL 1.0, then we never collided and just return our end position
			if(trace.ratio == 1.0)
				return end;
			else	// else COLLISION!!!!
			{
				// Set our new position to a position that is right up to the plane we collided with
				var d:Vector3D = end.subtract(start);
				d.scaleBy(trace.ratio);
				var newPosition:Vector3D = start.add(d);

				// Get the distance vector from the wanted end point to the actual new position 
				// The distance we have to travel backward from the original end position to the collision point)
				var missingMove:Vector3D = end.subtract( newPosition);

				// Get the distance we need to travel backwards from the end position to the new slide position.
				// (The position we arrive when we collide with a plane and slide along it with the remaining momentum)
				// This is a distance along the normal of the plane we collided with.
				var distance:Number = missingMove.dotProduct(trace.plane.normal);

				// Get the final end position that we will end up (after collision and sliding along the plane).
				var nc:Vector3D = trace.plane.normal.clone();
				nc.scaleBy(distance);
				var endPosition:Vector3D = end.subtract(nc);

				// Since we got a new position after sliding, we need to make sure
				// that the new sliding position doesn't collide with anything else.
				newPosition = traceLine(newPosition, endPosition);

				// Return the new position
				return newPosition;
			}
		}

		/**
		 * Traverses the clipping hull down to the content (see defines in bspdef).
		 * @param The clipnodes index to get the content at a position.
		 * @param The point to get the content for.
		 * @return Returns the content at the given point. (see defines in bspdef)
		 */
		public function hullPointContents(nodeIndex:int, point:Vector3D):int
		{
			while (nodeIndex >= 0)
			{
				var node:BspClipNode = bsp.clipNodes[nodeIndex];
				var plane:BspPlane = bsp.planes[node.plane];
				
				var d:Number = plane.normal.dotProduct( point) - plane.dist;
					
				if (d < 0)
					nodeIndex = node.children[1];
				else
					nodeIndex = node.children[0];
			}

			return nodeIndex;
		}

		/**
		 * Recursively checks a part of the traced line against the collision hull.
		 *
		 * @param nodeIndex The index of the clipnode currently checked.
		 * @param startFraction The start fraction for this node between 0.0 and 1.0 on the currently traced line.
		 * @param endFraction The end fraction for this node between 0.0 and 1.0 on the currently traced line.
		 * @param startPoint The start point for this node on the currently traced line.
		 * @param endPoint The end point for this node on the currently traced line.
		 * @param trace Reference to the current trace data.
		 * @return Returns true, if the current node index is not a clipnode but a content identifier (see defines in bspdef),
		 *         meaning a leaf of the clipnode tree has been reached.
		 */
		public function recursiveHullCheck(nodeIndex:int, startFraction:Number, endFraction:Number, startPoint:Vector3D, endPoint:Vector3D, trace:Trace):Boolean
		{
			// check for empty
			if (nodeIndex < 0)
			{
				if (nodeIndex != Bsp.CONTENTS_SOLID)
					trace.allsolid = false;

				return true; // empty
			}

			// find the point distances
			var node:BspClipNode = bsp.clipNodes[nodeIndex];
			var plane:BspPlane = bsp.planes[node.plane];

			var t1:Number, t2:Number;

			t1 = plane.normal.dotProduct( startPoint) - plane.dist;
			t2 = plane.normal.dotProduct( endPoint) - plane.dist;

			if (t1 >= 0.0 && t2 >= 0.0)
				return recursiveHullCheck(node.children[0], startFraction, endFraction, startPoint, endPoint, trace);
			if (t1 < 0.0 && t2 < 0.0)
				return recursiveHullCheck(node.children[1], startFraction, endFraction, startPoint, endPoint, trace);

			// put the crosspoint EPSILON pixels on the near side
			var frac:Number;

			if (t1 < 0.0)
				frac = (t1 + EPSILON) / (t1 - t2);
			else
				frac = (t1 - EPSILON) / (t1 - t2);
			if (frac < 0.0)
				frac = 0.0;
			if (frac > 1.0)
				frac = 1.0;

			var midf:Number = startFraction + (endFraction - startFraction) * frac;
			var d:Vector3D = endPoint.subtract(startPoint);
			d.scaleBy(frac);
			var midPoint:Vector3D = startPoint.add(d);

			var side:int = (t1 < 0) ? 1 : 0;

			// move up to the node
			if (!recursiveHullCheck(node.children[side], startFraction, midf, startPoint, midPoint, trace))
				return false;

			if (hullPointContents(node.children[side ^ 1], midPoint) != Bsp.CONTENTS_SOLID)
				// go past the node
				return recursiveHullCheck (node.children[side ^ 1], midf, endFraction, midPoint, endPoint, trace);

			if (trace.allsolid)
				return false; // never got out of the solid area

			// the other side of the node is solid, this is the impact point
			if (!side)
				trace.plane = plane;
			else
			{
				trace.plane = new BspPlane();
				trace.plane.normal = plane.normal.clone();
				trace.plane.normal.negate();
				trace.plane.dist = -plane.dist;
			}

			while(hullPointContents(bsp.models[0].headNodes[hull], midPoint) == Bsp.CONTENTS_SOLID)
			{
				// shouldn't really happen, but does occasionally
				frac -= 0.1;
				if (frac < 0)
				{
					trace.ratio = midf;
					return false;
				}
				midf = startFraction + (endFraction - startFraction) * frac;
				d = endPoint.subtract(startPoint);
				d.scaleBy(frac);
				midPoint = startPoint.add(d);
			}

			trace.ratio = midf;
			
			return false;
		}
		
	}

}