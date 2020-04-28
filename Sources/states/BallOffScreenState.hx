package states;

import kha.graphics2.Graphics;

using AnimationExtension;

class BallOffScreenState extends State {
  public function new(game:Game) {
    super(game);

    // Don't move...
    game.input.clearBindings();
    game.round.moveLeft = false;
    game.round.moveRight = false;
    // ...my deadly love!
    game.round.paddle.animation = 'paddle_explode'.loadAnimation(4, -1);
  }

  override function update():Void {
    game.round.update();

    if (game.round.paddle.animation == null) {
      game.round.lives--;
      if (game.round.lives > 0) {
        game.round.paddle = null;
        game.state = new GameStartState(game);
      }
      else {
        game.backToTitle();
      }
    }
  }

  override function render(g2:Graphics):Void {
    game.round.render(g2);
  }
}
