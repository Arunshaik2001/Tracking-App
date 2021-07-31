import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:toast/toast.dart';
import 'package:tracking_app/services/AuthenticationService.dart';
import 'package:provider/provider.dart';
import 'package:tracking_app/presentations/animations/FlipperWidget.dart';
import 'package:tracking_app/common/GlobalVariables.dart';
import 'package:tracking_app/presentations/screens/MyJoinedCircles.dart';
import 'package:tracking_app/presentations/maps/maps.dart';
import 'package:tracking_app/presentations/screens/sign_in.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  LocationData _locationData;
  String _secretcode = "";
  TextEditingController _codeController = TextEditingController();
  User user;

  void getCurrentLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.DENIED) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.GRANTED) {
        return;
      }
    }

    _locationData = await location.getLocation();
    print(
        "${_locationData.longitude} ${_locationData.latitude} LAAAAAAAAAAAAAAAAAAAAAAAAT");

    joinCircle(_locationData, _secretcode.trim());

    setState(() {});
  }

  void addOrFetchSecretCode() async {
    final _registeredCollection =
        FirebaseFirestore.instance.collection("registeredUsers");
    final user =
        await context.read<AuthenticationService>().authStateChanges.first;
    if (GlobalVariables.secretCode != null) {
      await _registeredCollection.doc(user.uid.trim()).set(
          {"code": GlobalVariables.secretCode, "name": GlobalVariables.name});
      _secretcode = GlobalVariables.secretCode;
      //storeCircleCode(this._locationData);
    } else {
      print("${user.uid} UIIIIIIIIIIIIIIIIIIIIIID");

      await _registeredCollection
          .doc(user.uid.trim())
          .get()
          .then((value) => {_secretcode = value.get("code")});
      print("${_secretcode} kkkkkkkkkkkkkkkkkkkkkkkkkkk");
    }

    setState(() {});
  }

  // void storeCircleCode(LocationData _locationData) async {
  //   CollectionReference circleReference =
  //       FirebaseFirestore.instance.collection("circles");
  //   final user =
  //       await context.read<AuthenticationService>().authStateChanges.first;
  //   await circleReference.doc(_secretcode).set({
  //     user.uid: {
  //       "location": GeoPoint(_locationData.latitude, _locationData.longitude),
  //       "name": GlobalVariables.name
  //     }
  //   });
  // }

  void joinCircle(LocationData _locationData, String codeToJoin) async {
    if (codeToJoin == _secretcode.trim()) {
      Toast.show("It is Your Code Only", context);
      return;
    }
    CollectionReference circleReference =
        FirebaseFirestore.instance.collection("circles");
    CollectionReference registeredUserReference =
        FirebaseFirestore.instance.collection("registeredUsers");

    user = await context.read<AuthenticationService>().authStateChanges.first;
    QueryDocumentSnapshot docs;
    String nameOfUser = "";
    await registeredUserReference
        .get()
        .then((value) => {
              docs = value.docs.firstWhere((element) {
                return element.id.trim() == user.uid.trim();
              }),
              nameOfUser = docs.get("name")
            })
        .catchError((error) => {Toast.show(error.toString(), context)});

    print("${nameOfUser} NAME");
    QueryDocumentSnapshot codeDoc;
    await circleReference
        .get()
        .then((value) => {
              codeDoc = value.docs.firstWhere((element) {
                return element.id.trim() == codeToJoin.trim();
              }),
              if (codeDoc == null)
                Toast.show("Not There Or U Entered Wrong Code", context)
              else
                {
                  print("${codeDoc.id} IDDDDDEEEEEEEEEEEEEEEE"),
                  codeDoc.reference.update({
                    user.uid: {
                      "location": GeoPoint(
                          _locationData.latitude, _locationData.longitude),
                      "name": nameOfUser
                    }
                  }),
                  Toast.show("added", context)
                }
            })
        .catchError((error) => {Toast.show(error.toString(), context)});
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    getCurrentLocation();
    addOrFetchSecretCode();

    //storeCircleCode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
              backgroundColor: Colors.blue),
          BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: "Circles",
              backgroundColor: Colors.blue)
        ],
        onTap: (index) {
          if (index != 0) {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => JoinedCircles(_secretcode)));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(Icons.navigation),
        onPressed: () async{
          final user=await context.read<AuthenticationService>().authStateChanges.first;
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => Maps(
                    title: "My Circle",
                    secretCode: user.uid,
                  )));
        },
      ),
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                padding: const EdgeInsets.all(10.0),
                width: 150.0,
                child: TextField(
                  controller: _codeController,
                  textAlign: TextAlign.center,
                )),
            RaisedButton(
              color: Colors.amber,
              textColor: Colors.white,
              onPressed: () {
                joinCircle(_locationData, _codeController.text.trim());
              },
              elevation: 3.0,
              child: Text("Join Circle"),
            ),
            Container(
                height: 250.0,
                child: FlipperWidget(_secretcode != null ? _secretcode : "")),
            RaisedButton(
              onPressed: () async {
                context.read<AuthenticationService>().signOut();
              },
              child: Text("Sign out"),
            ),
          ],
        ),
      )),
    );
  }
}
