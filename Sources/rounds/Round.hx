package rounds;

import kha.Assets;
import kha.Color;
import kha.graphics2.Graphics;

import Collisions.BounceStrategy;
import Collisions.Bounds;
import Collisions.bounds;
import Collisions.collide;
import sprites.Ball;
import sprites.Brick;
import sprites.Edge;
import sprites.Paddle;
import sprites.Sprite;
using AnimationExtension;

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
        var bounceStrategy:Null<BounceStrategy> = null;

        // Detect collision between ball and edges
        for (edge in [edgeLeft, edgeRight, edgeTop]) {
          if (collide(ball, edge)) {
            collisions.add(bounds(edge));
            bounceStrategy = edge.bounceStrategy;
          }
        }

        // Detect collision between ball and bricks
        for (brick in bricks) {
          if (collide(ball, brick)) {
            collisions.add(bounds(brick));
            bounceStrategy = brick.bounceStrategy;
            // TODO: remove fake score
            game.score += 100;
          }
        }

        // Detect collision between ball and paddle
        if (collide(ball, paddle)) {
          collisions.add(bounds(paddle));
          bounceStrategy = paddle.bounceStrategy;
        }

        // Determine new angle for ball
        if (!collisions.isEmpty()) {
          ball.angle = (collisions.length == 1 && bounceStrategy != null)
            ? bounceStrategy(ball, collisions.first())
            : Collisions.bounceStrategy(ball, collisions);
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
      bounceStrategy:Collisions.bounceStrategyPaddle,
      speed:PADDLE_SPEED,
    };
    return paddle;
  }
}
