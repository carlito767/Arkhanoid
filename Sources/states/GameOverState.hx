package states;

import rounds.Round;

class GameOverState extends RoundState {
  static inline var BACK_TO_TITLE_FRAME = 60;

  var updateCount:Int = 0;

  public function new(game:Game, round:Round) {
    super(game, round);

    round.balls.clear();
    round.paddle = null;
  }

  override function postUpdate():Void {
    if (updateCount == BACK_TO_TITLE_FRAME) {
      game.backToTitle();
    }

    updateCount++;
  }
}
