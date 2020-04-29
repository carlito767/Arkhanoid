package rounds;

import kha.Assets;
import kha.Color;

import sprites.Brick;
import sprites.BrickColor;

class Round1 extends Round {
  public function new(id:Int, lives:Int) {
    super(id, lives);

    backgroundColor = Color.fromBytes(0, 0, 128);
  }

  override function createBricks():List<Brick> {
    var bricks:List<Brick> = new List();
    var colors = [BrickColor.silver, BrickColor.red, BrickColor.yellow, BrickColor.blue, BrickColor.green];
    var r = 4;
    for (color in colors) {
      var image = Assets.images.get('brick_${color}');
      for (c in 0...13) {
        bricks.add({
          image:image,
          x:boundLeft + c * image.width,
          y:boundTop + r * image.height,
          color:color,
          collisions:0,
        });
      }
      r++;
    }
    return bricks;
  }
}
