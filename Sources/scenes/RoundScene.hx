package scenes;

import kha.graphics2.Graphics;

import rounds.Round;
import states.RoundState;
import states.RoundStartState;

class RoundScene extends Scene {
  public var round(default,null):Round;
  public var state:RoundState;

  public function new(game:Game, id:Int, lives:Int) {
    super(game);

    var roundDataFactory = game.rounds[id - 1];
    round = new Round(id, lives, roundDataFactory());

    // Input bindings
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

    // Initialize state
    state = new RoundStartState(this);
  }

  override function update():Void {
    round.update(game);
    state.update();
  }

  override function render(g2:Graphics):Void {
    round.render(game, g2);
    state.render(g2);
  }
}
