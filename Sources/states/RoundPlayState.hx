package states;

import rounds.Round;

class RoundPlayState extends RoundState {
  public function new(game:Game, round:Round) {
    super(game, round);

    // Input bindings
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
    if (round.balls.isEmpty()) {
      game.state = new BallOffScreenState(game, round);
    }
  }
}
