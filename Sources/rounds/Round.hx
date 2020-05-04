package rounds;

import kha.Assets;
import kha.Color;
import kha.graphics2.Graphics;

import BounceStrategies.BounceStrategy;
import sprites.Ball;
import sprites.Brick;
import sprites.Edge;
import sprites.Paddle;
import sprites.Sprite;
import world.World;
using AnimationExtension;
using Collisions;
using MathExtension;

class Round {
  public var id(default,null):Int;
  public var lives:Int;

  public var backgroundColor(default,null):Color;
  public var bricks(default,null):List<Brick>;

  public var moveLeft:Bool = false;
  public var moveRight:Bool = false;

  public var paddle:Null<Paddle> = null;

  var balls:List<Ball> = new List();

  // The number of pixels from the top of the screen before the top edge starts.
  static inline var TOP_OFFSET = 150;
  // The angle the ball initially moves off the paddle.
  static inline var BALL_START_ANGLE_RAD = 5.0; // radians
  // The speed that the ball will always try to arrive at.
  // This is based on a game running at 60fps. You might need to increment it by
  // a couple of notches if you find the ball moves too slowly.
  static inline var BALL_BASE_SPEED = 8.0; // pixels per frame
  // The max speed of the ball, prevents a runaway speed when lots of rapid
  // collisions.
  static inline var BALL_TOP_SPEED = 15.0; // pixels per frame
  // Per-frame rate at which ball is brought back to base speed.
  static inline var BALL_SPEED_NORMALISATION_RATE = 0.02;
  // Increase in speed caused by colliding with a brick.
  static inline var BRICK_SPEED_ADJUST = 0.5;
  // Increase in speed caused by colliding with a wall.
  static inline var WALL_SPEED_ADJUST = 0.2;
  // The speed the paddle moves.
  static inline var PADDLE_SPEED = 10.0;
  // The speed the powerup moves.
  static inline var POWERUP_SPEED = 3.0;

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

  var ballBaseSpeed:Float = BALL_BASE_SPEED;
  var ballSpeedNormalisationRate:Float = BALL_SPEED_NORMALISATION_RATE;

  static inline var KIND_POWERUP = 'powerup';

  var world:World = new World();

  public function new(id:Int, lives:Int, roundData:RoundData) {
    this.id = id;
    this.lives = lives;
    backgroundColor = roundData.backgroundColor;
    if (roundData.ballBaseSpeedAdjust != null) {
      ballBaseSpeed += roundData.ballBaseSpeedAdjust;
    }
    if (roundData.ballSpeedNormalisationRateAdjust != null) {
      ballSpeedNormalisationRate += roundData.ballSpeedNormalisationRateAdjust;
    }
    bricks = roundData.bricks;

    // Create edges
    var imageLeft = Assets.images.edge_left;
    var imageRight = Assets.images.edge_right;
    var imageTop = Assets.images.edge_top;
    edgeLeft = {image:imageLeft, x:0, y:TOP_OFFSET};
    edgeRight = {image:imageRight, x:Game.WIDTH - imageRight.width, y:TOP_OFFSET};
    edgeTop = {image:imageTop, x:imageLeft.width, y:TOP_OFFSET};

    // Add offset to bricks coordinates
    for (brick in bricks) {
      brick.x += boundLeft;
      brick.y += boundTop;
    }
  }

  public function reset():Void {
    balls.clear();
    paddle = null;
  }

  public function update(game:Game):Void {
    // Update animatables
    for (e in world.animatables()) {
      e.image = e.animation.tick();
    }

    // Update movables
    for (e in world.movables()) {
      e.position.x += e.velocity.speed * Math.cos(e.velocity.angle);
      e.position.y += e.velocity.speed * Math.sin(e.velocity.angle);
    }

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
      if (paddle.collide(edgeLeft, dx)) {
        dx = boundLeft - paddle.x;
      }
      if (paddle.collide(edgeRight, dx)) {
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
        var speed = 0.0;

        // Detect collision between ball and edges
        for (edge in [edgeLeft, edgeRight, edgeTop]) {
          if (ball.collide(edge)) {
            collisions.add(edge.bounds());
            bounceStrategy = edge.bounceStrategy;
            speed += WALL_SPEED_ADJUST;
          }
        }

        // Detect collision between ball and bricks
        for (brick in bricks) {
          if (ball.collide(brick)) {
            collisions.add(brick.bounds());
            bounceStrategy = brick.bounceStrategy;
            speed += BRICK_SPEED_ADJUST;
            if (brick.life > 0) {
              brick.life--;
              if (brick.life == 0) {
                bricks.remove(brick);
                game.score += brick.value;
                if (brick.powerupType != null) {
                  createPowerup(brick);
                }
              }
            }
          }
        }

        // Detect collision between ball and paddle
        if (paddle != null && ball.collide(paddle)) {
          collisions.add(paddle.bounds());
          bounceStrategy = paddle.bounceStrategy;
        }

        // Determine new angle for ball
        if (!collisions.isEmpty()) {
          ball.angle = (collisions.length == 1 && bounceStrategy != null)
            ? bounceStrategy(ball, collisions.first())
            : BounceStrategies.bounceStrategy(ball, collisions);
        }

        // Determine new speed for ball
        if (collisions.isEmpty()) {
          ball.speed += (ball.speed > ballBaseSpeed) ? -ballSpeedNormalisationRate : ballSpeedNormalisationRate;
        }
        else {
          ball.speed = Math.min(ball.speed + speed, BALL_TOP_SPEED);
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

    // Remove out of bounds
    for (e in world.drawables()) {
      if (e.position.y >= boundBottom) {
        world.remove(e);
      }
    }
  }

  public function render(g2:Graphics):Void {
    // Draw background
    g2.color = backgroundColor;
    g2.fillRect(0, TOP_OFFSET, Game.WIDTH, Game.HEIGHT - TOP_OFFSET);

    g2.color = Color.White;

    // Draw drawables
    for (e in world.drawables()) {
      g2.drawImage(e.image, e.position.x, e.position.y);
    }

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
  // Win/Lose conditions
  //

  public function win():Bool {
    for (brick in bricks) {
      if (brick.value > 0) return false;
    }
    return true;
  }

  public function lose():Bool {
    return balls.isEmpty();
  }

  //
  // Animation
  //

  function animateSprite(sprite:Sprite):Void {
    if (sprite.animation == null) return;

    sprite.image = sprite.animation.tick();
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
      speed:ballBaseSpeed,
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
        ball.speed = ballBaseSpeed;
      }
    }
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
      bounceStrategy:BounceStrategies.bounceStrategyPaddle,
      speed:PADDLE_SPEED,
      angle:0.0,
    };
    return paddle;
  }

  //
  // Powerup
  //

  function createPowerup(brick:Brick):Void {
    var e = world.add(KIND_POWERUP);
    e.animation = 'powerup_${Std.string(brick.powerupType).toLowerCase()}'.loadAnimation(4);
    e.position = {x:brick.x, y:brick.y};
    e.powerupType = brick.powerupType;
    e.velocity = {speed:POWERUP_SPEED, angle:90.toRadians()};
  }
}
