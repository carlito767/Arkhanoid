import kha.System;

class Main {
  public static function main() {
    System.start({ title:TITLE, width:WIDTH, height:HEIGHT, framebuffer:{ samplesPerPixel:4 } }, function(_) {
      new Game();
    });
  }
}
