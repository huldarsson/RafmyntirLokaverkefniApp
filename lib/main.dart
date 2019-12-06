import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './Pages/compass.dart';
import './Pages/login.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'dart:math' as math;

void main() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  String username;
  SocketIOManager manager;
  SocketIO socketIO;

  BuildContext currentContext;

  bool loginLoading = false;
  bool directionLoading = false;
  bool digLoading = false;

  String currentDirection;
  String currentDistance;

  String userAddress;

  void setDigLoading(loading) {
    setState(() {
      digLoading = loading;
    });
  }

  void setCurrentDirection(direction) {
    setState(() {
      currentDirection = direction;
    });
  }

  void setCurrentDistance(distance) {
    setState(() {
      currentDistance = distance;
    });
  }

  void setDirectionLoading(b) {
    setState(() {
      directionLoading = b;
    });
  }

  void setLoginLoading(bool b) {
    setState(() {
      loginLoading = b;
    });
  }

  void setCurrentContext(myContext) {
    currentContext = myContext;
  }

  void setUsername(String name) {
    setState(() {
      username = name;
    });
  }

  void setSocket(SocketIO socket) {
    setState(() {
      socketIO = socket;
    });
  }

  void requestDirections(lat, long) {
    socketIO.emit('requestDirections', [
      {"lat": lat, "long": long, "username": username}
    ]);
  }

  void dig(lat, long) {
    socketIO.emit('dig', [
      {"lat": lat, "long": long, "username": username}
    ]);
  }

  void connect(String myUsername) async {
    print(myUsername);
    setUsername(myUsername);
    SocketIO socket = await manager.createInstance(SocketOptions(
        "https://rafmyntir.herokuapp.com",
        query: {"username": myUsername},
        enableLogging: true));

    socket.onConnect((data) {
      print('connected');
    });

    socket.on('login', (data) {
      print('logged in');
      setLoginLoading(false);
      Navigator.pushNamedAndRemoveUntil(currentContext, '/compass', (_) {
        return false;
      });
    });

    socket.on('sendToAddress', (data) async {
      print(data);
      setDirectionLoading(false);
      String amount = data['amount'].toString();
      String address = data['address'].toString();

      await messageDialog(
          currentContext,
          'Send $amount smileys to $address to get directions to the nearest treasure',
          'Send Smileycoins');
    });

    socket.on('userConnected', (data) {
      messageDialog(
          currentContext,
          'This user is already connected. Try closing the app and try again',
          'Error');
      setLoginLoading(false);
    });

    socket.on('directionToNearest', (data) {
      print(data);
      setCurrentDirection(data['direction']);
      setCurrentDistance(data['distance'].toString());
    });

    socket.on('found', (data) async {
      String amount = data["amount"].toString();
      setDigLoading(false);
      await foundDialog(
          currentContext,
          'Congratulations! You have found ${amount} smileycoins. Insert the address of your wallet to recieve the treasure',
          'Treasure found!',
          data["amount"]);
    });

    socket.on('notFound', (data) {
      print('not found :(');
      messageDialog(currentContext, 'No treasure here :( Try again', '404');
      setDigLoading(false);
    });

    socket.connect();
    setSocket(socket);
  }

  Future messageDialog(myContext, message, title) async {
    await showDialog(
      context: currentContext,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SelectableText(message),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  Future foundDialog(myContext, message, title, amount) async {
    await showDialog(
        barrierDismissible: false,
        context: currentContext,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message),
                  Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        width: 250,
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              userAddress = value;
                            });
                          },
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.redAccent, width: 1),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              hintText: 'Address'),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(myContext);
                },
              ),
              FlatButton(
                child: Text('Submit'),
                onPressed: () {
                  socketIO.emit('requestPayment', [
                    {"address": userAddress, "amount": amount}
                  ]);
                  Navigator.pop(currentContext);
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.red,
      ),
      home: Login(
        connect: connect,
        setLoginLoading: setLoginLoading,
        loginLoading: loginLoading,
        setCurrentContext: setCurrentContext,
      ),
      routes: {
        '/compass': (context) => Compass(
              showMessage: messageDialog,
              setCurrentContext: setCurrentContext,
              requestDirections: requestDirections,
              setDirectionLoading: setDirectionLoading,
              directionLoading: directionLoading,
              currentDirection: currentDirection,
              currentDistance: currentDistance,
              dig: dig,
              digLoading: digLoading,
              setDigLoading: setDigLoading,
            )
      },
    );
  }

  @override
  void initState() {
    super.initState();
    manager = SocketIOManager();
  }

  @override
  void dispose() {
    socketIO.emit('disconnectUser', [
      {"username": username}
    ]);
    manager.clearInstance(socketIO);
    super.dispose();
  }
}
