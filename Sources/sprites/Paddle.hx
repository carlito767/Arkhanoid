package sprites;

import paddle_states.PaddleState;

typedef Paddle = {
  > Sprite,
  ?state:PaddleState,
  visible:Bool,

  moveLeft:Bool,
  moveRight:Bool,
  speed:Int,
}
