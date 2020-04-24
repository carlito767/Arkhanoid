package paddle_states;

import sprites.Paddle;

class PaddlePulsator {
  var updateCount:Int = 0;

  var animation:Null<Images> = null;
  var animation1:Images;
  var animation2:Images;

  public function new(id:String) {
    animation1 = AnimationTools.loadSequence(id);
    animation2 = AnimationTools.reverse(animation1);
  }

  public function update(paddle:Paddle) {
    if (updateCount % 80 == 0) {
      animation = AnimationTools.chain(animation1, animation2);
      updateCount = 0;
    }
    else if (updateCount % 4 == 0) {
      if (!animation.isEmpty()) {
        paddle.image = animation.pop();
      }
    }
    updateCount++;
  }
}
