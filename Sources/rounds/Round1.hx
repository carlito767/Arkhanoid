package rounds;

import kha.Assets;
import kha.Color;

import sprites.Brick;
import sprites.BrickColor;

class Round1 {
  public static function generate():RoundData {
    var bricks:List<Brick> = new List();
    var colors = [BrickColor.silver, BrickColor.red, BrickColor.yellow, BrickColor.blue, BrickColor.green];
    var r = 4;
    for (color in colors) {
      var image = Assets.images.get('brick_${color}');
      for (c in 0...13) {
        bricks.add({
          image:image,
          x:c * image.width,
          y:r * image.height,
          color:color,
          collisions:0,
        });
      }
      r++;
    }

    return {
      backgroundColor:Color.fromBytes(0, 0, 128),
      bricks:bricks,
    };
  }
}
