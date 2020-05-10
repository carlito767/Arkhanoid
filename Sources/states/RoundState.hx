package states;

import kha.graphics2.Graphics;

import components.Bounds;
import rounds.RoundData;
import scenes.RoundScene;
import world.World;

class RoundState implements State {
  var game(get,never):Game; inline function get_game() return scene.game;
  var roundData(get,never):RoundData; inline function get_roundData() return scene.roundData;
  var world(get,never):World; inline function get_world() return scene.world;
  var worldBounds(get,never):Bounds; inline function get_worldBounds() return scene.worldBounds;

  var scene:RoundScene;

  public function new(scene:RoundScene) {
    this.scene = scene;
  }

  public function update():Void {
  }

  public function render(g2:Graphics):Void {
  }
}
