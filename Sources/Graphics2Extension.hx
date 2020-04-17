import kha.FastFloat;
import kha.System;

class Graphics2Extension {
  public static function centerString(g2:kha.graphics2.Graphics, s:String, y:FastFloat, dx:FastFloat = 0.0):Void {
    var w = g2.font.width(g2.fontSize, s);
    var x = (System.windowWidth() - w) / 2;
    g2.drawString(s, x + dx, y);
  }
}
