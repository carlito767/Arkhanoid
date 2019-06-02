import kha.Color;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.graphics2.Graphics;
using kha.graphics2.GraphicsExtension;
import kha.input.KeyCode;

interface ICollidable {
  public function left():Float;
  public function right():Float;
  public function top():Float;
  public function bottom():Float;
}

@:structInit
class Ball implements ICollidable {
  public var x:Float;
  public var y:Float;

  public function new(x:Float, y:Float) {
    this.x = x;
    this.y = y;
  }

  public function left():Float { return x - BALL_RADIUS; }
  public function right():Float { return x + BALL_RADIUS; }
  public function top():Float { return y - BALL_RADIUS; }
  public function bottom():Float { return y + BALL_RADIUS; }
}

@:structInit
class Paddle implements ICollidable {
  public var x:Float;
  public var y:Float;

  public function new(x:Float, y:Float) {
    this.x = x;
    this.y = y;
  }

  public function left():Float { return x - PADDLE_WIDTH * 0.5; }
  public function right():Float { return x + PADDLE_WIDTH * 0.5; }
  public function top():Float { return y - PADDLE_HEIGHT * 0.5; }
  public function bottom():Float { return y + PADDLE_HEIGHT * 0.5; }
}

@:structInit
class Brick implements ICollidable {
  public var x:Float;
  public var y:Float;
  public var destroyed:Bool;

  public function new(x:Float, y:Float) {
    this.x = x;
    this.y = y;
    destroyed = false;
  }

  public function left():Float { return x - BRICK_WIDTH * 0.5; }
  public function right():Float { return x + BRICK_WIDTH * 0.5; }
  public function top():Float { return y - BRICK_HEIGHT * 0.5; }
  public function bottom():Float { return y + BRICK_HEIGHT * 0.5; }
}

typedef Velocity = {
  var x:Float;
  var y:Float;
}

class Game {
  var ball:Ball = { x:WIDTH * 0.5, y:HEIGHT * 0.5 };
  var ballVelocity:Velocity = { x:-BALL_VELOCITY, y:-BALL_VELOCITY };

  var paddle:Paddle = { x:WIDTH * 0.5, y:HEIGHT - 50 };
  var paddleVelocity:Velocity = { x:0, y:0 };

  var bricks:List<Brick> = new List();

  var keyboard:Keyboard = new Keyboard();

  public function new() {
    for (x in 0...BRICKS_X) {
      for (y in 0...BRICKS_Y) {
        bricks.push({ x:(x + 1) * (BRICK_WIDTH + 3) + 22, y:(y + 2) * (BRICK_HEIGHT + 3) });
      }
    }

    Scheduler.addTimeTask(update, 0, 1 / 60);
    System.notifyOnFrames(render);
  }

  function update():Void {
    // Update Ball
    if (ball.left() < 0) ballVelocity.x = BALL_VELOCITY;
    else if (ball.right() > WIDTH) ballVelocity.x = -BALL_VELOCITY;

    if (ball.top() < 0) ballVelocity.y = BALL_VELOCITY;
    else if (ball.bottom() > HEIGHT) ballVelocity.y = -BALL_VELOCITY;

    ball.x = ball.x + ballVelocity.x;
    ball.y = ball.y + ballVelocity.y;

    // Update Paddle
    if (keyboard.isPressed(KeyCode.Left) && (paddle.left() > 0)) paddleVelocity.x = -PADDLE_VELOCITY;
    else if (keyboard.isPressed(KeyCode.Right) && (paddle.right() < WIDTH)) paddleVelocity.x = PADDLE_VELOCITY;
    else paddleVelocity.x = 0;

    paddle.x = paddle.x + paddleVelocity.x;
    paddle.y = paddle.y + paddleVelocity.y;

    // Detect Paddle Collision
    if (isIntersecting(paddle, ball)) {
      ballVelocity.x = (ball.x < paddle.x) ? -BALL_VELOCITY : BALL_VELOCITY;
      ballVelocity.y = -BALL_VELOCITY;
    }

    // Detect Brick Collision
    for (brick in bricks) {
      if (isIntersecting(brick, ball)) {
        brick.destroyed = true;

        var overlapLeft = ball.right() - brick.left();
        var overlapRight = brick.right() - ball.left();
        var overlapTop = ball.bottom() - brick.top();
        var overlapBottom = brick.bottom() - ball.top();

        var ballFromLeft = Math.abs(overlapLeft) < Math.abs(overlapRight);
        var ballFromTop = Math.abs(overlapTop) < Math.abs(overlapBottom);

        var minOverlapX = ballFromLeft ? overlapLeft : overlapRight;
        var minOverlapY = ballFromTop ? overlapTop : overlapBottom;

        if (Math.abs(minOverlapX) < Math.abs(minOverlapY))
          ballVelocity.x = ballFromLeft ? -BALL_VELOCITY : BALL_VELOCITY;
        else
          ballVelocity.y = ballFromTop ? -BALL_VELOCITY : BALL_VELOCITY;
      }
    }

    // Remove Bricks
    bricks = bricks.filter(function(brick) { return !brick.destroyed; });
  }

  function render(framebuffers:Array<Framebuffer>):Void {
    var g2 = framebuffers[0].g2;
    g2.begin();

    // Draw Ball
    g2.color = Color.Red;
    g2.fillCircle(ball.x, ball.y, BALL_RADIUS);

    // Draw Paddle
    g2.color = Color.Red;
    g2.fillRect(paddle.left(), paddle.top(), PADDLE_WIDTH, PADDLE_HEIGHT);

    // Draw Bricks
    for (brick in bricks) {
      g2.color = Color.Yellow;
      g2.fillRect(brick.left(), brick.top(), BRICK_WIDTH, BRICK_HEIGHT);
    }

    g2.end();
  }

  function isIntersecting(A:ICollidable, B:ICollidable):Bool {
    return (A.right() >= B.left() && A.left() <= B.right() && A.bottom() >= B.top() && A.top() <= B.bottom());
  }
}
