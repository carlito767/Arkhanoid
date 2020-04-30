import kha.System;

class Graphics2Extension {
  public static function centerString(g2:kha.graphics2.Graphics, s:String, y:Float, dx:Float = 0):Void {
    var w = g2.font.width(g2.fontSize, s);
    var x = (System.windowWidth() - w) * 0.5;
    g2.drawString(s, x + dx, y);
  }

  public static function rightString(g2:kha.graphics2.Graphics, s:String, right:Float, y:Float):Void {
    var w = g2.font.width(g2.fontSize, s);
    g2.drawString(s, right - w, y);
  }
}
