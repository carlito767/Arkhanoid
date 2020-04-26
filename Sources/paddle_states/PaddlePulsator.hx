package paddle_states;

import sprites.Paddle;
using AnimationExtension;

class PaddlePulsator {
  var updateCount:Int = 0;

  var animation:Animation;
  var animation1:Animation;
  var animation2:Animation;

  var paddle:Paddle;

  public function new(paddle:Paddle, id:String) {
    this.paddle = paddle;
  
    animation1 = id.loadAnimation();
    animation2 = animation1.reverse();
  }

  public function update() {
    if (updateCount % 80 == 0) {
      animation = animation1.chain(animation2);
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
