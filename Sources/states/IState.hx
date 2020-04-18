package states;

import kha.graphics2.Graphics;

import screens.GameScreen;

interface IState {
  public function update(screen:GameScreen, game:Game):Void;
  public function render(screen:GameScreen, game:Game, g2:Graphics):Void;
}
