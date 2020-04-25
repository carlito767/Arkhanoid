package rounds;

import kha.Color;

class Round2 extends Round {
  public function new(id:Int, lives:Int) {
    super(id, lives);

    backgroundColor = Color.fromBytes(0, 128, 0);
  }
}
