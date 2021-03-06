import haxe.macro.Compiler;

import kha.Assets;
import kha.Color;
import kha.Framebuffer;
import kha.System;

class Main {
  public static function main() {
    System.start({title:title(), width:Game.WIDTH, height:Game.HEIGHT}, (_)->{
      System.notifyOnFrames(renderLoadingScreen);
      Assets.loadEverything(()->{
        System.removeFramesListener(renderLoadingScreen);
        new Game();
      });
    });
  }

  static function renderLoadingScreen(framebuffers:Array<Framebuffer>):Void {
    var g2 = framebuffers[0].g2;
    g2.begin();
    var width = Assets.progress * System.windowWidth();
    var height = System.windowHeight() * 0.02;
    var y = (System.windowHeight() - height) * 0.5;
    g2.color = Color.White;
    g2.fillRect(0, y, width, height);
    g2.end();
  }

  static function title():String {
    return Compiler.getDefine('kha_project_name');
  }
}
