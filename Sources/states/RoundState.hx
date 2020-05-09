package states;

import kha.graphics2.Graphics;

import rounds.Round;
import scenes.RoundScene;

class RoundState implements State {
  var game(get,never):Game; inline function get_game() return scene.game;
  var round(get,never):Round; inline function get_round() return scene.round;

  var scene:RoundScene;

  public function new(scene:RoundScene) {
    this.scene = scene;
  }

  public function update():Void {
  }

  public function render(g2:Graphics):Void {
  }
}
