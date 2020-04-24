package paddle_states;

import sprites.Paddle;

class NormalState extends PaddleState {
  var pulsator:PaddlePulsator;

  public function new(paddle:Paddle) {
    super(paddle);

    pulsator = new PaddlePulsator(paddle, 'paddle_pulsate');
  }

  override function update():Void {
    pulsator.update();
  }
}
