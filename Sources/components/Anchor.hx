package components;

import components.Position;
import world.Entity;

//                   x=0
//                    |
//               x<0  |  x>0
//            +---------------+
//        y<0 |               |
//  y=0 ----- |       *       |   <--- Anchor.e
//        y>0 |               |
//            +---------------+
//
typedef Anchor = {
  // Entity to which we are anchored
  e:Entity,
  // Offset from the center of the anchor
  offset:Position,
}
