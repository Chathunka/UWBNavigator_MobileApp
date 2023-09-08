import 'dart:math';

class TrilaterationCalculator {
  final double W;
  final double H;
  final double r1;
  final double r2;
  final double r3;

  TrilaterationCalculator({
    required this.W,
    required this.H,
    required this.r1,
    required this.r2,
    required this.r3,
  });

  List<double> calculateCoordinates() {
    double x = (W * W - r1 * r1 + r2 * r2) / (2 * W);
    double y = (H * H - r2 * r2 + r3 * r3) / (2 * H);
    double zSquared = r2 * r2 - x * x - y * y;
    double z = sqrt(zSquared);

    return [x, y, z];
  }
}
