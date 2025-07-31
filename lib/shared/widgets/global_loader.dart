import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class GlobalLoader extends StatelessWidget {
  const GlobalLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitWaveSpinner(
        color: Theme.of(context).primaryColor,
        size: 80.0,
        waveColor: Theme.of(context).primaryColor.withOpacity(0.5),
      ),
    );
  }
}
