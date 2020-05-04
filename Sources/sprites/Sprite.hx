package sprites;

import components.Animation;
import components.BounceStrategy;
import components.Image;
import components.Position;

typedef Sprite = {
  > Position,
  image:Image,
  ?animation:Animation,
  ?bounceStrategy:BounceStrategy,
}
