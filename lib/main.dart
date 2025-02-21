import 'dart:convert';
import 'dart:core';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';


final firebaseApp = Firebase.app();



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  String Lati = '15';
  String Longi = '10';
  double lat = 3.0;
  double long = 5.0;
  final dbRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    activateListeners();
  }



  void activateListeners() {
    dbRef
        .child("Location")
        .onValue
        .listen((event) {
      var data = Map<String, dynamic>.from(event.snapshot.value as Map<dynamic, dynamic>);
      final double latitude = data['Latitude'] as double;
      final double longitude = data['Longitude'] as double;


      setState(() {
        Lati = '$latitude';
        Longi = '$longitude';
        lat = latitude;
        long = longitude;

      });
    });
  }

  final currentloc = LatLng(-6.3, 107.1);

  final List<Marker> _markers = <Marker>[
    Marker(markerId: MarkerId('CheapTags'),position: LatLng(-6.3, 107.1))
  ];


  Future<Position> getUserCurrentLocation() async{

    await Geolocator.requestPermission().then((value){

    }).onError((error, stackTrace) {
      print("error"+error.toString());
    });

    return await Geolocator.getCurrentPosition();
  }

  late GoogleMapController mapController;


  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
  void _navigateToNextScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => _HomeScreen()));
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 100,
          title: Text('CheapTags Location\nLat : $Lati \nLong : $Longi',style: GoogleFonts.akayaTelivigala(fontSize: 25)),
          elevation: 4,
        ),
        body: GoogleMap(
          markers: Set<Marker>.of(_markers),
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: currentloc,
            zoom: 25.0,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          shape: RoundedRectangleBorder(side: BorderSide(width: 3,color: Colors.white),borderRadius: BorderRadius.circular(100)),
          backgroundColor: const Color.fromRGBO(222, 222, 222, 1.0),
          tooltip: 'Increment',
          child: const Icon(Icons.my_location, size: 35,color: Colors.blue),
          onPressed: (){
            print(lat.toString()+"   "+long.toString());
            _markers.add(Marker(markerId: MarkerId('CheapTag'),
            position: LatLng(lat,long),
            infoWindow: const InfoWindow(
              title: "CheapTags"
                )
              )
            );
            CameraPosition cameraPosition = CameraPosition(zoom : 17,target: LatLng(lat,long));
            final GoogleMapController controller =  mapController;
            controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
            setState(() {

            });
          },
        ),
        bottomNavigationBar: BottomAppBar(
            color: const Color.fromRGBO(222, 222, 222, 1.0),
            shape: const CircularNotchedRectangle(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Builder(
                builder: (context) => IconButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => _HomeScreen()));
                    },
                    icon: const Icon(Icons.home, color: Color.fromRGBO(43, 217, 254, 1.0))
                  ),
                ),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.settings, color: Colors.purple
                    )
                )
              ],
            )
        ),
      ),
    );
  }
}

class _HomeScreen extends StatelessWidget {

  String lat = 'lat';
  String long = 'long';
  final dbRef = FirebaseDatabase.instance.ref();



  
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          leading: Icon(
            Icons.supervisor_account,
            //For Dark Color
            //color: isDark ? tWhiteColor : tDarkColor,
          ),
          title:  Text("CheapTags", style: GoogleFonts.rubikBubbles(fontSize: 30)),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 20, top: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                //For Dark Color
                //color: isDark ? tSecondaryColor : tCardBgColor,
              ),
              child: IconButton(onPressed: () {}, icon: const Icon(Icons.exit_to_app, color: Color.fromRGBO(0, 0, 0, 2.0)),

              ),
            )
          ],
        ),

        bottomNavigationBar: BottomAppBar(
            color: const Color.fromRGBO(222, 222, 222, 1.0),
            shape: const CircularNotchedRectangle(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Builder(
                builder: (context) =>
                IconButton(

                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(
                              builder: (context) => MyApp()));

                    },
                    icon: const Icon(Icons.location_on_sharp, color: Colors.red
                    )
                )
                ),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.settings, color: Colors.purple
                    )
                )
              ],
            )
        ),
      ),
    );
  }
}

