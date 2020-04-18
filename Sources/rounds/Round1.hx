package rounds;

import kha.Color;

class Round1 extends Round {
  public function new(lives:Int) {
    super(lives);

    name = 'Round 1';
    backgroundColor = Color.fromBytes(0, 0, 128);
  }
}
