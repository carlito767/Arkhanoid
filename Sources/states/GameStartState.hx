package states;

import rounds.Round;

class GameStartState extends RoundState {
  public function new(game:Game, round:Round) {
    super(game, round);

    // Input bindings
    game.input.clearBindings();
    #if debug
    game.input.bind(Key(Backspace), (_)->{ game.backToTitle(); });
    game.input.bind(Key(Subtract), (_)->{
      if (round.id > 1) {
        game.switchToRound(round.id - 1);
      }
    });
    game.input.bind(Key(Add), (_)->{
      if (round.id < game.rounds.length) {
        game.switchToRound(round.id + 1);
      }
    });
    #end
    game.input.bind(Mouse(Left), (_)->{ game.switchMouseLock(); });
    game.input.bind(Key(R), (_)->{
      if (round.lives > 1) {
        game.state = new RoundRestartState(game, round);
      }
    });
  }

  override function postUpdate():Void {
    game.state = new RoundStartState(game, round);
  }
}
