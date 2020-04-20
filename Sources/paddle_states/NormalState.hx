package paddle_states;

import sprites.Paddle;

class NormalState implements PaddleState {
  var pulsator:PaddlePulsator = new PaddlePulsator('paddle_pulsate');

  public function new() {
  }

  public function enter():Void {
  }

  public function update(paddle:Paddle):Void {
    pulsator.update(paddle);
  }

  public function exit():Void {
  }
}
