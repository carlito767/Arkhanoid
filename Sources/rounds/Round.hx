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

  public var moveLeft:Bool = false;
  public var moveRight:Bool = false;

  public var lives:Int;

  var balls:Array<Ball> = [];
  var bricks:Array<Brick> = [];
  var paddle:Null<Paddle> = null;

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
  }

  public function update():Void {
    if (paddle != null) {
      if (paddle.state != null) {
        paddle.state.update(paddle);
      }

      var left = moveLeft && !moveRight;
      var right = moveRight && !moveLeft;
      if (left || right) {
        var x = (left) ? Std.int(Math.max(area.x, paddle.x - paddle.speed))
                       : Std.int(Math.min(area.x + area.width - paddle.image.width, paddle.x + paddle.speed));
        var dx = x - paddle.x;
        paddle.x = x;

        for (ball in balls) {
          if (ball.anchored) {
            ball.x += dx;
          }
        }
      }
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
    if (paddle != null) {
      g2.drawImage(paddle.image, paddle.x, paddle.y);
    }

    // Draw ball
    for (ball in balls) {
      g2.drawImage(ball.image, ball.x, ball.y);
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

  @:allow(states.State)
  function createPaddle(speed:Int = PADDLE_SPEED):Paddle {
    var image = Assets.images.paddle;
    paddle = {
      image:image,
      x:area.x + Std.int((area.width - image.width) * 0.5),
      y:area.y + area.height - image.height - 30,
      speed:speed,
    };
    return paddle;
  }
}
