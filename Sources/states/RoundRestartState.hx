package states;

import scenes.RoundScene;

class RoundRestartState extends RoundState {
  static inline var RESTART_FRAME = 50;

  var updateCount:Int = 0;

  public function new(scene:RoundScene) {
    super(scene);

    scene.reset();
  }

  override function update():Void {
    if (updateCount == RESTART_FRAME) {
      scene.lives--;
      scene.state = new RoundStartState(scene);
    }

    updateCount++;
  }
}
