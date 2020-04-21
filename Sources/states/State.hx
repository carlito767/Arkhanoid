package states;

import kha.graphics2.Graphics;

class State {
  var game:Game;

  public function new(game:Game) {
    this.game = game;
  }

  public function update():Void {
  }

  public function render(g2:Graphics):Void {
  }
}
