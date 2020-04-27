package paddle_states;

import sprites.Paddle;
using AnimationExtension;
using PaddleExtension;

class MaterializeState extends PaddleState {
  var updateCount:Int = 0;

  var animation:Animation = 'paddle_materialize'.loadAnimation();

  public function new(paddle:Paddle) {
    super(paddle);
  }

  override function update():Void {
    if (updateCount % 2 == 0) {
      var image = animation.pop();
      if (image == null) {
        paddle.transition(NormalState.new);
      }
      else {
        paddle.image = image;
      }
    }

    updateCount++;
  }
}
