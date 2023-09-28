import 'dart:math';

class TrilaterationCalculatorVectormode{

  double vectorDotFunc(var V1, var V2) {
    //perform vector dot product of a given three dimensional vector
    var x = V1[0] * V2[0] + V1[1] * V2[1] + V1[2] * V2[2];
    return x;
  }

  double vectorNormFunc(var V) {
    //Normalize a given three dimensional vector
    var x = sqrt(V[0] * V[0] + V[1] * V[1] + V[2] * V[2]);
    return x;
  }

  List vectorCrossFunc(var V1, var V2) {
    //perform vector cross product of a given three dimensional vector
    final List result = [];
    result.add(V1[1] * V2[2] - V1[2] * V2[1]);
    result.add(V1[2] * V2[0] - V1[0] * V2[2]);
    result.add(V1[0] * V2[1] - V1[1] * V2[0]);
    return result;
  }

  List vectorSubtractFunc(var V2, var V1) {
    //perform vector subtraction of given three three dimensional vectors
    final List result = [];
    result.add(V2[0] - V1[0]);
    result.add(V2[1] - V1[1]);
    result.add(V2[2] - V1[2]);
    return result;
  }

  List vectorAddFunc(var V1, var V2) {
    ////perform vector addition of given three three dimensional vectors
    final List result = [];
    result.add(V2[0] + V1[0]);
    result.add(V2[1] + V1[1]);
    result.add(V2[2] + V1[2]);
    return result;
  }

  List vectorDivbyElementFunc(var V, var c) {
    ////perform element by division of a given vector by given constant
    final List result = [];
    result.add(V[0] / c);
    result.add(V[1] / c);
    result.add(V[2] / c);
    return result;
  }

  List vectorMulbyElementFunc(var V, var c) {
    //perform element by multiplication of a given vector by given constant
    final List result = [];
    result.add(V[0] * c);
    result.add(V[1] * c);
    result.add(V[2] * c);
    return result;
  }


  List trilateration(var P1, var P2, var P3, var r1, var r2, var r3, var x_max, var y_max, z_max) {
    final List lis = [];

    final p1 = List<double>.filled(3, 0);
    List p2 = [P2[0] - P1[0], P2[1] - P1[1], P2[2] - P1[2]];
    List p3 = [P3[0] - P1[0], P3[1] - P1[1], P3[2] - P1[2]];
    var v1 = vectorSubtractFunc(p2, p1);
    var v2 = vectorSubtractFunc(p3, p1);

    var magV1 = vectorNormFunc(v1);
    var Xn = vectorDivbyElementFunc(v1, magV1);
    var tmp = vectorCrossFunc(v1, v2);

    var magTmp = vectorNormFunc(tmp);
    var Zn = vectorDivbyElementFunc(tmp, magTmp);

    var Yn = vectorCrossFunc(Xn, Zn);
    var i = vectorDotFunc(Xn, v2);
    var d = vectorDotFunc(Xn, v1);
    var j = vectorDotFunc(Yn, v2);

    var X = ((r1 * r1) - (r2 * r2) + (d * d)) / (2 * d);
    var Y = (((r1 * r1) - (r3 * r3) + (i * i) + (j * j)) / (2 * j)) -
        ((i / j) * (X));
    var Z1 = sqrt(max(0, (r1 * r1) - (X * X) - (Y * Y)));
    var Z2 = -1 * Z1;
    var K1 = vectorAddFunc(P1, vectorAddFunc(vectorMulbyElementFunc(Xn, X),
        vectorAddFunc(
            vectorMulbyElementFunc(Yn, Y), vectorMulbyElementFunc(Zn, Z1))));
    var K2 = vectorAddFunc(p1, vectorAddFunc(vectorMulbyElementFunc(Xn, X),
        vectorSubtractFunc(
            vectorMulbyElementFunc(Yn, Y), vectorMulbyElementFunc(Zn, Z2))));
    //lis.add(K1);
    //lis.add(K2);
    var K = K1;

    if (-5 <= K1[0] && K1[0]< x_max+5 && -5 <= K1[1] && K1[1] < y_max+5 && -5 <= K1[2] && K1[2] < z_max+5) {
      if (-5 <= K2[0] && K2[0] < x_max + 5 && -5 <= K2[1] && K2[1]< y_max + 5 && -5 <= K2[2] && K2[2] < z_max + 5) {
        K = [(K1[0] + K2[0]) / 2, (K1[1] + K2[1]) / 2, (K1[2] + K2[2]) / 2];
      }
    }
    else if (-5 <= K2[0] && K2[0] < x_max+5 && -5 <= K2[1] && K2[1] < y_max+10 && -5 <= K2[2] && K2[2] < z_max+5) {
      K = K2;
    }
    else {
      K = [];
    }
    lis.add(K);
    return lis;
  }

  //With those cordinates and distances P1=(2,2,0), P2=(3,3,0), P3=(1,4,0) r1=1, r2=1, r3=1.4142, it shoudl return P=(2,3,0).
  List GetCoordinates(var Vec1, var Vec2, var Vec3, var r1, var r2, var r3, var maxX, var maxY, var maxZ) {
    //list
    // var Vec1 = [2, 2, 0];
    // var Vec2 = [3, 3, 0];
    // var Vec3 = [1, 4, 0];
    // var r1 = 1;
    // var r2 = 1;
    // var r3 = 1.4142;
    //call
    List coordinate = trilateration(Vec1, Vec2, Vec3, r1-30, r2-30, r3-30, maxX, maxY, maxZ);
    print("Print from calculator 888888888888888888888888888888888888888888888888");
    print(coordinate);
    return coordinate;
  }
}