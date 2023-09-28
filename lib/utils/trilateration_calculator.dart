import 'dart:math';

class TrilaterationCalculator {
  final double W;
  final double L;
  double r1;
  final double r2;
  final double r3;

  TrilaterationCalculator({
    required this.W,
    required this.L,
    required this.r1,
    required this.r2,
    required this.r3,
  });

  List<double> calculateCoordinates() {
    double x = (r1 * r1 - r2 * r2 + W * W) / (2 * W);
    double y = (r1 * r1 - r3 * r3 + L * L) / (2 * L);
    if(x>W){x=W;}if(x<0){x=0;}if(y>L){y=W;}if(y<0){y=0;}
    double temp = sqrt((x*x) + (y*y));
    if(r1<temp){r1=temp+1;}
    double zSquared = (r1 * r1) - (x * x + y * y);
    double z = sqrt(zSquared);

    String t = x.toStringAsFixed(2);
    x = double.parse(t);
    t = y.toStringAsFixed(2);
    y = double.parse(t);
    t = z.toStringAsFixed(2);
    z = double.parse(t);
    print("X = $x  Y = $y  Z = $z");
    return [x, y, z];
  }
}
