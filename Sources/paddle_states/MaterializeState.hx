package paddle_states;

import sprites.Paddle;

class MaterializeState implements PaddleState {
  var updateCount:Int = 0;

  var animation:Images = AnimationTools.loadSequence('paddle_materialize');

  public function new() {
  }

  public function enter():Void {
  }

  public function update(paddle:Paddle):Void {
    if (updateCount % 2 == 0) {
      var image = animation.pop();
      if (image == null) {
        PaddleStateManager.transition(paddle, new NormalState());
      }
      else {
        paddle.image = image;
      }
    }

    updateCount++;
  }

  public function exit():Void {
  }
}
