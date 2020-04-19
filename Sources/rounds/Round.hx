package rounds;

import kha.Assets;
import kha.Color;
import kha.graphics2.Graphics;

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

  function createBricks():Array<Brick> {
    return [];
  }

  function createEdges():Edges {
    var edge_left = Assets.images.edge_left;
    var edge_right = Assets.images.edge_right;
    var edge_top = Assets.images.edge_top;
    return {
      left:{ image:edge_left, x:0, y:TOP_OFFSET },
      right:{ image:edge_right, x:WIDTH - edge_right.width, y:TOP_OFFSET },
      top:{ image:edge_top, x:edge_left.width, y:TOP_OFFSET },
    };
  }

  function createPaddle():Paddle {
    var paddle = Assets.images.paddle;
    var bottomOffset = 30;
    return pos({
      image:paddle,
      x:Std.int((area.width - paddle.width) / 2),
      y:area.height - paddle.height - bottomOffset,
      visible:false,
    });
  }

  final function pos<T:(Sprite)>(sprite:T):T {
    sprite.x += area.x;
    sprite.y += area.y;
    return sprite;
  }
}
