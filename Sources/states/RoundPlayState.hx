package states;

import kha.Assets;
import kha.Color;
import kha.graphics2.Graphics;

using AnimationExtension;
using Collisions;
using MathExtension;
import Random;
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
  // The speed the laser bullet moves.
  static inline var BULLET_SPEED = 15.0; // pixels per frame
  // Minimum delay before opening a top door.
  static inline var DOOR_OPEN_DELAY_MIN = 60; // frames
  // Maximum delay before opening a top door.
  static inline var DOOR_OPEN_DELAY_MAX = 600; // frames
  // The time the door remains open.
  static inline var DOOR_OPEN_TIME = 20; // frames
  // A value between this and its negative will be chosen at random and then
  // added to the direction of the enemy. This ensures some erraticness in the
  // enemy movement.
  static inline var ENEMY_RANDOM_RANGE = 1.5; // radians
  // The speed the laser bullet moves.
  static inline var ENEMY_SPEED = 2.0; // pixels per frame
  // The initial direction of the enemy.
  static inline var ENEMY_START_ANGLE_RAD = 1.57; // radians
  // The enemy travels in the start direction for this duration.
  static inline var ENEMY_START_DURATION = 75; // frames
  // The value of the enemy.
  static inline var ENEMY_VALUE = 100;
  // Increase in speed caused by colliding with a wall.
  static inline var WALL_SPEED_ADJUST = 0.2;
  // The speed the paddle moves.
  static inline var PADDLE_SPEED = 10.0; // pixels per frame
  // The speed the powerup moves.
  static inline var POWERUP_SPEED = 3.0; // pixels per frame
  // The value of the powerup.
  static inline var POWERUP_VALUE = 1000;
  // A value between these two bounds will be randomly selected for the
  // duration of travel (i.e. number of frames) in a given direction.
  static inline var TRAVEL_MIN_DURATION = 30; // frames
  static inline var TRAVEL_MAX_DURATION = 60; // frames

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

  var door:Entity;
  var doorDelay:Null<Int> = null;
  var doorSide:String;

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
    door = world.add();

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
    if (round.id > 0) {
      game.input.bind(Key(K), (_)->{
        world.remove(door);
        world.removeAll(Ball);
        paddle.speed = null;
        currentPowerupType = null;
        scene.state = new BallOffScreenState(scene);
      });
    }

    // Here we go!
    releaseBalls();
  }

  override function update():Void {
    // Check top door
    if (door.animation == null) {
      if (doorDelay == null) {
        // Delay before opening the top door
        if (world.all(Enemy).length < round.enemiesNumber) {
          doorDelay = Random.int(DOOR_OPEN_DELAY_MAX, DOOR_OPEN_DELAY_MIN);
        }
      }
      else if (doorDelay > 0) {
        doorDelay--;
      }
      else {
        doorDelay = null;

        // Open the top door
        doorSide = (Std.random(2) == 0) ? 'left' : 'right';
        door.animation = 'door_top_$doorSide'.loadAnimation(4, -1);
        door.x = edgeTop.x;
        door.y = edgeTop.y;
      }
    }
    else if (door.animation.over()) {
      if (doorDelay == null) {
        // Delay before closing the top door
        doorDelay = DOOR_OPEN_TIME;

        // Release an enemy
        var animationId = switch round.enemiesType {
          case Konerd:'cone';
          case Pyradok:'pyramid';
          case TriSphere:'molecule';
          case Opopo:'cube';
        };
        var enemy = world.add(Enemy);
        enemy.animation = 'enemy_$animationId'.loadAnimation(4);
        enemy.x = ((doorSide == 'left') ? 135 : 435);
        enemy.y = 150;
        enemy.speed = ENEMY_SPEED;
        enemy.angle = ENEMY_START_ANGLE_RAD;
        enemy.value = ENEMY_VALUE;
        enemy.travel = { duration:ENEMY_START_DURATION, lastContact:0 };
      }
      else if (doorDelay > 0) {
        doorDelay--;
        if (doorDelay == 0) {
          // Close the top door
          door.animation.reverse();
        }
      }
      else {
        door.reset();
        doorDelay = null;
      }
    }

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

      // Detect collision between paddle and enemies
      for (enemy in world.collidables(Enemy)) {
        if (paddle.collide(enemy)) {
          game.score += enemy.value;
          destroyEnemy(enemy);
        }
      }

      // Detect collision between paddle and powerups
      for (powerup in world.collidables(Powerup)) {
        if (paddle.collide(powerup)) {
          game.score += powerup.value;
          currentPowerupType = powerup.powerupType;
          world.remove(powerup);
        }
      }
    }

    // Detect bullets collisions
    for (bullet in world.collidables(Bullet)) {
      // Detect collision between bullet and edges
      if (bullet.collide(edgeTop)) {
        world.remove(bullet);
      }

      // Detect collision between bullet and bricks
      for (brick in world.collidables(Brick)) {
        if (bullet.collide(brick)) {
          if (brick.health > 0) {
            brick.health--;
            if (brick.health == 0) {
              // The game's score is not increased and the powerup
              // is not released when laser destroys a brick
              world.remove(brick);
            }
          }
          world.remove(bullet);
        }
      }

      // Detect collision between bullet and enemies
      for (enemy in world.collidables(Enemy)) {
        if (bullet.collide(enemy)) {
          // The game's score is not increased when laser destroys an enemy
          destroyEnemy(enemy);
          world.remove(bullet);
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

      // Detect collision between ball and enemies
      for (enemy in world.collidables(Enemy)) {
        if (ball.collide(enemy)) {
          collisions.push(enemy.bounds());
          game.score += enemy.value;
          destroyEnemy(enemy);
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

    // Detect enemies collisions
    for (enemy in world.collidables(Enemy)) {
      // TODO: handle collisions with bricks and edges
      if (enemy.travel.lastContact >= enemy.travel.duration) {
        if (paddle.x != null && paddle.y != null && paddle.image != null) {
          var x = paddle.x + paddle.image.width * 0.5;
          var y = paddle.y + paddle.image.height * 0.5;
          enemy.angle = Math.atan2(y - enemy.y, x - enemy.x) + Random.float(-ENEMY_RANDOM_RANGE, ENEMY_RANDOM_RANGE);
          enemy.travel.duration = Random.int(TRAVEL_MAX_DURATION, TRAVEL_MIN_DURATION);
          enemy.travel.lastContact = 0;
        }
      }
      enemy.travel.lastContact++;
    }

    // Remove old explosions
    for (e in world.all(Explosion)) {
      if (e.animation.over()) world.remove(e);
    }

    if (round.id > 0) {
      if (win()) {
        // You win!
        world.removeAll(Ball);
        paddle.speed = null;
        scene.state = new RoundEndState(scene);
      }
      else if (lose()) {
        // You lose!
        world.remove(door);
        paddle.speed = null;
        currentPowerupType = null;
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
  // Bullet
  //

  function fire():Void {
    // Paddle ready?
    if (paddle.animation.cycle == 0 || (paddle.pendingAnimations != null && !paddle.pendingAnimations.isEmpty())) return;
    // Only allowing max 4 bulets in the air at once
    if (world.all(Bullet).length > 2) return;

    var image = Assets.images.laser_bullet;

    var bullet1 = world.add(Bullet);
    bullet1.image = image;
    bullet1.x = paddle.x + 10;
    bullet1.y = paddle.y;
    bullet1.speed = BULLET_SPEED;
    bullet1.angle = 270.toRadians();

    var bullet2 = world.add(Bullet);
    bullet2.image = image;
    bullet2.x = paddle.x + paddle.image.width - 10;
    bullet2.y = paddle.y;
    bullet2.speed = BULLET_SPEED;
    bullet2.angle = 270.toRadians();
  }

  //
  // Enemy
  //

  function destroyEnemy(enemy:Entity) {
    var explosion = world.add(Explosion);
    explosion.animation = 'enemy_explosion'.loadAnimation(2, -1);
    explosion.x = enemy.x;
    explosion.y = enemy.y;
    world.remove(enemy);
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
              paddle.animation = 'paddle_wide'.loadAnimation(2, -1);
            }
            paddle.animation.reverse();
            paddle.pendingAnimations = ['paddle_pulsate'.pulsateAnimation(4, 80)];
            ballBaseSpeed = BALL_BASE_SPEED + ballBaseSpeedAdjust;
          }
        case Laser:
          if (to != Laser) {
            game.input.bind(Key(Space));
            if (paddle.animation.cycle >= 0) {
              paddle.animation = 'paddle_laser'.loadAnimation(2, -1);
            }
            paddle.animation.reverse();
            paddle.pendingAnimations = ['paddle_pulsate'.pulsateAnimation(4, 80)];
          }
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
            paddle.pendingAnimations = ['paddle_wide'.loadAnimation(2, -1), 'paddle_wide_pulsate'.pulsateAnimation(4, 80)];
            if (paddle.animation.cycle >= 0) {
              paddle.animation = paddle.pendingAnimations.shift();
            }
            ballBaseSpeed = BALL_BASE_SPEED + ballBaseSpeedAdjust + 1;
          }
        case Laser:
          if (from != Laser) {
            game.input.bind(Key(Space), (_)->{ fire(); });
            paddle.pendingAnimations = ['paddle_laser'.loadAnimation(2, -1), 'paddle_laser_pulsate'.pulsateAnimation(4, 80)];
            if (paddle.animation.cycle >= 0) {
              paddle.animation = paddle.pendingAnimations.shift();
            }
          }
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
