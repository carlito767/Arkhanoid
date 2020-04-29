package states;

import kha.graphics2.Graphics;

import rounds.Round;

class RoundState implements State {
  var game:Game;
  var round:Round;

  public function new(game:Game, round:Round) {
    this.game = game;
    this.round = round;
  }

  public function update():Void {
    round.update();
  }

  public function render(g2:Graphics):Void {
    round.render(g2);
  }
}
