package rounds;

import kha.Color;

class Round2 extends Round {
  public function new(lives:Int) {
    super(lives);

    name = 'Round 2';
    backgroundColor = Color.fromBytes(0, 128, 0);
  }
}
