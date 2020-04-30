package states;

import kha.graphics2.Graphics;

import rounds.Round;

class RoundState implements State {
  var game:Game;
  var round:Round;
  var frame:Int = 0;

  public function new(game:Game, round:Round) {
    this.game = game;
    this.round = round;
  }

  public final function update():Void {
    round.update(game);
    postUpdate();
    frame++;
  }

  public final function render(g2:Graphics):Void {
    round.render(g2);
    postRender(g2);
  }

  function postUpdate():Void {
  }

  function postRender(g2:Graphics):Void {
  }
}
