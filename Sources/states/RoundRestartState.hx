package states;

import kha.graphics2.Graphics;

import rounds.Round;

class RoundRestartState implements State {
  static inline var RESTART_FRAME = 50;

  var updateCount:Int = 0;

  var round:Round;

  public function new(round:Round) {
    this.round = round;
  }

  public function enter(game:Game):Void {
    round.reset();
  }

  public function exit(game:Game):Void {
  }

  public function update(game:Game):Void {
    round.update(game);

    if (updateCount == RESTART_FRAME) {
      if (!game.godMode) round.lives--;
      game.state = new RoundStartState(round);
    }

    updateCount++;
  }

  public function render(game:Game, g2:Graphics):Void {
    round.render(game, g2);
  }
}
