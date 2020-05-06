package rounds;

import kha.Assets;
import kha.Color;
import kha.System;
import kha.graphics2.Graphics;

import components.BounceStrategy;
import components.Bounds;
import world.Entity;
import world.World;
using AnimationExtension;
using Collisions;
using MathExtension;

class Round {
  public var id(default,null):Int;
  public var lives:Int;

  public var backgroundColor(default,null):Color;

  public var moveLeft:Bool = false;
  public var moveRight:Bool = false;

  // The number of pixels from the top of the screen before the top edge starts.
  static inline var TOP_OFFSET = 150.0;
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

  var ballBaseSpeed:Float = BALL_BASE_SPEED;
  var ballSpeedNormalisationRate:Float = BALL_SPEED_NORMALISATION_RATE;

  static inline var KIND_BALL = 'ball';
  static inline var KIND_BRICK = 'brick';
  static inline var KIND_EDGE = 'edge';
  static inline var KIND_PADDLE = 'paddle';
  static inline var KIND_POWERUP = 'powerup';

  var edgeLeft:Entity;
  var edgeRight:Entity;
  var edgeTop:Entity;

  @:allow(states.State)
  var paddle:Entity;

  var world:World = new World();
  var worldBounds:Bounds = {left:0.0, top:TOP_OFFSET, right:System.windowWidth(), bottom:System.windowHeight()};

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

    // Create edges
    edgeLeft = world.add(KIND_EDGE);
    edgeLeft.image = Assets.images.edge_left;
    edgeLeft.position = {x:worldBounds.left, y:worldBounds.top};

    edgeRight = world.add(KIND_EDGE);
    edgeRight.image = Assets.images.edge_right;
    edgeRight.position = {x:worldBounds.right - edgeRight.image.width, y:worldBounds.top};

    edgeTop = world.add(KIND_EDGE);
    edgeTop.image = Assets.images.edge_top;
    edgeTop.position = {x:edgeLeft.image.width, y:worldBounds.top};

    // Create bricks
    for (brick in roundData.bricks) {
      var e = world.add(KIND_BRICK);
      e.animation = brick.animation;
      e.image = brick.image;
      e.position = {x:brick.x + edgeLeft.image.width, y:brick.y + worldBounds.top};
      e.life = brick.life;
      e.value = brick.value;
      e.powerupType = brick.powerupType;
    }

    // Create paddle
    paddle = world.add(KIND_PADDLE);
  }

  public function reset():Void {
    world.removeAll(KIND_BALL);
    world.reset(paddle);
  }

  public function update(game:Game):Void {
    // Detect paddle movement
    if (moveLeft && !moveRight) {
      paddle.velocity = {speed:PADDLE_SPEED, angle:180.toRadians()};
    }
    else if (moveRight && !moveLeft) {
      paddle.velocity = {speed:PADDLE_SPEED, angle:0.0};
    }
    else {
      paddle.velocity = null;
    }

    // Animate entities
    for (e in world.animatables()) {
      e.image = e.animation.tick();
    }

    // Update anchored entities
    for (e in world.anchoredTo()) {
      e.position = null;
      var anchor = e.anchor.e;
      if (anchor.position != null && anchor.image != null && e.image != null) {
        var offset = e.anchor.offset;
        var dx = Math.min(Math.abs(offset.x), anchor.image.width * 0.5);
        e.position = {
          x:anchor.position.x + anchor.image.width * 0.5 + ((offset.x > 0) ? dx : -dx),
          y:anchor.position.y - e.image.height,
        };
      }
    }

    // Move entities
    for (e in world.movables()) {
      e.position.x += e.velocity.speed * Math.cos(e.velocity.angle);
      e.position.y += e.velocity.speed * Math.sin(e.velocity.angle);
    }

    // Detect collision between paddle and edges
    var dx = 0.0;
    if (paddle.image != null && paddle.position != null) {
      if (paddle.collide(edgeLeft)) {
        dx = edgeLeft.position.x + edgeLeft.image.width - paddle.position.x;
      }
      if (paddle.collide(edgeRight)) {
        dx = edgeRight.position.x - (paddle.position.x + paddle.image.width);
      }

      paddle.position.x += dx;
    }

    // Update balls
    for (ball in world.all(KIND_BALL)) {
      if (ball.anchor == null) {
        var collisions = new List<Bounds>();
        var bounceStrategy:Null<BounceStrategy> = null;
        var speed = 0.0;

        // Detect collision between ball and edges
        for (edge in [edgeLeft, edgeRight, edgeTop]) {
          if (ball.collide(edge)) {
            collisions.add(edge.bounds());
            speed += WALL_SPEED_ADJUST;
          }
        }

        // Detect collision between ball and bricks
        for (brick in world.all(KIND_BRICK)) {
          if (ball.collide(brick)) {
            collisions.add(brick.bounds());
            speed += BRICK_SPEED_ADJUST;
            if (brick.life > 0) {
              brick.life--;
              if (brick.life == 0) {
                game.score += brick.value;
                if (brick.powerupType != null) {
                  createPowerup(brick);
                }
                world.remove(brick);
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
          ball.velocity.angle = (collisions.length == 1 && bounceStrategy != null)
            ? bounceStrategy(ball, collisions.first())
            : BounceStrategies.bounceStrategy(ball, collisions);
        }

        // Determine new speed for ball
        if (collisions.isEmpty()) {
          ball.velocity.speed += (ball.velocity.speed > ballBaseSpeed) ? -ballSpeedNormalisationRate : ballSpeedNormalisationRate;
        }
        else {
          ball.velocity.speed = Math.min(ball.velocity.speed + speed, BALL_TOP_SPEED);
        }
      }
    }

    // Remove out of bounds
    for (e in world.drawables()) {
      if (e.position.y >= worldBounds.bottom) {
        world.remove(e);
      }
    }
  }

  public function render(g2:Graphics):Void {
    // Draw background
    g2.color = backgroundColor;
    g2.fillRect(worldBounds.left, worldBounds.top, worldBounds.right - worldBounds.left, worldBounds.bottom - worldBounds.top);

    g2.color = Color.White;

    // Draw entities
    for (e in world.drawables()) {
      g2.drawImage(e.image, e.position.x, e.position.y);
    }

    // Draw lives
    var paddleLife = Assets.images.paddle_life;
    var x = edgeLeft.position.x + edgeLeft.image.width;
    var y = worldBounds.bottom - paddleLife.height - 5;
    for (i in 1...lives) {
      g2.drawImage(paddleLife, x, y);
      x += paddleLife.width + 5;
    }
  }

  //
  // Win/Lose conditions
  //

  public function win():Bool {
    for (brick in world.all(KIND_BRICK)) {
      if (brick.value > 0) return false;
    }
    return true;
  }

  public function lose():Bool {
    return world.all(KIND_BALL).length == 0;
  }

  //
  // Ball
  //

  @:allow(states.State)
  function createBall():Entity {
    var e = world.add(KIND_BALL);
    e.image = Assets.images.ball;
    e.position = {x:0, y:0};
    e.velocity = {angle:BALL_START_ANGLE_RAD, speed:ballBaseSpeed};
    return e;
  }

  @:allow(states.State)
  function releaseBalls():Void {
    for (ball in world.all(KIND_BALL)) {
      if (ball.anchor != null) {
        ball.anchor = null;
        ball.velocity = {speed:ballBaseSpeed, angle:BALL_START_ANGLE_RAD};
      }
    }
  }

  //
  // Bricks
  //

  @:allow(states.State)
  function animateBricks():Void {
    for (brick in world.all(KIND_BRICK)) {
      brick.animation.reset();
    }
  }

  //
  // Paddle
  //

  @:allow(states.State)
  function createPaddle():Entity {
    world.reset(paddle);
    paddle.animation = 'paddle_materialize'.loadAnimation(2, -1);
    paddle.image = paddle.animation.tick();
    paddle.position = {
      x:(worldBounds.right + worldBounds.left - paddle.image.width) * 0.5,
      y:worldBounds.bottom - paddle.image.height - 30
    };
    paddle.bounceStrategy = BounceStrategies.bounceStrategyPaddle;
    return paddle;
  }

  //
  // Powerup
  //

  function createPowerup(brick:Entity):Void {
    var e = world.add(KIND_POWERUP);
    e.animation = 'powerup_${Std.string(brick.powerupType).toLowerCase()}'.loadAnimation(4);
    e.position = brick.position;
    e.powerupType = brick.powerupType;
    e.velocity = {speed:POWERUP_SPEED, angle:90.toRadians()};
  }
}
