package states;

import kha.graphics2.Graphics;

import rounds.Round;

class GameOverState implements State {
  static inline var BACK_TO_TITLE_FRAME = 60;

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

    if (updateCount == BACK_TO_TITLE_FRAME) {
      game.backToTitle();
    }

    updateCount++;
  }

  public function render(game:Game, g2:Graphics):Void {
    round.render(game, g2);
  }
}
