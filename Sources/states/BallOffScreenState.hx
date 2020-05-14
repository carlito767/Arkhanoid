package states;

using AnimationExtension;
import scenes.RoundScene;
using world.EntityExtension;

class BallOffScreenState extends RoundState {
  public function new(scene:RoundScene) {
    super(scene);

    paddle.pendingAnimations = ['paddle_explode'.loadAnimation(4, -1)];
    if (paddle.animation.cycle >= 0) {
      paddle.animation = paddle.pendingAnimations.shift();
    }
  }

  override function update():Void {
    if (paddle.pendingAnimations.isEmpty() && paddle.animation.over()) {
      paddle.reset();
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
