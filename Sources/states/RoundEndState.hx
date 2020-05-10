package states;

import scenes.RoundScene;

class RoundEndState extends RoundState {
  static inline var NEXT_ROUND_FRAME = 60;

  var updateCount:Int = 0;

  public function new(scene:RoundScene) {
    super(scene);
  }

  override function update():Void {
    if (updateCount == NEXT_ROUND_FRAME) {
      game.switchToRound(round.id + 1, scene.lives);
    }

    updateCount++;
  }
}
