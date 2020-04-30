package states;

import rounds.Round;

class RoundEndState extends RoundState {
  static inline var NEXT_ROUND_FRAME = 60;

  public function new(game:Game, round:Round) {
    super(game, round);

    round.balls.clear();
  }

  override function postUpdate():Void {
    if (frame == NEXT_ROUND_FRAME) {
      game.switchToRound(round.id + 1);
    }
  }
}
