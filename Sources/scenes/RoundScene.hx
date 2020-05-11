package scenes;

import kha.Assets;
import kha.Color;
import kha.System;
import kha.graphics2.Graphics;

import components.BounceStrategy;
import components.Bounds;
import components.PowerupType;
import rounds.Round;
import states.BallOffScreenState;
import states.RoundState;
import states.RoundStartState;
import world.Entity;
import world.World;
using AnimationExtension;
using Collisions;
using MathExtension;

class RoundScene extends Scene {
  // The number of pixels from the top of the screen before the top edge starts.
  static inline var TOP_OFFSET = 150.0;
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

  public var lives:Int;
  public var round(default,null):Round;
  public var state:RoundState;

  public var freezePaddle:Bool = false;
  public var moveLeft:Bool = false;
  public var moveRight:Bool = false;

  var ballBaseSpeed:Float = BALL_BASE_SPEED;
  var ballBaseSpeedAdjust:Float = 0.0;
  var ballSpeedNormalisationRate:Float = BALL_SPEED_NORMALISATION_RATE;
  var ballTopSpeed:Float = BALL_TOP_SPEED;

  var currentPowerupType:Null<PowerupType> = null;

  var edgeLeft:Entity;
  var edgeRight:Entity;
  var edgeTop:Entity;

  @:allow(states.RoundState)
  var paddle:Entity;

  public var world(default,never):World = new World();
  public var worldBounds(default,never):Bounds = {left:0.0, top:TOP_OFFSET, right:System.windowWidth(), bottom:System.windowHeight()};

  public function new(game:Game, round:Round, lives:Int) {
    super(game);

    this.lives = lives;
    this.round = round;

    if (round.ballBaseSpeedAdjust != null) {
      ballBaseSpeedAdjust = round.ballBaseSpeedAdjust;
    }
    if (round.ballSpeedNormalisationRateAdjust != null) {
      ballSpeedNormalisationRate += round.ballSpeedNormalisationRateAdjust;
    }
    ballBaseSpeed += ballBaseSpeedAdjust;

    //
    // World
    //

    // Create edges
    edgeLeft = world.add(Edge);
    edgeLeft.image = Assets.images.edge_left;
    edgeLeft.x = worldBounds.left;
    edgeLeft.y = worldBounds.top;

    edgeRight = world.add(Edge);
    edgeRight.image = Assets.images.edge_right;
    edgeRight.x = worldBounds.right - edgeRight.image.width;
    edgeRight.y = worldBounds.top;

    edgeTop = world.add(Edge);
    edgeTop.image = Assets.images.edge_top;
    edgeTop.x = edgeLeft.image.width;
    edgeTop.y = worldBounds.top;

    // Create bricks
    for (brick in round.bricks) {
      var e = world.add(Brick);
      e.animation = brick.animation;
      e.image = brick.image;
      e.x = brick.x + edgeLeft.image.width;
      e.y = brick.y + worldBounds.top;
      e.health = brick.health;
      e.value = brick.value;
      e.powerupType = brick.powerupType;
    }

    // Create paddle
    paddle = world.add(Paddle);

    //
    // Input bindings
    //

    #if debug
    game.input.bind(Key(Subtract), (_)->{
      if (round.id > 1) {
        game.switchToRound(round.id - 1, this.lives);
      }
    });
    game.input.bind(Key(Add), (_)->{
      if (round.id < game.rounds.length) {
        game.switchToRound(round.id + 1, this.lives);
      }
    });
    game.input.bind(Key(R), (_)->{
      game.switchToRound(round.id, this.lives);
    });
    #end
    game.input.bind(Key(Backspace), (_)->{ game.backToTitle(); });
    game.input.bind(Key(Left),
      (_)->{ moveLeft = true; },
      (_)->{ moveLeft = false; }
    );
    game.input.bind(Key(Right),
      (_)->{ moveRight = true; },
      (_)->{ moveRight = false; }
    );
    game.input.bind(Key(K), (_)->{
      state = new BallOffScreenState(this);
    });

    // Initialize state
    state = new RoundStartState(this);
  }

  override function update():Void {
    // Detect paddle movement
    if (!freezePaddle && moveLeft && !moveRight) {
      paddle.speed = PADDLE_SPEED;
      paddle.angle = 180.toRadians();
    }
    else if (!freezePaddle && moveRight && !moveLeft) {
      paddle.speed = PADDLE_SPEED;
      paddle.angle = 0.0;
    }
    else {
      paddle.speed = null;
      paddle.angle = null;
    }

    // Animate entities
    for (e in world.animatables()) {
      e.image = e.animation.tick();
    }

    // Move entities
    for (e in world.movables()) {
      e.x += e.speed * Math.cos(e.angle);
      e.y += e.speed * Math.sin(e.angle);
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
              brick.remove();
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
      if (collisions.length > 0) {
        ball.angle = (collisions.length == 1 && bounceStrategy != null)
          ? bounceStrategy(ball, collisions[0])
          : BounceStrategies.bounceStrategy(ball, collisions);
      }

      // Determine new speed for ball
      if (collisions.length == 0) {
        ball.speed += (ball.speed > ballBaseSpeed) ? -ballSpeedNormalisationRate : ballSpeedNormalisationRate;
      }
      else {
        ball.speed = Math.min(ball.speed + speed, ballTopSpeed);
      }

      if (collideWithPaddle && currentPowerupType == Catch) {
        ball.anchorTo(paddle);
      }
    }

    // Remove out of bounds
    for (e in world.drawables()) {
      if (e.y >= worldBounds.bottom) {
        e.remove();
      }
    }

    // Update state
    state.update();
  }

  override function render(g2:Graphics):Void {
    // Draw background
    g2.color = round.backgroundColor;
    g2.fillRect(worldBounds.left, worldBounds.top, worldBounds.right - worldBounds.left, worldBounds.bottom - worldBounds.top);

    // Draw entities
    g2.color = Color.White;
    for (e in world.drawables()) {
      g2.drawImage(e.image, e.x, e.y);
      if (game.debugMode && e.kind == Brick && e.powerupType != null) {
        var name = e.powerupType.getName().toLowerCase();
        var image = Assets.images.get('powerup_${name}_1');
        g2.drawImage(image, e.x, e.y);
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
    var x = edgeLeft.x + edgeLeft.image.width;
    var y = worldBounds.bottom - paddleLife.height - 5;
    for (i in 1...lives) {
      g2.drawImage(paddleLife, x, y);
      x += paddleLife.width + 5;
    }

    // Render state
    state.render(g2);
  }

  public function reset():Void {
    world.removeAll(Ball);
    paddle.reset();

    // Reset effects
    currentPowerupType = null;
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

  @:allow(states.RoundState)
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

  function activatePowerup(game:Game, powerupType:PowerupType):Void {
    switch powerupType {
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
      case Laser:
      case Life:
        lives++;
      case Slow:
        ballBaseSpeed = BALL_SLOW_SPEED;
        ballTopSpeed = BALL_SLOW_SPEED;
        for (ball in world.all(Ball)) {
          ball.speed = BALL_SLOW_SPEED;
        }
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
        ballBaseSpeed = BALL_BASE_SPEED + ballBaseSpeedAdjust;
        ballTopSpeed = BALL_TOP_SPEED;
    }
  }
}
