package states;

import rounds.Round;

class RoundRestartState extends RoundState {
  static inline var RESTART_FRAME = 50;

  var updateCount:Int = 0;

  public function new(game:Game, round:Round) {
    super(game, round);

    round.reset();
  }

  override function postUpdate():Void {
    if (updateCount == RESTART_FRAME) {
      if (!game.godMode) round.lives--;
      game.state = new RoundStartState(game, round);
    }

    updateCount++;
  }
}
