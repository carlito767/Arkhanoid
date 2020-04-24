package sprites;

import paddle_states.PaddleState;

typedef Paddle = {
  > Sprite,
  ?state:PaddleState,
  speed:Int,
}
