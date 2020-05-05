import components.Bounds;
import components.Position;
import sprites.Sprite;
import world.Entity;

class Collisions {
  public static function bounds(e:Entity, ?dx:Float = 0.0, ?dy:Float = 0.0):Bounds {
    return {
      left:e.position.x + dx,
      top:e.position.y + dy,
      right:e.position.x + e.image.width + dx,
      bottom:e.position.y + e.image.height + dy,
    };
  }

  // TODO: remove (for compatibility)
  public static function boundsS(sprite:Sprite, ?dx:Float = 0.0, ?dy:Float = 0.0):Bounds {
    return {
      left:sprite.x + dx,
      top:sprite.y + dy,
      right:sprite.x + sprite.image.width + dx,
      bottom:sprite.y + sprite.image.height + dy,
    };
  }

  public static function collide(e1:Entity, e2:Entity, ?dx:Float = 0.0, ?dy:Float = 0.0):Bool {
    return isIntersecting(bounds(e1, dx, dy), bounds(e2));
  }

  // TODO: remove (for compatibility)
  public static function collideES(e:Entity, sprite:Sprite, ?dx:Float = 0.0, ?dy:Float = 0.0):Bool {
    return isIntersecting(bounds(e, dx, dy), boundsS(sprite));
  }

  // TODO: remove (for compatibility)
  public static function collideSE(sprite:Sprite, e:Entity, ?dx:Float = 0.0, ?dy:Float = 0.0):Bool {
    return isIntersecting(boundsS(sprite, dx, dy), bounds(e));
  }

  // TODO: remove (for compatibility)
  public static function collideSS(sprite1:Sprite, sprite2:Sprite, ?dx:Float = 0.0, ?dy:Float = 0.0):Bool {
    return isIntersecting(boundsS(sprite1, dx, dy), boundsS(sprite2));
  }

  public static function isInside(A:Bounds, position:Position):Bool {
    return position.x >= A.left && position.x <= A.right && position.y >= A.top && position.y <= A.bottom;
  }

  public static function isIntersecting(A:Bounds, B:Bounds) {
    return A.right >= B.left && A.left <= B.right && A.bottom >= B.top && A.top <= B.bottom;
  }
}
