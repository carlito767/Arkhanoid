package paddle_states;

import sprites.Paddle;

class PaddleState {
  var paddle:Paddle;

  public function new(paddle:Paddle) {
    this.paddle = paddle;
  }

  public function enter():Void {
  }

  public function update():Void {
  }

  public function exit():Void {
  }

  @:allow(states.State)
  static function transition(paddle:Paddle, paddleStateFactory:PaddleStateFactory):Void {
    if (paddle.state != null) {
      paddle.state.exit();
    }
    var state = paddleStateFactory(paddle);
    state.enter();
    paddle.state = state;
  }
}
