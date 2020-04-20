package paddle_states;

import sprites.Paddle;

class PaddlePulsator {
  var updateCount:Int = 0;

  var animation:Null<Animation> = null;
  var animation1:Animation;
  var animation2:Animation;

  public function new(id:String) {
    animation1 = AnimationManager.load(id);
    animation2 = AnimationManager.reverse(animation1);
  }

  public function update(paddle:Paddle) {
    if (updateCount % 80 == 0) {
      animation = AnimationManager.chain(animation1, animation2);
      updateCount = 0;
    }
    else if (animation != null) {
      if (updateCount % 4 == 0) {
        var image = AnimationManager.next(animation);
        if (image == null) {
          animation = null;
        }
        else {
          paddle.image = image;
        }
      }
    }
    updateCount++;
  }
}
