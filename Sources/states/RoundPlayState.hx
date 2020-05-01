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
    if (round.win()) {
      // You win!
      game.state = new RoundEndState(game, round);
    }
    else if (round.lose()) {
      // You lose!
      game.state = new BallOffScreenState(game, round);
    }
  }
}
