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
  public var paddleState:Null<PaddleState>;

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

    paddleState = null;
  }

  public function update():Void {
    if (paddleState != null) {
      paddleState.update(paddle);
    }
  }

  public function drawBall(g2:Graphics):Void {
    if (ball.visible) {
      g2.color = Color.White;
      g2.drawImage(ball.image, ball.x, ball.y);
    }
  }

  public function drawBricks(g2:Graphics):Void {
    g2.color = Color.White;
    for (brick in bricks) {
      g2.drawImage(brick.image, brick.x, brick.y);
    }
  }

  public function drawEdges(g2:Graphics):Void {
    g2.color = Color.White;
    for (edge in [edges.left, edges.right, edges.top]) {
      g2.drawImage(edge.image, edge.x, edge.y);
    }
  }

  public function drawLives(g2:Graphics):Void {
    var paddleLife = Assets.images.paddle_life;
    var x = edges.left.image.width;
    g2.color = Color.White;
    for (i in 1...lives) {
      g2.drawImage(paddleLife, x, area.y + area.height - paddleLife.height - 5);
      x += paddleLife.width + 5;
    }
  }

  public function drawPaddle(g2:Graphics):Void {
    if (paddle.visible) {
      g2.color = Color.White;
      g2.drawImage(paddle.image, paddle.x, paddle.y);
    }
  }

  function createBall():Ball {
    var ball = Assets.images.ball;
    return {
      image:ball,
      x:paddle.x + Std.int(paddle.image.width / 2),
      y:paddle.y - ball.height,
      visible:false,
    };
  }

  function createBricks():Array<Brick> {
    return [];
  }

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

  function createPaddle():Paddle {
    var paddle = Assets.images.paddle;
    var bottomOffset = 30;
    return {
      image:paddle,
      x:area.x + Std.int((area.width - paddle.width) / 2),
      y:area.y + area.height - paddle.height - bottomOffset,
      visible:false,
    };
  }
}
