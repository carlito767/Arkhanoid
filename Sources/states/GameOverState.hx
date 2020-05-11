package states;

import scenes.RoundScene;

class GameOverState extends RoundState {
  static inline var BACK_TO_TITLE_FRAME = 50;

  var updateCount:Int = 0;

  public function new(scene:RoundScene) {
    super(scene);

    scene.reset();
  }

  override function update():Void {
    if (updateCount == BACK_TO_TITLE_FRAME) {
      game.backToTitle();
    }

    updateCount++;
  }
}
