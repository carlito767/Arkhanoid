package states;

import kha.graphics2.Graphics;

interface State {
  public function update():Void;
  public function render(g2:Graphics):Void;
}
