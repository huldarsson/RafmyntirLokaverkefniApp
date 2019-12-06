import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_compass/flutter_compass.dart';
// import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';

class Compass extends StatefulWidget {
  final Function showMessage;
  final Function setCurrentContext;
  final Function requestDirections;
  final Function dig;

  final bool directionLoading;
  final bool digLoading;
  final Function setDirectionLoading;
  final Function setDigLoading;

  final String currentDirection;
  final String currentDistance;

  Compass(
      {this.showMessage,
      this.setCurrentContext,
      this.requestDirections,
      this.directionLoading,
      this.setDirectionLoading,
      this.currentDirection,
      this.currentDistance,
      this.dig,
      this.digLoading,
      this.setDigLoading});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CompassState();
  }
}

class CompassState extends State<Compass> {
  double _direction;
  // LocationData currentLocation;

  // var location = Location();
  Geolocator geolocator = Geolocator();
  Position currentPosition;

  var stream;

  void getDirections() async {
    try {
      widget.setDirectionLoading(true);
      _getLocation().then((value) {
        widget.requestDirections(value.latitude, value.longitude);
        setState(() {
          currentPosition = value;
        });
      });
    } catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        widget.showMessage(
            context, 'Location permission denied', 'Permission error');
      }
      setState(() {
        currentPosition = null;
      });
      widget.setDirectionLoading(false);
    }
  }

  void dig() async {
    try {
      widget.setDigLoading(true);
      _getLocation().then((value) {
        widget.dig(value.latitude, value.longitude);
        setState(() {
          currentPosition = value;
        });
      });
    } catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        widget.showMessage(
            context, 'Location permission denied', 'Permission error');
      }
      setState(() {
        currentPosition = null;
      });
      widget.setDigLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Container(
              alignment: Alignment.center,
              color: Colors.white,
              child: new Transform.rotate(
                angle: ((_direction ?? 0) * (math.pi / 180) * -1),
                child: new Image.asset('assets/compass.jpg'),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                widget.directionLoading
                    ? Container(
                        alignment: Alignment.center,
                        width: 100,
                        child: CircularProgressIndicator(),
                      )
                    : MaterialButton(
                        height: 50,
                        shape: StadiumBorder(),
                        color: Colors.redAccent,
                        child: Text(
                          'Directions',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        onPressed: getDirections,
                      ),
                widget.digLoading
                    ? Container(
                        alignment: Alignment.center,
                        width: 100,
                        child: CircularProgressIndicator(),
                      )
                    : MaterialButton(
                        height: 50,
                        child: Text(
                          'Dig',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        color: Colors.redAccent,
                        shape: StadiumBorder(),
                        onPressed: dig,
                      )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    widget.currentDirection != null
                        ? Text(
                            '${widget.currentDirection}',
                            style: TextStyle(
                                fontSize: 24, color: Colors.redAccent),
                          )
                        : Text(''),
                    widget.currentDistance != null
                        ? Text(
                            '${widget.currentDistance} m',
                            style: TextStyle(
                                fontSize: 24, color: Colors.redAccent),
                          )
                        : Text('')
                  ],
                ),
                // currentPosition != null
                //     ? SelectableText(
                //         '${currentPosition.latitude},${currentPosition.longitude}')
                //     : Text('null')
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<Position> _getLocation() async {
    var currentLocation;
    try {
      currentLocation = await geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

  @override
  void initState() {
    super.initState();
    //widget.setCurrentContext(context);
    _getLocation().then((position) {
      currentPosition = position;
    });
    widget.setCurrentContext(context);
    stream = FlutterCompass.events.listen((double direction) {
      setState(() {
        _direction = direction;
      });
    });
  }

  @override
  void dispose() {
    stream.cancel();
    super.dispose();
  }
}
