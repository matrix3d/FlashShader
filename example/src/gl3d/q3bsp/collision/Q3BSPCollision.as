package gl3d.q3bsp.collision 
{
	import flash.geom.Vector3D;
	import parser.Q3BSP.Q3BSP;
	import parser.Q3BSP.Q3BSPBrush;
	import parser.Q3BSP.Q3BSPBrushside;
	import parser.Q3BSP.Q3BSPLeaf;
	import parser.Q3BSP.Q3BSPNode;
	import parser.Q3BSP.Q3BSPPlane;
    public class Q3BSPCollision
    {
		public static const Epsilon:Number = 0.03125 // 1/32
		private var bsp:Q3BSP;
		public function Q3BSPCollision(bsp:Q3BSP) 
		{
			this.bsp = bsp;
		}
		
        public function traceRay(startPosition:Vector3D, endPosition:Vector3D):Q3BSPCollisionData
        {
            var collision:Q3BSPCollisionData = new Q3BSPCollisionData();
            collision.type = Q3BSPCollisionType.Ray;
            return Trace(startPosition, endPosition,collision);
        }

        public function traceSphere(startPosition:Vector3D, endPosition:Vector3D, sphereRadius:Number):Q3BSPCollisionData
        {
            var collision:Q3BSPCollisionData = new Q3BSPCollisionData();
            collision.type = Q3BSPCollisionType.Sphere;
            collision.sphereRadius = sphereRadius;
            return Trace(startPosition, endPosition,  collision);
        }

        public function traceBox(startPosition:Vector3D, endPosition:Vector3D, boxMinimums:Vector3D,boxMaximums:Vector3D):Q3BSPCollisionData
        {
			var collision:Q3BSPCollisionData = new Q3BSPCollisionData();

            if (boxMinimums.x == 0 && boxMinimums.y == 0 && boxMinimums.z == 0 && boxMaximums.x == 0 && boxMaximums.y == 0 && boxMaximums.z == 0)
            {
                collision.type = Q3BSPCollisionType.Ray;
                return Trace(startPosition, endPosition, collision);
            }

            if (boxMaximums.x < boxMinimums.x)
            {
                var x:Number = boxMaximums.x;
                boxMaximums.x = boxMinimums.x;
                boxMinimums.x = x;
            }
            if (boxMaximums.y < boxMinimums.y)
            {
                var y:Number = boxMaximums.y;
                boxMaximums.y = boxMinimums.y;
                boxMinimums.y = y;
            }
            if (boxMaximums.z < boxMinimums.z)
            {
                var z:Number = boxMaximums.z;
                boxMaximums.z = boxMinimums.z;
                boxMinimums.z = z;
            }

            var boxExtents:Vector3D = new Vector3D();
            boxExtents.x = Math.max(Math.abs(boxMaximums.x), Math.abs(boxMinimums.x));
            boxExtents.y = Math.max(Math.abs(boxMaximums.y), Math.abs(boxMinimums.y));
            boxExtents.z = Math.max(Math.abs(boxMaximums.z), Math.abs(boxMinimums.z));

            collision.type = Q3BSPCollisionType.Box;
            collision.boxMinimums = boxMinimums;
            collision.boxMaximums = boxMaximums;
            collision.boxExtents = boxExtents;
            return Trace(startPosition, endPosition,collision);
        }
         
        private function Trace(startPosition:Vector3D,  endPosition:Vector3D, collision:Q3BSPCollisionData):Q3BSPCollisionData
        {
            collision.startOutside = true;
            collision.inSolid = false;
            collision.ratio = 1.0;
            collision.startPosition = startPosition;
            collision.endPosition = endPosition;
            collision.collisionPoint = startPosition;

            walkNode(0, 0.0, 1.0, startPosition, endPosition, collision);

            if (1.0 == collision.ratio)
            {
                collision.collisionPoint = endPosition;
            }
            else
            {
                collision.collisionPoint = endPosition.subtract(startPosition);
				collision.collisionPoint.scaleBy(collision.ratio - 0.002);
				collision.collisionPoint = startPosition.add(collision.collisionPoint);
            }

            return collision;
        }

        private function walkNode(nodeIndex:int, startRatio:Number, endRatio:Number, startPosition:Vector3D, endPosition:Vector3D, cd: Q3BSPCollisionData):void
        {
            // Is this a leaf?
            if (0 > nodeIndex)
            {
                var leaf:Q3BSPLeaf = bsp.leafs[-(nodeIndex + 1)];
                for (var i:int = 0; i < leaf.n_leafbrushes; i++)
                {
                    var brush:Q3BSPBrush = bsp.brushes[bsp.leafbrushes[leaf.leafbrush + i].brush];
                    if (0 < brush.n_brushsides &&
                        1 == (bsp.textures[brush.texture].contents & 1))
                    {
                        checkBrush(brush, cd);
                    }
                }

                return;
            }

            // This is a node
            var thisNode:Q3BSPNode = bsp.nodes[nodeIndex];
            var thisPlane:Q3BSPPlane = bsp.planes[thisNode.plane];
            var startDistance:Number = startPosition.dotProduct( thisPlane.normal) - thisPlane.distance;
            var endDistance:Number = endPosition.dotProduct( thisPlane.normal) - thisPlane.distance;
            var offset:Number = 0; 

            // Set offset for sphere-based collision
            if (cd.type == Q3BSPCollisionType.Sphere)
            {
                offset = cd.sphereRadius;
            }

            // Set offest for box-based collision
            if (cd.type == Q3BSPCollisionType.Box)
            {
                offset = Math.abs(cd.boxExtents.x * thisPlane.normal.x) + Math.abs(cd.boxExtents.y * thisPlane.normal.y) + Math.abs(cd.boxExtents.z * thisPlane.normal.z);
            }

            if (startDistance >= offset && endDistance >= offset)
            {
                // Both points are in front
                walkNode(thisNode.children[0], startRatio, endRatio, startPosition, endPosition,  cd);
            }
            else if (startDistance < -offset && endDistance < -offset)
            {
                walkNode(thisNode.children[1], startRatio, endRatio, startPosition, endPosition, cd);
            }
            else
            {
                // The line spans the splitting plane
                var side:int = 0;
                var fraction1:Number = 0.0;
                var fraction2:Number = 0.0;
                var middleFraction:Number = 0.0;
                var middlePosition :Vector3D;

                if (startDistance < endDistance)
                {
                    side = 1;
                    var inverseDistance:Number = 1.0 / (startDistance - endDistance);
                    fraction1 = (startDistance - offset + Epsilon) * inverseDistance;
                    fraction2 = (startDistance + offset + Epsilon) * inverseDistance;
                }
                else if (endDistance < startDistance)
                {
                    side = 0;
                    inverseDistance = 1.0 / (startDistance - endDistance);
                    fraction1 = (startDistance + offset + Epsilon) * inverseDistance;
                    fraction2 = (startDistance - offset - Epsilon) * inverseDistance;
                }
                else
                {
                    side = 0;
                    fraction1 = 1.0;
                    fraction2 = 0.0;
                }

                if (fraction1 < 0.0) fraction1 = 0.0;
                else if (fraction1 > 1.0) fraction1 = 1.0;
                if (fraction2 < 0.0) fraction2 = 0.0;
                else if (fraction2 > 1.0) fraction2 = 1.0;

                middleFraction = startRatio + (endRatio - startRatio) * fraction1;
                middlePosition = endPosition.subtract(startPosition);
				middlePosition.scaleBy(fraction1);
				middlePosition=startPosition.add(middlePosition);

                var side1:int;
                var side2:int;
                if (0 == side)
                {
                    side1 = thisNode.children[0];
                    side2 = thisNode.children[1];
                }
                else
                {
                    side1 = thisNode.children[1];
                    side2 = thisNode.children[0];
                }

                walkNode(side1, startRatio, middleFraction, startPosition, middlePosition,cd);

                middleFraction = startRatio + (endRatio - startRatio) * fraction2;
                middlePosition = endPosition.subtract(startPosition);
				middlePosition.scaleBy(fraction2);
				middlePosition = startPosition.add(middlePosition);

                walkNode(side2, middleFraction, endRatio, middlePosition, endPosition, cd);
            }
        }

        private function checkBrush(brush:Q3BSPBrush, cd:Q3BSPCollisionData):void
        {
            var startFraction:Number = -1.0;
            var endFraction:Number = 1.0;
            var startsOut:Boolean = false;
            var endsOut:Boolean = false;
			var nowPlane:Q3BSPPlane;
            for (var i:int = 0; i < brush.n_brushsides; i++)
            {
                var brushSide:Q3BSPBrushside = bsp.brushsides[brush.brushside + i];
                var plane:Q3BSPPlane = bsp.planes[brushSide.plane];

                var startDistance:Number = 0, endDistance:Number = 0;
                
                if(cd.type == Q3BSPCollisionType.Ray)
                {
                    startDistance = cd.startPosition.dotProduct( plane.normal) - plane.distance;
                    endDistance = cd.endPosition.dotProduct( plane.normal) - plane.distance;
                }

                else if (cd.type == Q3BSPCollisionType.Sphere)
                {
                    startDistance = cd.startPosition.dotProduct( plane.normal) - (plane.distance + cd.sphereRadius);
                    endDistance = cd.endPosition.dotProduct( plane.normal) - (plane.distance + cd.sphereRadius);
                }

                else if (cd.type == Q3BSPCollisionType.Box)
                {
                    var offset:Vector3D = new Vector3D();
                    if (plane.normal.x < 0)
                        offset.x = cd.boxMaximums.x;
                    else
                        offset.x = cd.boxMinimums.x;

                    if (plane.normal.y < 0)
                        offset.y = cd.boxMaximums.y;
                    else
                        offset.y = cd.boxMinimums.y;
                    
                    if (plane.normal.z < 0)
                        offset.z = cd.boxMaximums.z;
                    else
                        offset.z = cd.boxMinimums.z;

                    startDistance = (cd.startPosition.x + offset.x) * plane.normal.x +
                                    (cd.startPosition.y + offset.y) * plane.normal.y +
                                    (cd.startPosition.z + offset.z) * plane.normal.z -
                                    plane.distance;

                    endDistance = (cd.endPosition.x + offset.x) * plane.normal.x +
                                  (cd.endPosition.y + offset.y) * plane.normal.y +
                                  (cd.endPosition.z + offset.z) * plane.normal.z -
                                  plane.distance;
                }

                if (startDistance > 0)
                    startsOut = true;
                if (endDistance > 0)
                    endsOut = true;

                if (startDistance > 0 && endDistance > 0)
                {
                    return;
                }

                if (startDistance <= 0 && endDistance <= 0)
                {
                    continue;
                }

                if (startDistance > endDistance)
                {
                    var fraction:Number = (startDistance - Epsilon) / (startDistance - endDistance);
                    if (fraction > startFraction) {
						nowPlane = plane;
                        startFraction = fraction;
					}
                }
                else
                {
                    fraction = (startDistance + Epsilon) / (startDistance - endDistance);
                    if (fraction < endFraction)
                        endFraction = fraction;
                }
            }

            if (false == startsOut)
            {
                cd.startOutside = false;
                if (false == endsOut)
                    cd.inSolid = true;

                return;
            }

            if (startFraction < endFraction)
            {
                if (startFraction > -1.0 && startFraction < cd.ratio)
                {
					cd.plane = nowPlane;
                    if (startFraction < 0)
                        startFraction = 0;
                    cd.ratio = startFraction;
                }
            }
        }
    }
}