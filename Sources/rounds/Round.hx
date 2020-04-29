package rounds;

import kha.Assets;
import kha.Color;
import kha.graphics2.Graphics;

import sprites.Ball;
import sprites.Brick;
import sprites.Edge;
import sprites.Paddle;
import sprites.Sprite;
using AnimationExtension;

import Math.PI;

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

class Round {
  public var id(default,null):Int;
  public var backgroundColor(default,null):Color = Color.Black;
  public var lives:Int;

  public var moveLeft:Bool = false;
  public var moveRight:Bool = false;

  public var balls(default,null):List<Ball> = new List();
  public var bricks(default,null):Array<Brick> = [];
  public var paddle:Null<Paddle> = null;

  static inline var TOP_OFFSET = 150;

  static inline var PADDLE_SPEED = 10;

  static inline var BALL_START_ANGLE_RAD = 5.0;
  static inline var BALL_BASE_SPEED = 8.0;

  // (left,top)
  //      +---------------+
  //      |               |
  //      |               |
  //      |               |
  //      |               |
  //      |               |
  //      +---------------+
  //                (right,bottom)
  var boundLeft(get,never):Float; inline function get_boundLeft() return edgeLeft.x + edgeLeft.image.width;
  var boundTop(get,never):Float; inline function get_boundTop() return edgeTop.y + edgeTop.image.height;
  var boundRight(get,never):Float; inline function get_boundRight() return edgeRight.x;
  var boundBottom(get,never):Float; inline function get_boundBottom() return Game.HEIGHT;

  var edgeLeft:Edge;
  var edgeRight:Edge;
  var edgeTop:Edge;

  public function new(id:Int, lives:Int) {
    this.id = id;
    this.lives = lives;

    // Create edges
    var imageLeft = Assets.images.edge_left;
    var imageRight = Assets.images.edge_right;
    var imageTop = Assets.images.edge_top;
    edgeLeft = {image:imageLeft, x:0, y:TOP_OFFSET};
    edgeRight = {image:imageRight, x:Game.WIDTH - imageRight.width, y:TOP_OFFSET};
    edgeTop = {image:imageTop, x:imageLeft.width, y:TOP_OFFSET};

    // Create bricks
    bricks = createBricks();
  }

  public function update(game:Game):Void {
    // Update paddle
    var dx = 0.0;
    if (paddle != null) {
      // Animate paddle
      var image = paddle.image;
      animateSprite(paddle);

      // Center paddle (and adjust its balls)
      var dw = (image.width - paddle.image.width) * 0.5;
      var dh = (image.height - paddle.image.height) * 0.5;
      if (dw != 0 || dh != 0) {
        paddle.x += dw;
        paddle.y += dh;
        for (ball in balls) {
          if (ball.anchored) {
            ball.x += dw;
            ball.y += dh;
          }
        }
      }

      // Detect paddle movement
      if (moveLeft && !moveRight) {
        dx = -paddle.speed;
      }
      else if (moveRight && !moveLeft) {
        dx = paddle.speed;
      }

      // Detect collision between paddle and edges
      if (collide(paddle, edgeLeft, dx)) {
        dx = boundLeft - paddle.x;
      }
      if (collide(paddle, edgeRight, dx)) {
        dx = boundRight - (paddle.x + paddle.image.width);
      }

      paddle.x += dx;
    }

    // Update balls
    for (ball in balls) {
      if (ball.anchored) {
        ball.x += dx;
      }
      else {
        var collisions = new List<Bounds>();

        // Detect collision between ball and edges
        for (edge in [edgeLeft, edgeRight, edgeTop]) {
          if (collide(ball, edge)) {
            collisions.add(bounds(edge));
          }
        }

        // Detect collision between ball and bricks
        for (brick in bricks) {
          if (collide(ball, brick)) {
            collisions.add(bounds(brick));
            // TODO: remove fake score
            game.score += 100;
          }
        }

        // Detect collision between ball and paddle
        if (collide(ball, paddle)) {
          collisions.add(bounds(paddle));
        }

        // Determine new angle for ball
        if (!collisions.isEmpty()) {
          newAngleForBall(ball, collisions);
        }

        ball.x += ball.speed * Math.cos(ball.angle);
        ball.y += ball.speed * Math.sin(ball.angle);

        if (ball.y >= boundBottom) {
          balls.remove(ball);
        }
      }
    }

    // Animate the bricks
    for (brick in bricks) {
      animateSprite(brick);
    }
  }

  public function render(g2:Graphics):Void {
    // Draw background
    g2.color = backgroundColor;
    g2.fillRect(0, TOP_OFFSET, Game.WIDTH, Game.HEIGHT - TOP_OFFSET);

    g2.color = Color.White;

    // Draw edges
    for (edge in [edgeLeft, edgeRight, edgeTop]) {
      g2.drawImage(edge.image, edge.x, edge.y);
    }

    // Draw bricks
    for (brick in bricks) {
      g2.drawImage(brick.image, brick.x, brick.y);
    }

    // Draw lives
    var paddleLife = Assets.images.paddle_life;
    var x = boundLeft;
    var y = boundBottom - paddleLife.height - 5;
    for (i in 1...lives) {
      g2.drawImage(paddleLife, x, y);
      x += paddleLife.width + 5;
    }

    // Draw paddle
    if (paddle != null) {
      g2.drawImage(paddle.image, paddle.x, paddle.y);
    }

    // Draw ball
    for (ball in balls) {
      g2.drawImage(ball.image, ball.x, ball.y);
    }
  }

  //
  // Animation
  //

  function animateSprite(sprite:Sprite):Void {
    if (sprite.animation == null) return;

    var image = sprite.animation.tick();
    if (image == null) {
      sprite.animation = null;
    }
    else {
      sprite.image = image;
    }
  }

  //
  // Collisions
  //

  static var HALF_PI(get,never):Float; static inline function get_HALF_PI() { return PI * 0.5; };
  static var TWO_PI(get,never):Float; static inline function get_TWO_PI() { return PI * 2; };

  // A value will be chosen at random between this and it's negative
  // to apply to the angle of bounce for top/bottom/side collisions of the ball
  static inline var RANDOM_RANGE = 0.1; // Radians

  function newAngleForBall(ball:Ball, collisions:List<Bounds>):Void {
    if (collisions.isEmpty()) return;

    var angle = ball.angle;

    // Determine collide points
    var tl = false;
    var tr = false;
    var bl = false;
    var br = false;

    var bb = bounds(ball);
    for (collision in collisions) {
      tl = tl || isInside(collision, {x:bb.left, y:bb.top});
      tr = tr || isInside(collision, {x:bb.right, y:bb.top});
      bl = bl || isInside(collision, {x:bb.left, y:bb.bottom});
      br = br || isInside(collision, {x:bb.right, y:bb.bottom});
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
    switch (collideTrue.length) {
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

    ball.angle = angle;
  }

  function bounds(sprite:Sprite, ?dx:Float = 0, ?dy:Float = 0):Bounds {
    return {
      left:sprite.x + dx,
      top:sprite.y + dy,
      right:sprite.x + sprite.image.width + dx,
      bottom:sprite.y + sprite.image.height + dy,
    };
  }

  function collide(spriteA:Sprite, spriteB:Sprite, ?dx:Float = 0, ?dy:Float = 0):Bool {
    return isIntersecting(bounds(spriteA, dx, dy), bounds(spriteB));
  }

  function isInside(A:Bounds, point:Point):Bool {
    return point.x >= A.left && point.x <= A.right && point.y >= A.top && point.y <= A.bottom;
  }

  inline function isIntersecting(A:Bounds, B:Bounds) {
    return A.right >= B.left && A.left <= B.right && A.bottom >= B.top && A.top <= B.bottom;
  }

  //
  // Ball
  //

  @:allow(states.State)
  function createBall():Ball {
    var image = Assets.images.ball;
    var ball:Ball = {
      image:image,
      x:0,
      y:0,
      anchored:false,
      angle:BALL_START_ANGLE_RAD,
      speed:BALL_BASE_SPEED,
    };
    balls.add(ball);
    return ball;
  }

  @:allow(states.State)
  function releaseBalls():Void {
    for (ball in balls) {
      if (ball.anchored) {
        ball.anchored = false;
        ball.angle = BALL_START_ANGLE_RAD;
        ball.speed = BALL_BASE_SPEED;
      }
    }
  }

  //
  // Bricks
  //

  function createBricks():Array<Brick> {
    return [];
  }

  //
  // Paddle
  //

  @:allow(states.State)
  function createPaddle():Paddle {
    var image = Assets.images.paddle;
    paddle = {
      image:image,
      x:(boundRight + boundLeft - image.width) * 0.5,
      y:boundBottom - image.height - 30,
      speed:PADDLE_SPEED,
    };
    return paddle;
  }
}
