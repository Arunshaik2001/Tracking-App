import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tracking_app/AuthenticationService.dart';
import 'package:provider/provider.dart';
import 'package:tracking_app/home_page.dart';

class JoinedCircles extends StatefulWidget {
  final String _secretCode;

  JoinedCircles(this._secretCode);

  @override
  _JoinedCirclesState createState() => _JoinedCirclesState();
}

class _JoinedCirclesState extends State<JoinedCircles> {
  final List<String> allCircles = List<String>();


  void joinCircle() async {
    final user =
        await context.read<AuthenticationService>().authStateChanges.first;
    CollectionReference circleReference =
        FirebaseFirestore.instance.collection("circles");
    final List<String> codes = new List<String>();
    QuerySnapshot querySnapshot = await circleReference.get();
    querySnapshot.docs.forEach((element) {

      element.reference.get().then((value) {
            String code=value.get(user.uid.trim()).toString() ;

            if (code != null && value.id.trim()!=widget._secretCode.trim())
              {
                codes.add(element.reference.id);

                setState(() {});
              }
          }).whenComplete(() => {allCircles.addAll(codes)});
    });


    //setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    joinCircle();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: allCircles.length > 0
            ? ListView.builder(
                itemCount: allCircles.length,
                itemBuilder: (_, index) {
                  return ListTile(
                    title: Text(allCircles[index]),
                  );
                },
              )
            : Center(child: Text("no circles joined")),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
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
            if (index != 1) {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => HomePage()));
            }
          },
        ),
        appBar: AppBar(
          title: Text("Your Circles"),
        ),
      ),
    );
  }
}
