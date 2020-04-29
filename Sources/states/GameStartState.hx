package states;

import rounds.Round;

class GameStartState extends RoundState {
  public function new(game:Game, round:Round) {
    super(game, round);

    // Input bindings
    game.input.clearBindings();
    #if debug
    game.input.bind(Key(Backspace), (_)->{ game.backToTitle(); });
    #end
    game.input.bind(Mouse(Left), (_)->{ game.switchMouseLock(); });
  }

  override function postUpdate():Void {
    game.state = new RoundStartState(game, round);
  }
}
