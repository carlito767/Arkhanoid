package states;

import rounds.Round;
using AnimationExtension;

class BallOffScreenState extends RoundState {
  public function new(game:Game, round:Round) {
    super(game, round);

    round.destroyPaddle();
  }

  override function postUpdate():Void {
    if (round.paddle.animation.over()) {
      if (round.lives > 1) {
        // Try again!
        game.state = new RoundRestartState(game, round);
      }
      else {
        // Game over!
        game.state = new GameOverState(game, round);
      }
    }
  }
}
