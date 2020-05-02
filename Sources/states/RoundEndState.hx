package states;

import rounds.Round;

class RoundEndState extends RoundState {
  static inline var NEXT_ROUND_FRAME = 60;

  var updateCount:Int = 0;

  public function new(game:Game, round:Round) {
    super(game, round);
  }

  override function postUpdate():Void {
    if (updateCount == NEXT_ROUND_FRAME) {
      game.switchToRound(round.id + 1, round.lives);
    }

    updateCount++;
  }
}
