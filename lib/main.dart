import 'package:flutter/material.dart';

import 'loggin.dart';


void main() => runApp(MaterialApp(
  builder: (context, child) {
    // return MediaQuery(
    //   data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    //   child: child!,
    // );
    return LayoutBuilder(builder: (context, constraints) {
      return OrientationBuilder(builder: (context, orientation) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      });
    });
  },
  home: const Login(),
));
