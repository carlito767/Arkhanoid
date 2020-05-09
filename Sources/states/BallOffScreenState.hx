package states;

import kha.graphics2.Graphics;

import rounds.Round;
using AnimationExtension;

class BallOffScreenState implements State {
  var round:Round;

  public function new(round:Round) {
    this.round = round;
  }

  public function enter(game:Game):Void {
    round.destroyPaddle();
  }

  public function exit(game:Game):Void {
  }

  public function update(game:Game):Void {
    round.update(game);

    if (round.paddle.animation.over()) {
      if (round.lives > 1) {
        // Try again!
        game.state = new RoundRestartState(round);
      }
      else {
        // Game over!
        game.state = new GameOverState(round);
      }
    }
  }

  public function render(game:Game, g2:Graphics):Void {
    round.render(game, g2);
  }
}
