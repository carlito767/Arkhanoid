package states;

import kha.graphics2.Graphics;

import rounds.Round;

class GameStartState implements State {
  var round:Round;

  public function new(round:Round) {
    this.round = round;
  }

  public function enter(game:Game):Void {
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
    game.input.bind(Key(R), (_)->{
      game.switchToRound(round.id, round.lives);
    });
    #end
    game.input.bind(Key(Left),
      (_)->{ round.moveLeft = true; },
      (_)->{ round.moveLeft = false; }
    );
    game.input.bind(Key(Right),
      (_)->{ round.moveRight = true; },
      (_)->{ round.moveRight = false; }
    );
  }

  public function exit(game:Game):Void {
  }

  public function update(game:Game):Void {
    round.update(game);

    game.state = new RoundStartState(round);
  }

  public function render(game:Game, g2:Graphics):Void {
    round.render(game, g2);
  }
}
