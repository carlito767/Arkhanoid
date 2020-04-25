package states;

import kha.graphics2.Graphics;

class RoundPlayState extends State {
  public function new(game:Game) {
    super(game);

    // Input bindings
    game.input.bind(Key(Left),
      (_)->{
        game.round.moveLeft = true;
      },
      (_)->{
        game.round.moveLeft = false;
      }
    );
    game.input.bind(Key(Right),
      (_)->{
        game.round.moveRight = true;
      },
      (_)->{
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
