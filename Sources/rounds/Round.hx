package rounds;

import kha.Assets;
import kha.Color;
import kha.System;
import kha.graphics2.Graphics;

import components.BounceStrategy;
import components.Bounds;
import components.PowerupType;
import world.Entity;
import world.World;
using AnimationExtension;
using Collisions;
using MathExtension;

class Round {
  public var id(default,null):Int;
  public var lives:Int;

  public var backgroundColor(default,null):Color;

  public var freezePaddle:Bool = false;
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
  // The value of the powerup.
  static inline var POWERUP_VALUE = 1000;

  var currentPowerupType:Null<PowerupType> = null;

  var ballBaseSpeed:Float = BALL_BASE_SPEED;
  var ballSpeedNormalisationRate:Float = BALL_SPEED_NORMALISATION_RATE;

  var edgeLeft:Entity;
  var edgeRight:Entity;
  var edgeTop:Entity;

  @:allow(states.RoundState)
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
    edgeLeft = world.add(Edge);
    edgeLeft.image = Assets.images.edge_left;
    edgeLeft.position = {x:worldBounds.left, y:worldBounds.top};

    edgeRight = world.add(Edge);
    edgeRight.image = Assets.images.edge_right;
    edgeRight.position = {x:worldBounds.right - edgeRight.image.width, y:worldBounds.top};

    edgeTop = world.add(Edge);
    edgeTop.image = Assets.images.edge_top;
    edgeTop.position = {x:edgeLeft.image.width, y:worldBounds.top};

    // Create bricks
    for (brick in roundData.bricks) {
      var e = world.add(Brick);
      e.animation = brick.animation;
      e.image = brick.image;
      e.position = {x:brick.x + edgeLeft.image.width, y:brick.y + worldBounds.top};
      e.life = brick.life;
      e.value = brick.value;
      e.powerupType = brick.powerupType;
    }

    // Create paddle
    paddle = world.add(Paddle);
  }

  public function reset():Void {
    world.removeAll(Ball);
    paddle.reset();

    // Reset effects
    currentPowerupType = null;
  }

  public function update(game:Game):Void {
    // Detect paddle movement
    if (!freezePaddle && moveLeft && !moveRight) {
      paddle.velocity = {speed:PADDLE_SPEED, angle:180.toRadians()};
    }
    else if (!freezePaddle && moveRight && !moveLeft) {
      paddle.velocity = {speed:PADDLE_SPEED, angle:0.0};
    }
    else {
      paddle.velocity = null;
    }

    // Animate entities
    for (e in world.animatables()) {
      e.image = e.animation.tick();
    }

    // Move entities
    for (e in world.movables()) {
      e.position.x += e.velocity.speed * Math.cos(e.velocity.angle);
      e.position.y += e.velocity.speed * Math.sin(e.velocity.angle);
    }

    // Detect paddle collisions
    for (paddle in world.collidables(Paddle)) {
      // Detect collision between paddle and edges
      var dx = 0.0;
      if (paddle.collide(edgeLeft)) {
        dx = edgeLeft.position.x + edgeLeft.image.width - paddle.position.x;
      }
      if (paddle.collide(edgeRight)) {
        dx = edgeRight.position.x - (paddle.position.x + paddle.image.width);
      }

      paddle.position.x += dx;

      // Detect collision between paddle and powerups
      for (powerup in world.collidables(Powerup)) {
        if (paddle.collide(powerup)) {
          game.score += powerup.value;
          if (currentPowerupType != null) {
            deactivatePowerup(game, currentPowerupType);
          }
          currentPowerupType = powerup.powerupType;
          activatePowerup(game, currentPowerupType);
          powerup.remove();
        }
      }
    }

    // Detect balls collisions
    for (ball in world.collidables(Ball)) {
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
      for (brick in world.collidables(Brick)) {
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
              brick.remove();
            }
          }
        }
      }

      // Detect collision between ball and paddle
      var collideWithPaddle = ball.collide(paddle);
      if (collideWithPaddle) {
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

      if (collideWithPaddle && currentPowerupType == Catch) {
        ball.anchorTo(paddle);
      }
    }

    // Remove out of bounds
    for (e in world.drawables()) {
      if (e.position.y >= worldBounds.bottom) {
        e.remove();
      }
    }
  }

  public function render(game:Game, g2:Graphics):Void {
    // Draw background
    g2.color = backgroundColor;
    g2.fillRect(worldBounds.left, worldBounds.top, worldBounds.right - worldBounds.left, worldBounds.bottom - worldBounds.top);

    g2.color = Color.White;

    // Draw entities
    for (e in world.drawables()) {
      g2.drawImage(e.image, e.position.x, e.position.y);
      if (game.debugMode && e.kind == Brick && e.powerupType != null) {
        var name = e.powerupType.getName().toLowerCase();
        var image = Assets.images.get('powerup_${name}_1');
        g2.drawImage(image, e.position.x, e.position.y);
      }
      for (anchored in world.anchoredTo(e)) {
        var position = anchored.anchorPosition();
        if (position != null) {
          g2.drawImage(anchored.image, position.x, position.y);
        }
      }
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
    for (brick in world.all(Brick)) {
      if (brick.value > 0) return false;
    }
    return true;
  }

  public function lose():Bool {
    return world.all(Ball).length == 0;
  }

  //
  // Ball
  //

  @:allow(states.RoundState)
  function createBall():Entity {
    var e = world.add(Ball);
    e.image = Assets.images.ball;
    return e;
  }

  function cloneBall(e:Entity):Entity {
    var clone = world.add(Ball);
    clone.image = e.image;
    clone.position = {x:e.position.x, y:e.position.y};
    clone.velocity = {speed:e.velocity.speed, angle:e.velocity.angle};
    return clone;
  }

  @:allow(states.RoundState)
  function releaseBalls():Void {
    for (ball in world.all(Ball)) {
      if (ball.anchor != null) {
        ball.position = ball.anchorPosition();
        var angle = (ball.velocity == null) ? BALL_START_ANGLE_RAD : ball.velocity.angle;
        ball.velocity = {speed:ballBaseSpeed, angle:angle};
        ball.anchor = null;
      }
    }
  }

  //
  // Bricks
  //

  @:allow(states.RoundState)
  function animateBricks():Void {
    for (brick in world.all(Brick)) {
      brick.animation.reset();
    }
  }

  //
  // Paddle
  //

  @:allow(states.RoundState)
  function createPaddle():Entity {
    paddle.reset();
    paddle.animation = 'paddle_materialize'.loadAnimation(2, -1);
    paddle.image = paddle.animation.tick();
    paddle.position = {
      x:(worldBounds.right + worldBounds.left - paddle.image.width) * 0.5,
      y:worldBounds.bottom - paddle.image.height - 30
    };
    paddle.bounceStrategy = BounceStrategies.bounceStrategyPaddle;

    // Move your body!
    freezePaddle = false;
    moveLeft = false;
    moveRight = false;

    return paddle;
  }

  @:allow(states.RoundState)
  function destroyPaddle():Void {
    // Don't move...
    freezePaddle = true;
    // ...my deadly love!
    paddle.animation = 'paddle_explode'.loadAnimation(4, -1);
  }

  //
  // Powerup
  //

  function createPowerup(brick:Entity):Void {
    var e = world.add(Powerup);
    var name = brick.powerupType.getName().toLowerCase();
    e.animation = 'powerup_$name'.loadAnimation(4);
    e.position = brick.position;
    e.powerupType = brick.powerupType;
    e.velocity = {speed:POWERUP_SPEED, angle:90.toRadians()};
    e.value = POWERUP_VALUE;
  }

  function activatePowerup(game:Game, powerupType:PowerupType):Void {
    switch powerupType {
      case Catch:
        game.input.bind(Key(Space), (_)->{ releaseBalls(); });
      case Duplicate:
        var splitAngle = 0.4; // radians
        for (ball in world.all(Ball)) {
          var angle = ball.velocity.angle + splitAngle;
          if (angle > 2 * Math.PI) {
            angle -= 2 * Math.PI;
          }

          var clone1 = cloneBall(ball);
          clone1.velocity.angle = angle;

          var clone2 = cloneBall(ball);
          clone2.velocity.angle = Math.abs(ball.velocity.angle - splitAngle);
        }
      case Expand:
      case Laser:
      case Life:
        lives++;
      case Slow:
    }
  }

  function deactivatePowerup(game:Game, powerupType:PowerupType):Void {
    switch powerupType {
      case Catch:
        game.input.bind(Key(Space));
        releaseBalls();
      case Duplicate:
        // Nothing
      case Expand:
      case Laser:
      case Life:
        // Nothing
      case Slow:
    }
  }
}
