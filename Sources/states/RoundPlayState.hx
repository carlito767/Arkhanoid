package states;

import kha.graphics2.Graphics;

import rounds.Round;

class RoundPlayState implements State {
  var round:Round;

  public function new(round:Round) {
    this.round = round;
  }

  public function enter(game:Game):Void {
  }

  public function exit(game:Game):Void {
  }

  public function update(game:Game):Void {
    round.update(game);

    if (round.win()) {
      // You win!
      game.state = new RoundEndState(round);
    }
    else if (round.lose()) {
      // You lose!
      game.state = new BallOffScreenState(round);
    }
  }

  public function render(game:Game, g2:Graphics):Void {
    round.render(game, g2);
  }
}
