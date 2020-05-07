class Random {
  // Generate 'n' random unique numbers between 'from' (included) and 'to' (excluded)
  public static function sample(n:Int, to:Int, ?from:Int = 0):Array<Int> {
    var r:Array<Int> = [];
    var v:Array<Int> = [for (i in from...to) i];
    while (r.length < n && v.length > 0) {
      var i = Std.random(v.length);
      r.push(v.splice(i, 1)[0]);
    }
    return r;
  }

  // Shuffle an array
  // https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
  public static function shuffle<T>(a:Array<T>):Void {
    for (i in 0...a.length) {
      var j = Std.random(i);
      var vi = a[i];
      a[i] = a[j];
      a[j] = vi;
    }
  }
}
