package states;

import rounds.Round;
using AnimationExtension;

class BallOffScreenState extends RoundState {
  public function new(game:Game, round:Round) {
    super(game, round);

    // Don't move...
    game.input.clearBindings();
    round.moveLeft = false;
    round.moveRight = false;
    // ...my deadly love!
    round.paddle.animation = 'paddle_explode'.loadAnimation(4, -1);
  }

  override function postUpdate():Void {
    if (round.paddle.animation == null) {
      if (round.lives > 1) {
        game.state = new RoundRestartState(game, round);
      }
      else {
        game.backToTitle();
      }
    }
  }
}
