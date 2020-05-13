package states;

import kha.Assets;
import kha.Color;
import kha.graphics2.Graphics;

using AnimationExtension;
using Collisions;
using MathExtension;
import components.Animation;
import components.BounceStrategy;
import components.Bounds;
import components.PowerupType;
import scenes.RoundScene;
import world.Entity;
using world.EntityExtension;

class RoundPlayState extends RoundState {
  // The angle the ball initially moves off the paddle.
  static inline var BALL_START_ANGLE_RAD = 5.0; // radians
  // The speed that the ball will always try to arrive at.
  // This is based on a game running at 60fps. You might need to increment it by
  // a couple of notches if you find the ball moves too slowly.
  static inline var BALL_BASE_SPEED = 8.0; // pixels per frame
  // The ball will assume this base speed when the "Slow" powerup is activated.
  static inline var BALL_SLOW_SPEED = 6.0; // pixels per frame
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

  var moveLeft:Bool = false;
  var moveRight:Bool = false;

  var ballBaseSpeed:Float = BALL_BASE_SPEED;
  var ballBaseSpeedAdjust:Float = 0.0;
  var ballSpeedNormalisationRate:Float = BALL_SPEED_NORMALISATION_RATE;
  var ballTopSpeed:Float = BALL_TOP_SPEED;

  var currentPowerupType(default,set):Null<PowerupType>;
  inline function set_currentPowerupType(value:PowerupType) {
    transitionPowerup(game, currentPowerupType, value);
    return currentPowerupType = value;
  }

  public function new(scene:RoundScene) {
    super(scene);

    if (round.ballBaseSpeedAdjust != null) {
      ballBaseSpeedAdjust = round.ballBaseSpeedAdjust;
    }
    if (round.ballSpeedNormalisationRateAdjust != null) {
      ballSpeedNormalisationRate += round.ballSpeedNormalisationRateAdjust;
    }
    ballBaseSpeed += ballBaseSpeedAdjust;

    currentPowerupType = null;

    // Input bindings
    game.input.bind(Key(Left));
    game.input.bind(Key(Left),
      (_)->{ moveLeft = true; },
      (_)->{ moveLeft = false; }
    );
    game.input.bind(Key(Right));
    game.input.bind(Key(Right),
      (_)->{ moveRight = true; },
      (_)->{ moveRight = false; }
    );
    game.input.bind(Key(K));
    if (round.id != null) {
      game.input.bind(Key(K), (_)->{
        world.removeAll(Ball);
        paddle.speed = null;
        scene.state = new BallOffScreenState(scene);
      });
    }

    // Here we go!
    releaseBalls();
  }

  override function update():Void {
    // Detect paddle movement
    if (moveLeft && !moveRight) {
      paddle.speed = PADDLE_SPEED;
      paddle.angle = 180.toRadians();
    }
    else if (moveRight && !moveLeft) {
      paddle.speed = PADDLE_SPEED;
      paddle.angle = 0.0;
    }
    else {
      paddle.speed = null;
      paddle.angle = null;
    }

    // Detect paddle collisions
    for (paddle in world.collidables(Paddle)) {
      // Detect collision between paddle and edges
      var dx = 0.0;
      if (paddle.collide(edgeLeft)) {
        dx = edgeLeft.x + edgeLeft.image.width - paddle.x;
      }
      if (paddle.collide(edgeRight)) {
        dx = edgeRight.x - (paddle.x + paddle.image.width);
      }

      paddle.x += dx;

      // Detect collision between paddle and powerups
      for (powerup in world.collidables(Powerup)) {
        if (paddle.collide(powerup)) {
          game.score += powerup.value;
          currentPowerupType = powerup.powerupType;
          world.remove(powerup);
        }
      }
    }

    // Detect balls collisions
    for (ball in world.collidables(Ball)) {
      var collisions:Array<Bounds> = [];
      var bounceStrategy:Null<BounceStrategy> = null;
      var speed = 0.0;

      // Detect collision between ball and edges
        for (edge in [edgeLeft, edgeRight, edgeTop]) {
        if (ball.collide(edge)) {
          collisions.push(edge.bounds());
          speed += WALL_SPEED_ADJUST;
        }
      }

      // Detect collision between ball and bricks
      for (brick in world.collidables(Brick)) {
        if (ball.collide(brick)) {
          collisions.push(brick.bounds());
          speed += BRICK_SPEED_ADJUST;
          if (brick.health > 0) {
            brick.health--;
            if (brick.health == 0) {
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
      var collideWithPaddle = ball.collide(paddle);
      if (collideWithPaddle) {
        collisions.push(paddle.bounds());
        bounceStrategy = paddle.bounceStrategy;
      }

      // Determine new angle for ball
      if (!collisions.isEmpty()) {
        ball.angle = (collisions.length == 1 && bounceStrategy != null)
          ? bounceStrategy(ball, collisions[0])
          : BounceStrategies.bounceStrategy(ball, collisions);
      }

      // Determine new speed for ball
      if (collisions.isEmpty()) {
        ball.speed += (ball.speed > ballBaseSpeed) ? -ballSpeedNormalisationRate : ballSpeedNormalisationRate;
      }
      else {
        ball.speed = Math.min(ball.speed + speed, ballTopSpeed);
      }

      if (collideWithPaddle && currentPowerupType == Catch) {
        ball.anchorTo(paddle);
      }
    }

    if (round.id != null) {
      if (win()) {
        // You win!
        world.removeAll(Ball);
        paddle.speed = null;
        scene.state = new RoundEndState(scene);
      }
      else if (lose()) {
        // You lose!
        paddle.speed = null;
        scene.state = new BallOffScreenState(scene);
      }
    }
  }

  override function render(g2:Graphics):Void {
    if (game.debugMode) {
      g2.color = Color.Yellow;
      g2.font = Assets.fonts.optimus;
      g2.fontSize = 30;
      var n = world.drawables(Ball).length;
      g2.drawString('Balls:$n', 10, 10);
      g2.drawString('Ball Base Speed:$ballBaseSpeed', 10, 40);
      g2.drawString('Ball Top Speed:$ballTopSpeed', 10, 70);
    }
  }

  //
  // Win/Lose conditions
  //

  function win():Bool {
    for (brick in world.all(Brick)) {
      if (brick.value > 0) return false;
    }
    return true;
  }

  function lose():Bool {
    return world.all(Ball).isEmpty();
  }

  //
  // Ball
  //

  function cloneBall(e:Entity):Entity {
    var clone = world.add(Ball);
    clone.image = e.image;
    clone.x = e.x;
    clone.y = e.y;
    clone.speed = e.speed;
    clone.angle = e.angle;
    return clone;
  }

  function releaseBalls():Void {
    for (ball in world.all(Ball)) {
      if (ball.anchor != null) {
        var position = ball.anchorPosition();
        ball.x = position.x;
        ball.y = position.y;
        ball.speed = ballBaseSpeed;
        if (ball.angle == null) ball.angle = BALL_START_ANGLE_RAD;
        ball.anchor = null;
      }
    }
  }

  //
  // Powerup
  //

  function createPowerup(brick:Entity):Void {
    var e = world.add(Powerup);
    var name = brick.powerupType.getName().toLowerCase();
    e.animation = 'powerup_$name'.loadAnimation(4);
    e.x = brick.x;
    e.y = brick.y;
    e.powerupType = brick.powerupType;
    e.speed = POWERUP_SPEED;
    e.angle = 90.toRadians();
    e.value = POWERUP_VALUE;
  }

  function transitionPowerup(game:Game, from:Null<PowerupType>, to:Null<PowerupType>):Void {
    // Deactivate the previous powerup
    if (from != null) {
      switch from {
        case Catch:
          game.input.bind(Key(Space));
          releaseBalls();
        case Duplicate:
          // Nothing
        case Expand:
          if (to != Expand) {
            if (paddle.animation.cycle >= 0) {
              paddle.animation = 'paddle_wide'.loadAnimation(4, -1);
            }
            paddle.animation.reverse();
            paddle.pendingAnimation = 'paddle_pulsate'.pulsateAnimation(4, 80);
            ballBaseSpeed = BALL_BASE_SPEED + ballBaseSpeedAdjust;
          }
        case Laser:
        case Life:
          // Nothing
        case Slow:
          ballBaseSpeed = BALL_BASE_SPEED + ballBaseSpeedAdjust;
          ballTopSpeed = BALL_TOP_SPEED;
      }
    }

    // Activate the new powerup
    if (to != null) {
      switch to {
        case Catch:
          game.input.bind(Key(Space), (_)->{ releaseBalls(); });
        case Duplicate:
          var splitAngle = 0.4; // radians
          for (ball in world.all(Ball)) {
            var angle = ball.angle + splitAngle;
            if (angle > 2 * Math.PI) {
              angle -= 2 * Math.PI;
            }

            var clone1 = cloneBall(ball);
            clone1.angle = angle;

            var clone2 = cloneBall(ball);
            clone2.angle = Math.abs(ball.angle - splitAngle);
          }
        case Expand:
          if (from != Expand) {
            paddle.animation = 'paddle_wide'.loadAnimation(4, -1);
            paddle.pendingAnimation = 'paddle_wide_pulsate'.pulsateAnimation(4, 80);
            ballBaseSpeed = BALL_BASE_SPEED + ballBaseSpeedAdjust + 1;
          }
        case Laser:
        case Life:
          scene.lives++;
        case Slow:
          ballBaseSpeed = BALL_SLOW_SPEED;
          ballTopSpeed = BALL_SLOW_SPEED;
          for (ball in world.all(Ball)) {
            ball.speed = BALL_SLOW_SPEED;
          }
      }
    }
  }
}
