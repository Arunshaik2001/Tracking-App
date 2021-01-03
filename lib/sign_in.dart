import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math' as Math;
import 'package:toast/toast.dart';
import 'package:tracking_app/AuthenticationService.dart';
import 'package:tracking_app/GlobalVariables.dart';
import 'fade_animations.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _passWordNode = FocusNode();
  final _nameNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  var signInOrUp = "LogIn";
  Map<String, String> _map = {"email": null, "password": null ,"name":null};

  @override
  void dispose() {
    // TODO: implement dispose
    _passWordNode.dispose();
    _nameNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/background.png'),
                          fit: BoxFit.fill)),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        left: 30,
                        width: 80,
                        height: 200,
                        child: FadeAnimation(
                            1,
                            Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage('assets/light-1.png'))),
                            )),
                      ),
                      Positioned(
                        left: 140,
                        width: 80,
                        height: 150,
                        child: FadeAnimation(
                            1.3,
                            Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage('assets/light-2.png'))),
                            )),
                      ),
                      Positioned(
                        right: 40,
                        top: 40,
                        width: 80,
                        height: 150,
                        child: FadeAnimation(
                            1.5,
                            Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage('assets/clock.png'))),
                            )),
                      ),
                      Positioned(
                        child: FadeAnimation(
                            1.6,
                            Container(
                              margin: EdgeInsets.only(top: 50),
                              child: Center(
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Column(
                    children: <Widget>[
                      FadeAnimation(
                          1.8,
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                      color: Color.fromRGBO(143, 148, 251, .2),
                                      blurRadius: 20.0,
                                      offset: Offset(0, 10))
                                ]),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey[100]))),
                                    child: TextFormField(

                                      onSaved: (value) {
                                        _map["email"] = value;
                                      },
                                      onFieldSubmitted: (_) {
                                        FocusScope.of(context)
                                            .requestFocus(_passWordNode);
                                      },
                                      validator: (value) {
                                        return !RegExp(
                                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                                .hasMatch(value)
                                            ? "Type Email Properly"
                                            : null;
                                      },
                                      textInputAction: TextInputAction.next,
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Email",
                                          hintStyle: TextStyle(
                                              color: Colors.grey[400])),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      onSaved: (value) {
                                        _map["password"] = value;
                                      },
                                      validator: (value) {
                                        if (!RegExp(
                                                r"^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$")
                                            .hasMatch(value))
                                          return "Minimum eight characters, at least one letter and one number";
                                        return null;
                                      },
                                      onFieldSubmitted: (_)=>{
                                        FocusScope.of(context).requestFocus(_nameNode)
                                      },
                                      focusNode: _passWordNode,
                                      textInputAction: TextInputAction.next,
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Password",
                                          hintStyle: TextStyle(
                                              color: Colors.grey[400])),
                                    ),
                                  ),
                                  if(signInOrUp=="SignUp")Container(
                                    padding: EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      onSaved: (value) {
                                        _map["name"] = value;
                                      },
                                      validator: (value) {
                                        if (!RegExp(
                                            r"^[A-Za-z]{2,}")
                                            .hasMatch(value))
                                          return "Name is short";
                                        return null;
                                      },
                                      focusNode: _nameNode,
                                      textInputAction: TextInputAction.done,
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Name",
                                          hintStyle: TextStyle(
                                              color: Colors.grey[400])),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )),
                      SizedBox(
                        height: 30,
                      ),
                      FadeAnimation(
                          2,
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(colors: [
                                  Color.fromRGBO(143, 148, 251, 1),
                                  Color.fromRGBO(143, 148, 251, .6),
                                ])),
                            child: Center(
                              heightFactor: 5,
                              child: GestureDetector(
                                  onTap: () => {login(context)},
                                  child: Text(
                                    signInOrUp,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ),
                          )),
                      SizedBox(
                        height: 70,
                      ),
                      FadeAnimation(
                          1.5,
                          GestureDetector(
                            onTap: () {
                              if (signInOrUp == "LogIn")
                                signInOrUp = "SignUp";
                              else
                                signInOrUp = "LogIn";
                              setState(() {});
                            },
                            child: Text(
                              (signInOrUp == "LogIn") ? "SignUp?" : "LogIn?",
                              style: TextStyle(
                                  color: Color.fromRGBO(143, 148, 251, 1)),
                            ),
                          )),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  void login(BuildContext ctx) async {
    bool validate = _formKey.currentState.validate();
    if (validate) {
      _formKey.currentState.save();
      final authService = ctx.read<AuthenticationService>();
      if (signInOrUp == "LogIn")
        authService.signIn(
            email: _map["email"].trim(), password: _map["password"].trim());
      else{
        var msg1=await authService.signUp(
            email: _map["email"].trim(), password: _map["password"].trim());
        if(msg1.substring(0,2)=="11")
            msg1=msg1.split("]")[1];
        int _secretCode=1000000+Math.Random().nextInt(99999);



        // bool result=await FirebaseDatabase(FirebaseFirestore.instance).addDocumentToRegisteredUser(nameOfDoc:user.uid,keyValuePair:{
        //   "code":_secretCode,
        //   "name":_map["name"]
        // });

        GlobalVariables.secretCode=_secretCode.toString();

        GlobalVariables.name=_map["name"];
        Toast.show("${msg1} ", ctx, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
  }
    }
  }
}
