package states;

import kha.graphics2.Graphics;
import kha.input.KeyCode;

class RoundPlayState extends State {
  public function new(game:Game) {
    super(game);
  }

  override function update():Void {
    game.round.update();
  }

  override function render(g2:Graphics):Void {
    game.round.render(g2);
  }
}
