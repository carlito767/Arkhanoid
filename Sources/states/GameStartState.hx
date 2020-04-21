package states;

import kha.graphics2.Graphics;
import kha.input.KeyCode;

import input.InputEventType;
import input.MouseButton;
import states.RoundStartState;

class GameStartState extends State {
  public function new(game:Game) {
    super(game);

    // Input bindings
    game.input.clearBindings();
    game.input.bind(Mouse(Middle), game.switchMouseLock);
    game.input.bind(Key(Escape), game.backToTitle);
  }

  override function update():Void {
    game.state = new RoundStartState(game);
  }
}
