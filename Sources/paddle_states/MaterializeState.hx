package paddle_states;

import sprites.Paddle;

class MaterializeState extends PaddleState {
  var updateCount:Int = 0;

  var animation:Animation = AnimationTools.loadSequence('paddle_materialize');

  public function new(paddle:Paddle) {
    super(paddle);
  }

  override function update():Void {
    if (updateCount % 2 == 0) {
      var image = animation.pop();
      if (image == null) {
        PaddleState.transition(paddle, NormalState.new);
      }
      else {
        paddle.image = image;
      }
    }

    updateCount++;
  }
}
