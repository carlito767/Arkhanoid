import kha.Assets;
import kha.graphics2.Graphics;

class Scene implements State {
  public final MAIN_FONT = Assets.fonts.generation;
  public final ALT_FONT = Assets.fonts.optimus;

  public var game(default,null):Game;

  public function new(game:Game) {
    this.game = game;

    game.pause = false;
    game.resetBindings();
  }

  public function update():Void {
  }

  public function render(g2:Graphics):Void {
  }
}
