import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Login extends StatefulWidget {
  final Function connect;
  final Function setLoginLoading;
  final bool loginLoading;
  final Function setCurrentContext;

  Login({
    this.connect,
    this.setLoginLoading,
    this.loginLoading,
    this.setCurrentContext
  });

  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State<Login> {
  String username;
  final _formKey = GlobalKey<FormState>();

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SmileySearch'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 200,
                  child: Image.asset('assets/treasure.png'),
                )
              ],
            ),
            SizedBox(
              height: 70,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  width: 300,
                  child: TextFormField(
                    validator: (value) {
                      print('Asdf');
                      if (value.isEmpty) {
                        return 'Insert a username';
                      } else if (value.length < 4) {
                        return 'Username length must be greater than 3';
                      }
                      return null;
                    },
                    onChanged: (value){
                      setState(() {
                        username = value;
                      });
                    },
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.redAccent, width: 1),
                            borderRadius: BorderRadius.circular(100)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.redAccent, width: 1),
                            borderRadius: BorderRadius.circular(100)),
                        border:  OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.redAccent, width: 1),
                            borderRadius: BorderRadius.circular(100)),
                        hintText: 'Username'),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                widget.loginLoading ? CircularProgressIndicator() : MaterialButton(
                  color: Colors.redAccent,
                  shape: StadiumBorder(),
                  minWidth: 300,
                  height: 50,
                  child: Text(
                    'Log in',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      widget.setCurrentContext(context);
                      widget.connect(username);
                      widget.setLoginLoading(true);
                    }
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
