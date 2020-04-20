package paddle_states;

import sprites.Paddle;

class PaddleStateManager {
  public static function transition(paddle:Paddle, state:PaddleState):Void {
    if (paddle.state != null) {
      paddle.state.exit();
    }
    state.enter();
    paddle.state = state;
  }
}
