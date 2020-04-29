package sprites;

import kha.Image;

import Collisions.BounceStrategy;

typedef Sprite = {
  image:Image,
  ?animation:Animation,
  x:Float,
  y:Float,
  ?bounceStrategy:BounceStrategy,
}
