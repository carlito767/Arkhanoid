import Math.PI;

import components.Bounds;
import world.Entity;
using Collisions;

class BounceStrategies {
  static var HALF_PI(get,never):Float; static inline function get_HALF_PI() { return PI * 0.5; };
  static var TWO_PI(get,never):Float; static inline function get_TWO_PI() { return PI * 2; };

  // A value will be chosen at random between this and it's negative
  // to apply to the angle of bounce for top/bottom/side collisions of the ball
  static inline var RANDOM_RANGE = 0.1; // radians

  public static function bounceStrategy(ball:Entity, collisions:Array<Bounds>):Float {
    if (collisions.isEmpty()) return ball.angle;

    var angle = ball.angle;

    // Determine collide points
    var tl = false;
    var tr = false;
    var bl = false;
    var br = false;

    var bb = ball.bounds();
    for (collision in collisions) {
      tl = tl || collision.isInside({x:bb.left, y:bb.top});
      tr = tr || collision.isInside({x:bb.right, y:bb.top});
      bl = bl || collision.isInside({x:bb.left, y:bb.bottom});
      br = br || collision.isInside({x:bb.right, y:bb.bottom});
    }

    var collideTrue = [tl, tr, bl, br].filter((v)->{v == true;});
    if (collideTrue.length == 1) {
      if (tl) {
        if (angle > TWO_PI - HALF_PI)
          tr = true;
        else if (angle < PI) {
          bl = true;
        }
      }
      else if (tr) {
        if (angle >= PI && angle <= TWO_PI - HALF_PI) {
          tl = true;
        }
        else if (angle < HALF_PI) {
          br = true;
        }
      }
      else if (bl) {
        if (angle < HALF_PI) {
          br = true;
        }
        else if (angle > PI) {
          tl = true;
        }
      }
      else if (br) {
        if (angle <= PI && angle > HALF_PI) {
          bl = true;
        }
        else if (angle > TWO_PI - HALF_PI) {
          tr = true;
        }
      }
    }

    // Determine new angle
    switch collideTrue.length {
      case 1 | 3 | 4:
        angle += (angle > PI) ? -PI : PI;
        if (collideTrue.length == 1) {
          // Add some randomness to corner collisions to prevent bounce
          // loops
          angle += RANDOM_RANGE - (2 * RANDOM_RANGE * Math.random());
        }
      case _:
        var topCollision = tl && tr && angle > PI;
        var bottomCollision = bl && br && angle < PI;
        if (topCollision || bottomCollision) {
          angle = TWO_PI - angle;
          // Prevent vertical bounce loops by detecting near vertical
          // angles and adjusting the angle of bounce
          if (angle > (TWO_PI - HALF_PI - 0.06) && angle < (TWO_PI - HALF_PI + 0.06)) {
            angle += 0.35;
          }
          else if (angle < (HALF_PI + 0.06) && angle > (HALF_PI - 0.06)) {
            angle += 0.35;
          }
        }
        else {
          var leftCollision = tl && bl && angle > HALF_PI && angle < (TWO_PI - HALF_PI);
          var rightCollision = tr && br && (angle > (TWO_PI - HALF_PI) || angle < HALF_PI);
          if (leftCollision || rightCollision) {
            angle = (angle < PI) ? (PI - angle) : TWO_PI - angle + PI;
            // Prevent horizontal bounce loops by detecting near
            // horizontal angles and adjusting the angle of bounce
            if (angle > (PI - 0.06) && angle < (PI + 0.06)) {
              angle += 0.35;
            }
            else if (angle > TWO_PI - 0.06) {
              angle -= 0.35;
            }
            else if (angle < 0.06) {
              angle += 0.35;
            }
          }

          // Add a small amount of randomness to the bounce to make it a
          // little more unpredictable, and to prevent the ball from getting
          // stuck in a repeating bounce loop
          angle += RANDOM_RANGE - (2 * RANDOM_RANGE * Math.random());
        }
    }

    return angle;
  }

  public static function bounceStrategyPaddle(ball:Entity, collision:Bounds):Float {
    // Logically break the paddle into 6 segments
    // Each segment triggers a different angle of bounce
    var segmentSize = Math.floor((collision.right - collision.left) / 6);

    // The bounce angles corresponding to each of the 6 segments
    var angles = [220, 245, 260, 280, 295, 320]; // degrees

    var bb = ball.bounds();
    for (i in 0...6) {
      var left = collision.left + segmentSize * i;
      var width = (i == 5) ? (collision.right - collision.left) - (segmentSize * 5) : segmentSize;
      if (bb.isIntersecting({left:left, top:collision.top, right:left + width, bottom:collision.bottom})) {
        return (PI / 180 * angles[i]);
      }
    }

    // Should never happen
    return ball.angle;
  }
}
