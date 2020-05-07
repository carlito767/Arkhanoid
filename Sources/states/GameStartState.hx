package states;

import rounds.Round;

class GameStartState extends RoundState {
  public function new(game:Game, round:Round) {
    super(game, round);

    // Input bindings
    game.resetBindings();
    #if debug
    game.input.bind(Key(Backspace), (_)->{ game.backToTitle(); });
    game.input.bind(Key(Subtract), (_)->{
      if (round.id > 1) {
        game.switchToRound(round.id - 1, round.lives);
      }
    });
    game.input.bind(Key(Add), (_)->{
      if (round.id < game.rounds.length) {
        game.switchToRound(round.id + 1, round.lives);
      }
    });
    game.input.bind(Key(S), (_)->{ round.showPowerups = !round.showPowerups; });
    #end
    game.input.bind(Key(R), (_)->{
      if (round.lives > 1) {
        game.state = new RoundRestartState(game, round);
      }
    });
    game.input.bind(Key(Left),
      (_)->{ round.moveLeft = true; },
      (_)->{ round.moveLeft = false; }
    );
    game.input.bind(Key(Right),
      (_)->{ round.moveRight = true; },
      (_)->{ round.moveRight = false; }
    );
  }

  override function postUpdate():Void {
    game.state = new RoundStartState(game, round);
  }
}
