package rounds;

import kha.Assets;
import kha.Color;
import kha.graphics2.Graphics;

import sprites.Ball;
import sprites.Brick;
import sprites.Edge;
import sprites.Paddle;
import sprites.Sprite;

class Round {
  public static inline var LIVES = 3;
  public static inline var PADDLE_SPEED = 10;
  public static inline var TOP_OFFSET = 150;

  // (left,top)
  //      +---------------+
  //      |               |
  //      |               |
  //      |               |
  //      |               |
  //      |               |
  //      +---------------+
  //                (right,bottom)
  public var boundLeft(get, never):Float; inline function get_boundLeft() return edgeLeft.x + edgeLeft.image.width; 
  public var boundTop(get, never):Float; inline function get_boundTop() return edgeTop.y + edgeTop.image.height; 
  public var boundRight(get, never):Float; inline function get_boundRight() return edgeRight.x; 
  public var boundBottom(get, never):Float; inline function get_boundBottom() return Game.HEIGHT; 

  public var id(default, null):Int;
  public var backgroundColor:Color = Color.Black;

  public var moveLeft:Bool = false;
  public var moveRight:Bool = false;

  public var lives:Int;
  public var score:Int = 0;

  var balls:Array<Ball> = [];
  var bricks:Array<Brick> = [];
  var paddle:Null<Paddle> = null;

  var edgeLeft:Edge;
  var edgeRight:Edge;
  var edgeTop:Edge;

  public function new(id:Int, lives:Int = LIVES) {
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

  public function update():Void {
    // Update paddle
    var dx = 0.0;
    if (paddle != null) {
      if (paddle.state != null) {
        paddle.state.update();
      }

      if (moveLeft && !moveRight) {
        dx = -paddle.speed;
      }
      else if (moveRight && !moveLeft) {
        dx = paddle.speed;
      }

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
  // Collisions
  //

  inline function left(sprite:Sprite):Float return sprite.x;
  inline function top(sprite:Sprite):Float return sprite.y;
  inline function right(sprite:Sprite):Float return sprite.x + sprite.image.width;
  inline function bottom(sprite:Sprite):Float return sprite.y + sprite.image.height;

  function collide(A:Sprite, B:Sprite, ?dx:Float = 0, ?dy:Float = 0):Bool {
    return (right(A) + dx >= left(B) && left(A) + dx <= right(B) && bottom(A) + dy >= top(B) && top(A) + dy <= bottom(B));
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
    };
    balls.push(ball);
    return ball;
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
