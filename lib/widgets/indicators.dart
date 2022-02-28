import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';

Center circularProgress(context) {
  return Center(
    child: Container(
      color: Colors.black,
      child: SpinKitFadingCircle(
        size: 40.0,
        color: Colors.white,
      ),
    ),
  );
}

Container linearProgress(context) {
  return Container(
    color: Colors.black,
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Theme.of(context).accentColor),
    ),
  );
}
