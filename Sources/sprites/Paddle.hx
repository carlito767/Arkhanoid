package sprites;

import components.BounceStrategy;
import components.Velocity;

typedef Paddle = {
  > Sprite,
  > Velocity,
  ?bounceStrategy:BounceStrategy,
}
