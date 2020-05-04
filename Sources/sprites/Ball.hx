package sprites;

import components.Anchored;
import components.Velocity;

typedef Ball = {
  > Sprite,
  > Velocity,
  anchored:Anchored,
}
