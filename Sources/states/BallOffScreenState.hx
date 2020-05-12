package states;

using AnimationExtension;
import scenes.RoundScene;
using world.EntityExtension;

class BallOffScreenState extends RoundState {
  public function new(scene:RoundScene) {
    super(scene);

    paddle.animation = 'paddle_explode'.loadAnimation(4, -1);
  }

  override function update():Void {
    if (paddle.animation.over()) {
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
