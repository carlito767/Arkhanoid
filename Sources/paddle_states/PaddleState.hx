package paddle_states;

import sprites.Paddle;

interface PaddleState {
  public function enter():Void;
  public function update(paddle:Paddle):Void;
  public function exit():Void;
}
