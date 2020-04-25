package states;

import kha.graphics2.Graphics;

import input.InputEventType;

class RoundPlayState extends State {
  public function new(game:Game) {
    super(game);

    // Input bindings
    game.input.bind(Key(Left),
      function(type:InputEventType) {
        game.round.moveLeft = true;
      },
      function(type:InputEventType) {
        game.round.moveLeft = false;
      }
    );
    game.input.bind(Key(Right),
      function(type:InputEventType) {
        game.round.moveRight = true;
      },
      function(type:InputEventType) {
        game.round.moveRight = false;
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
