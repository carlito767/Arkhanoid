package states;

import rounds.Round;

class RoundRestartState extends RoundState {
  var updateCount:Int = 0;

  public function new(game:Game, round:Round) {
    super(game, round);

    round.paddle = null;
  }

  override function postUpdate():Void {
    if (updateCount > 100) {
      round.lives--;
      game.state = new GameStartState(game, round);
    }

    updateCount++;
  }
}
