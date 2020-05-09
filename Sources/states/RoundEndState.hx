package states;

import kha.graphics2.Graphics;

import rounds.Round;

class RoundEndState implements State {
  static inline var NEXT_ROUND_FRAME = 60;

  var updateCount:Int = 0;

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

    if (updateCount == NEXT_ROUND_FRAME) {
      game.switchToRound(round.id + 1, round.lives);
    }

    updateCount++;
  }

  public function render(game:Game, g2:Graphics):Void {
    round.render(game, g2);
  }
}
