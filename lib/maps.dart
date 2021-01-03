import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:tracking_app/AuthenticationService.dart';

class Maps extends StatefulWidget {
  final String secretCode;

  Maps({Key key, this.title, this.secretCode}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Maps> {
  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  GoogleMapController _controller;
  List<GeoPoint> _geoPointsList = new List();
  List<String> _namesList = new List();
  List<Marker> markersList = new List();

  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Future<Uint8List> getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/car_icon.png");
    return byteData.buffer.asUint8List();
  }

  Stream<DocumentSnapshot> provideDocumentFieldStream() {
    return FirebaseFirestore.instance
        .collection('circles')
        .document(widget.secretCode.trim())
        .snapshots();
  }



  void updateMarkerAndCircle(
      LocationData newLocalData, Uint8List imageData) async {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    DocumentReference circleDocReference = FirebaseFirestore.instance
        .collection("circles")
        .doc(widget.secretCode.trim());
    final user =
        await context.read<AuthenticationService>().authStateChanges.first;
    List<GeoPoint> loactionsList = new List<GeoPoint>();
    List<String> namesList = new List<String>();



    await circleDocReference
        .get()
        .then((value) => {

              loactionsList.add(value["location".trim()] as GeoPoint),
              namesList.add(value["name".trim()])
            })
        .whenComplete(() => {
              _geoPointsList.addAll(loactionsList),
              _namesList.addAll(namesList),
              for (int i = 0; i < _geoPointsList.length; i++)
                {
                  markersList.add(Marker(
                      markerId: MarkerId(_namesList[i]),
                      position: new LatLng(_geoPointsList[i].latitude,
                          _geoPointsList[i].longitude),
                      draggable: false,

                  )
                  )
                }
            });

    this.setState(() {

    });
  }

  void getCurrentLocation() async {
    try {
      Uint8List imageData = await getMarker();
      var location = await _locationTracker.getLocation();

      updateMarkerAndCircle(location, imageData);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged().listen((newLocalData) {
        if (_controller != null) {
          _controller.animateCamera(CameraUpdate.newCameraPosition(
              new CameraPosition(

                  target: LatLng(newLocalData.latitude, newLocalData.longitude),
                  tilt: 0,
                  zoom: 14)));
          updateMarkerAndCircle(newLocalData, imageData);
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: initialLocation,
        markers: Set.of((markersList != null) ? [...markersList] : []),
        //circles: Set.of((circle != null) ? [circle] : []),
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
          getCurrentLocation();
        },
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.location_searching),
          onPressed: () {

          }),
    );
  }
}
