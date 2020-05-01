package sprites;

import kha.Image;

import BounceStrategies.BounceStrategy;

typedef Sprite = {
  image:Image,
  ?animation:Animation,
  x:Float,
  y:Float,
  ?bounceStrategy:BounceStrategy,
}
