package states;

import scenes.RoundScene;
using AnimationExtension;

class BallOffScreenState extends RoundState {
  public function new(scene:RoundScene) {
    super(scene);

    round.destroyPaddle();
  }

  override function update():Void {
    if (round.paddle.animation.over()) {
      if (round.lives > 1) {
        // Try again!
        scene.state = new RoundRestartState(scene);
      }
      else {
        // Game over!
        scene.state = new GameOverState(scene);
      }
    }
  }
}
