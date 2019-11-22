import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_compass/flutter_compass.dart';

class Compass extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CompassState();
  }
}

class CompassState extends State<Compass> {
  double _direction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          new Container(
            alignment: Alignment.center,
            color: Colors.white,
            child: new Transform.rotate(
              angle: ((_direction ?? 0) * (math.pi / 180) * -1),
              child: new Image.asset('assets/compass.jpg'),
            ),
          ),
          RaisedButton(
            onPressed: () async {
              print('asdf');
              double d = await FlutterCompass.events.first;
              setState(() {
                print(d);
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    FlutterCompass.events.listen((double direction) {
      setState(() {
        _direction = direction;
      });
    });
  }

  @override
  void dispose() {
    
    super.dispose();
  }
}
