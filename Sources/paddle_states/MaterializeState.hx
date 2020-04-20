package paddle_states;

import sprites.Paddle;

class MaterializeState implements PaddleState {
  var updateCount:Int = 0;

  var animation:Animation = AnimationManager.load('paddle_materialize');

  public function new() {
  }

  public function enter():Void {
  }

  public function update(paddle:Paddle):Void {
    if (updateCount % 2 == 0) {
      var image = AnimationManager.next(animation);
      if (image == null) {
        // TODO: transition to NormalState
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
