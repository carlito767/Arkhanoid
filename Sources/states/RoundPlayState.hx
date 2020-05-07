package states;

import rounds.Round;

class RoundPlayState extends RoundState {
  public function new(game:Game, round:Round) {
    super(game, round);
  }

  override function postUpdate():Void {
    if (round.win()) {
      // You win!
      game.state = new RoundEndState(game, round);
    }
    else if (round.lose()) {
      // You lose!
      game.state = new BallOffScreenState(game, round);
    }
  }
}
