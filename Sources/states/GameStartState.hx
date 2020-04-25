package states;

import states.RoundStartState;

class GameStartState extends State {
  public function new(game:Game) {
    super(game);

    // Input bindings
    game.input.clearBindings();
    game.input.bind(Mouse(Left), (_)->{ game.switchMouseLock(); });
    game.input.bind(Key(Escape), (_)->{ game.switchToRound(0); });
  }

  override function update():Void {
    game.state = new RoundStartState(game);
  }
}
