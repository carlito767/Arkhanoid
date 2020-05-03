class MathExtension {
  public static inline function toRadians(degrees:Float):Float {
    return degrees * (Math.PI / 180);
  }

  public static inline function toDegrees(radians:Float):Float {
    return radians * (180 / Math.PI);
  }
}
