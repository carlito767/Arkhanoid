package states;

import scenes.RoundScene;
using AnimationExtension;

class BallOffScreenState extends RoundState {
  public function new(scene:RoundScene) {
    super(scene);

    // Don't move...
    scene.freezePaddle = true;
    // ...my deadly love!
    scene.paddle.animation = 'paddle_explode'.loadAnimation(4, -1);
  }

  override function update():Void {
    if (scene.paddle.animation.over()) {
      if (scene.lives > 1) {
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
