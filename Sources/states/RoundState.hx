package states;

import kha.graphics2.Graphics;

import components.Bounds;
import rounds.Round;
import scenes.RoundScene;
import world.Entity;
import world.World;

class RoundState implements State {
  var edgeLeft(get,never):Entity; inline function get_edgeLeft() return scene.edgeLeft;
  var edgeRight(get,never):Entity; inline function get_edgeRight() return scene.edgeRight;
  var edgeTop(get,never):Entity; inline function get_edgeTop() return scene.edgeTop;
  var game(get,never):Game; inline function get_game() return scene.game;
  var paddle(get,never):Entity; inline function get_paddle() return scene.paddle;
  var round(get,never):Round; inline function get_round() return scene.round;
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
