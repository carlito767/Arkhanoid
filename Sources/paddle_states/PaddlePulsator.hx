package paddle_states;

import sprites.Paddle;

class PaddlePulsator {
  var updateCount:Int = 0;

  var animation:Animation;
  var animation1:Animation;
  var animation2:Animation;

  var paddle:Paddle;

  public function new(paddle:Paddle, id:String) {
    this.paddle = paddle;
  
    animation1 = AnimationTools.loadSequence(id);
    animation2 = AnimationTools.reverse(animation1);
  }

  public function update() {
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
