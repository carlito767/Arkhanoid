package rounds;

import kha.Assets;
import kha.Color;
import kha.graphics2.Graphics;

import sprites.EdgesSprites;
import sprites.Sprite;

class Round {
  public var name:String = '';
  public var backgroundColor:Color = Color.Black;

  var edges:EdgesSprites;

  public function new() {
    createEdges();
  }

  public function drawEdges(g2:Graphics):Void {
    g2.color = Color.White;
    for (edge in [edges.left, edges.right, edges.top]) {
      if (edge.visible) {
        g2.drawImage(edge.image, edge.x, edge.y);
      }
    }
  }

  function createEdges():Void {
    var edge_left = Assets.images.edge_left;
    var edge_right = Assets.images.edge_right;
    var edge_top = Assets.images.edge_top;
    edges = {
      left:{ image: edge_left, x:0, y:TOP_OFFSET },
      right:{ image: edge_right, x:WIDTH - edge_right.width , y:TOP_OFFSET },
      top:{ image: edge_top, x:edge_left.width, y:TOP_OFFSET },
    };
  }
}
