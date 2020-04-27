import paddle_states.PaddleStateFactory;
import sprites.Paddle;

class PaddleExtension {
  public static function transition(paddle:Paddle, paddleStateFactory:PaddleStateFactory):Void {
    if (paddle.state != null) {
      paddle.state.exit();
    }
    var state = paddleStateFactory(paddle);
    state.enter();
    paddle.state = state;
  }
}
