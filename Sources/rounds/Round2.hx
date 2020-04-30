package rounds;

import kha.Color;

import sprites.Brick;

class Round2 {
  public static function generate():RoundData {
    var bricks:List<Brick> = new List();

    return {
      backgroundColor:Color.fromBytes(0, 128, 0),
      bricks:bricks,
    }
  }
}
