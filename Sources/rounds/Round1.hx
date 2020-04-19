package rounds;

import kha.Assets;
import kha.Color;

import sprites.Brick;
import sprites.BrickColor;

class Round1 extends Round {
  public function new(lives:Int) {
    super(lives);

    name = 'Round 1';
    backgroundColor = Color.fromBytes(0, 0, 128);
  }

  override function createBricks():Array<Brick> {
    var bricks:Array<Brick> = [];
    var colors = [BrickColor.silver, BrickColor.red, BrickColor.yellow, BrickColor.blue, BrickColor.green];
    var r = 4;
    for (color in colors) {
      var image = Assets.images.get('brick_${color}');
      for (c in 0...13) {
        bricks.push({
          color:color,
          image:image,
          x:area.x + c * image.width,
          y:area.y + r * image.height,
        });
      }
      r++;
    }
    return bricks;
  }
}
