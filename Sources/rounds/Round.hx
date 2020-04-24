package rounds;

import kha.Assets;
import kha.Color;
import kha.graphics2.Graphics;

import paddle_states.PaddleState;

import sprites.Ball;
import sprites.Brick;
import sprites.BrickColor;
import sprites.Edges;
import sprites.Paddle;
import sprites.Sprite;

typedef Area = {
  x:Int,
  y:Int,
  width:Int,
  height:Int,
}

class Round {
  public var name:String = '';
  public var backgroundColor:Color = Color.Black;

  public var lives:Int;

  public var ball:Ball;
  public var paddle:Paddle;

  var bricks:Array<Brick>;
  var edges:Edges;

  var area:Area;

  public function new(lives:Int) {
    this.lives = lives;

    edges = createEdges();
    var x = edges.left.x + edges.left.image.width;
    var y = edges.top.y + edges.top.image.height;
    area = {
      x:x,
      y:y,
      width:edges.right.x - x,
      height:HEIGHT - y,
    };

    bricks = createBricks();
    paddle = createPaddle();
    ball = createBall();
    anchorBall();
  }

  public function update():Void {
    if (paddle.state != null) {
      paddle.state.update(paddle);
    }

    var moveLeft = paddle.moveLeft && !paddle.moveRight;
    var moveRight = paddle.moveRight && !paddle.moveLeft;
    if (moveLeft || moveRight) {
      paddle.x = (moveLeft) ? Std.int(Math.max(area.x, paddle.x - paddle.speed))
                            : Std.int(Math.min(area.x + area.width - paddle.image.width, paddle.x + paddle.speed));
      anchorBall();
    }
  }

  public function render(g2:Graphics):Void {
    // Draw background
    g2.color = backgroundColor;
    g2.fillRect(0, TOP_OFFSET, WIDTH, HEIGHT - TOP_OFFSET);

    // Draw edges
    g2.color = Color.White;
    for (edge in [edges.left, edges.right, edges.top]) {
      g2.drawImage(edge.image, edge.x, edge.y);
    }

    // Draw bricks
    for (brick in bricks) {
      g2.drawImage(brick.image, brick.x, brick.y);
    }

    // Draw lives
    var paddleLife = Assets.images.paddle_life;
    var x = area.x;
    for (i in 1...lives) {
      g2.drawImage(paddleLife, x, area.y + area.height - paddleLife.height - 5);
      x += paddleLife.width + 5;
    }

    // Draw paddle
    if (paddle.visible) {
      g2.drawImage(paddle.image, paddle.x, paddle.y);
    }

    // Draw ball
    if (ball.visible) {
      g2.drawImage(ball.image, ball.x, ball.y);
    }
  }

  //
  // Ball
  //

  function createBall(x:Int = 0, y:Int = 0):Ball {
    var image = Assets.images.ball;
    return {
      image:image,
      x:x,
      y:y,
      visible:false,
    };
  }

  function anchorBall():Void {
    ball.x = paddle.x + Std.int(paddle.image.width / 2);
    ball.y = paddle.y - ball.image.height;
  }

  //
  // Bricks
  //

  function createBricks():Array<Brick> {
    return [];
  }

  //
  // Edges
  //

  function createEdges():Edges {
    var edgeLeft = Assets.images.edge_left;
    var edgeRight = Assets.images.edge_right;
    var edgeTop = Assets.images.edge_top;
    return {
      left:{ image:edgeLeft, x:0, y:TOP_OFFSET },
      right:{ image:edgeRight, x:WIDTH - edgeRight.width, y:TOP_OFFSET },
      top:{ image:edgeTop, x:edgeLeft.width, y:TOP_OFFSET },
    };
  }

  //
  // Paddle
  //

  function createPaddle(speed:Int = PADDLE_SPEED):Paddle {
    var image = Assets.images.paddle;
    var bottomOffset = 30;
    return {
      image:image,
      x:area.x + Std.int((area.width - image.width) / 2),
      y:area.y + area.height - image.height - bottomOffset,
      moveLeft:false,
      moveRight:false,
      speed:speed,
      visible:false,
    };
  }
}
