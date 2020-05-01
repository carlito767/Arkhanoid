import sprites.Sprite;

typedef Bounds = {
  left:Float,
  top:Float,
  right:Float,
  bottom:Float,
}

typedef Point = {
  x:Float,
  y:Float,
}

class Collisions {
  public static function bounds(sprite:Sprite, ?dx:Float = 0, ?dy:Float = 0):Bounds {
    return {
      left:sprite.x + dx,
      top:sprite.y + dy,
      right:sprite.x + sprite.image.width + dx,
      bottom:sprite.y + sprite.image.height + dy,
    };
  }

  public static function collide(spriteA:Sprite, spriteB:Sprite, ?dx:Float = 0, ?dy:Float = 0):Bool {
    return isIntersecting(bounds(spriteA, dx, dy), bounds(spriteB));
  }

  public static function isInside(A:Bounds, point:Point):Bool {
    return point.x >= A.left && point.x <= A.right && point.y >= A.top && point.y <= A.bottom;
  }

  public static function isIntersecting(A:Bounds, B:Bounds) {
    return A.right >= B.left && A.left <= B.right && A.bottom >= B.top && A.top <= B.bottom;
  }
}
