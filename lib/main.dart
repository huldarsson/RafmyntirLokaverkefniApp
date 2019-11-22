import 'package:flutter/material.dart';
import './Pages/compass.dart';
import './Pages/login.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'dart:math' as math;


void main() => runApp(MyApp());

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

  void setUsername(String name) {
    setState(() {
      username = name;
    });
  }

  void setSocket(SocketIO socket){
    setState(() {
      socketIO = socket;
    });
  }

  void connect(String myUsername) async {
    print(myUsername);
    setUsername(myUsername);
    SocketIO socket = await manager.createInstance(SocketOptions("https://rafmyntir.herokuapp.com", query: {"username": myUsername}, enableLogging: true));
    socket.onConnect((data){
      print('connected');
    });
    socket.connect();
    setSocket(socket);
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
        connect: connect
      ),
      routes: {'/compass': (context) => Compass()},
    );
  }


  @override
  void initState() {
    super.initState();
    manager = SocketIOManager();
  }

  @override
  void dispose() {
    manager.clearInstance(socketIO);
    super.dispose();
  }
}
