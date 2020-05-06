import components.Bounds;
import components.Position;
import world.Entity;

class Collisions {
  public static function bounds(e:Entity):Bounds {
    return {
      left:e.position.x,
      top:e.position.y,
      right:e.position.x + e.image.width,
      bottom:e.position.y + e.image.height,
    };
  }

  public static function collide(e1:Entity, e2:Entity):Bool {
    return isIntersecting(bounds(e1), bounds(e2));
  }

  public static function isInside(A:Bounds, position:Position):Bool {
    return position.x >= A.left && position.x <= A.right && position.y >= A.top && position.y <= A.bottom;
  }

  public static function isIntersecting(A:Bounds, B:Bounds) {
    return A.right >= B.left && A.left <= B.right && A.bottom >= B.top && A.top <= B.bottom;
  }
}
