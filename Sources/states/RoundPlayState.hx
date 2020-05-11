package states;

import scenes.RoundScene;

class RoundPlayState extends RoundState {
  public function new(scene:RoundScene) {
    super(scene);
  }

  override function update():Void {
    if (win()) {
      // You win!
      scene.state = new RoundEndState(scene);
    }
    else if (lose()) {
      // You lose!
      scene.state = new BallOffScreenState(scene);
    }
  }

  //
  // Win/Lose conditions
  //

  function win():Bool {
    for (brick in world.all(Brick)) {
      if (brick.value > 0) return false;
    }
    return true;
  }

  function lose():Bool {
    return world.all(Ball).isEmpty();
  }
}
