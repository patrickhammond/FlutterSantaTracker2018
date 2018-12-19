import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Santa Tracker',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Santa Tracker'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: SantaTrackerWidget());
  }
}

class SantaTrackerWidget extends StatefulWidget {
  @override
  State createState() => _SantaTrackerWidgetState();
}

class _SantaTrackerWidgetState extends State<SantaTrackerWidget> {
  ValueNotifier _location = ValueNotifier(Location(39.3332326, -84.3145426, 19, 'Mason, OH'));

  StreamSubscription<Event> _locationSubscription;

  @override
  void initState() {
    super.initState();

    final firebase = FirebaseDatabase.instance;
    final currentLocationRef = firebase.reference().child('current_location');
    _locationSubscription = currentLocationRef.onValue.listen((event) {
      final value = event.snapshot.value;
      final lat = value['lat'];
      final lng = value['lng'];
      final bestZoom = value['bestZoom'].toDouble();
      final city = value['city'];
      _location.value = Location(lat, lng, bestZoom, city);
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SantaTrackerInheritedWidget(
        location: _location,
        child: Stack(children: <Widget>[
          SantaMapWidget(),
          Align(
            child: Padding(
              child: Material(
                child: SizedBox(
                    height: 48.0,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: ValueListenableBuilder(
                          valueListenable: _location,
                          builder: (context, location, child) {
                            return Text(location.city,
                                style: Theme.of(context).textTheme.body2);
                          }),
                    )),
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusDirectional.horizontal(
                        start: Radius.circular(24.0),
                        end: Radius.circular(24.0))),
              ),
              padding: EdgeInsets.only(bottom: 16.0),
            ),
            alignment: Alignment.bottomCenter,
          )
        ]));
  }
}

// You can think of an inherited widget as just a way of sharing state across
// a widget tree.
class SantaTrackerInheritedWidget extends InheritedWidget {
  final ValueNotifier location;

  SantaTrackerInheritedWidget(
      {Key key, @required this.location, @required Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(SantaTrackerInheritedWidget oldWidget) {
    return location.value != oldWidget.location.value;
  }

  static SantaTrackerInheritedWidget of(BuildContext context) {
    return context.ancestorWidgetOfExactType(SantaTrackerInheritedWidget);
  }
}

class SantaMapWidget extends StatefulWidget {
  @override
  _SantaMapWidgetState createState() => _SantaMapWidgetState();
}

class _SantaMapWidgetState extends State<SantaMapWidget> {
  ValueNotifier _location;
  GoogleMapController _controller;

  @override
  Widget build(BuildContext context) {
    _location = SantaTrackerInheritedWidget.of(context).location;

    return GoogleMap(onMapCreated: _onMapCreated);
  }

  @override
  void dispose() {
    _location.removeListener(_locationChanged);
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller = controller;

      _pinLocation(_location.value);
      _location.addListener(_locationChanged);
    });
  }

  void _locationChanged() {
    _pinLocation(_location.value);
  }

  void _pinLocation(Location location) {
    var latLng = LatLng(location.lat, location.lng);

    _controller?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: latLng,
        tilt: 35.0,
        zoom: location.zoom,
      ),
    ));

    _controller.clearMarkers();
    _controller.addMarker(MarkerOptions(
        position: latLng,
        icon: BitmapDescriptor.fromAsset("assets/santa.png")));
  }
}

class Location {
  final double lat;
  final double lng;
  final double zoom;
  final String city;

  Location(this.lat, this.lng, this.zoom, this.city);

  // IDE generated
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Location &&
          runtimeType == other.runtimeType &&
          lat == other.lat &&
          lng == other.lng &&
          zoom == other.zoom &&
          city == other.city;

  // IDE generated
  @override
  int get hashCode =>
      lat.hashCode ^ lng.hashCode ^ zoom.hashCode ^ city.hashCode;
}
