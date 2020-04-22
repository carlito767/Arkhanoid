package states;

import kha.graphics2.Graphics;
import kha.input.KeyCode;

import input.InputEventType;

class RoundPlayState extends State {
  public function new(game:Game) {
    super(game);

    // Input bindings
    game.input.bind(Key(Left),
      function(type:InputEventType) {
        game.round.paddle.moveLeft = true;
      },
      function(type:InputEventType) {
        game.round.paddle.moveLeft = false;
      }
    );
    game.input.bind(Key(Right),
      function(type:InputEventType) {
        game.round.paddle.moveRight = true;
      },
      function(type:InputEventType) {
        game.round.paddle.moveRight = false;
      }
    );
  }

  override function update():Void {
    game.round.update();
  }

  override function render(g2:Graphics):Void {
    game.round.render(g2);
  }
}
