package states;

import kha.graphics2.Graphics;

interface State {
  public function update(game:Game):Void;
  public function render(game:Game, g2:Graphics):Void;
}
