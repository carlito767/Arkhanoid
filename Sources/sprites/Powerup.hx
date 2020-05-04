package sprites;

import components.Velocity;
import components.PowerupType;

typedef Powerup = {
  > Sprite,
  > Velocity,
  type:PowerupType,
}
