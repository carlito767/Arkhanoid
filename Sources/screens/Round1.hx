package screens;

import kha.Color;
import kha.graphics2.Graphics;
import kha.input.KeyCode;

class Round1 extends Screen {
  public function new() {
    super();
  }

  override function update():Void {
    if (game.keyboard.isPressed(KeyCode.Space)) {
      game.switchTo(0);
    }
  }

  override function render(g2:Graphics):Void {
    g2.color = Color.fromBytes(0, 0, 128);
    g2.fillRect(0, 150, WIDTH, HEIGHT - 150);
  }
}
