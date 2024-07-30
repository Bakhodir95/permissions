import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:lesson72/services/location_service.dart';

class HomeScreenMap extends StatefulWidget {
  const HomeScreenMap({super.key});

  @override
  State<HomeScreenMap> createState() => _HomeScreenMapState();
}

class _HomeScreenMapState extends State<HomeScreenMap> {
  List<MapType> typeMap = [
    MapType.hybrid,
    MapType.normal,
    MapType.satellite,
    MapType.none,
    MapType.terrain,
  ];
  List<TravelMode> travleModes = [
    TravelMode.walking,
    TravelMode.transit,
    TravelMode.driving,
    TravelMode.bicycling,
  ];
  TravelMode currentTravelMode = TravelMode.driving;
  MapType currentMapType = MapType.hybrid;
  final textController = TextEditingController();
  late GoogleMapController myController;
  Set<Polyline> polylines = {};
  Marker? selectedMarker;
  LatLng? selectedPosition;

  LatLng _center = LatLng(LocationService.locationData!.latitude!, LocationService.locationData!.longitude!);

  void _onMapCreated(GoogleMapController controller) {
    myController = controller;
  }

  void liveLocation() {
    LocationService.getLiveLocation().listen((value) {
      _center = LatLng(value.latitude!, value.longitude!);
      setState(() {});
    });
  }

  void addLocationMarker() {
    if (selectedPosition != null) {
      setState(() {
        polylines.clear();
      });
      LocationService.fetchPolylinePoints(
        _center,
        selectedPosition!,
        currentTravelMode,
      ).then((List<LatLng> positions) {
        setState(() {
          polylines.add(
            Polyline(
              jointType: JointType.round,
              geodesic: true,
              endCap: Cap.roundCap,
              polylineId: PolylineId(UniqueKey().toString()),
              color: Colors.blue,
              width: 5,
              points: positions,
            ),
          );
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    liveLocation();
  }

  void onLongPress(LatLng position) {
    setState(() {
      selectedPosition = position;
      selectedMarker = Marker(
        markerId: MarkerId("selected_marker"),
        position: position,
        infoWindow: InfoWindow(
          title: "Selected Location",
          snippet: "(${position.latitude}, ${position.longitude})",
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      );
      addLocationMarker();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            trafficEnabled: true,
            myLocationButtonEnabled: true,
            buildingsEnabled: true,
            fortyFiveDegreeImageryEnabled: true,
            myLocationEnabled: true,
            onLongPress: onLongPress,
            markers: {
              Marker(
                markerId: const MarkerId("Current Location"),
                icon: BitmapDescriptor.defaultMarker,
                position: _center,
                infoWindow: const InfoWindow(
                  title: "Current Location",
                  snippet: "This is your current location",
                ),
              ),
              if (selectedMarker != null) selectedMarker!,
            },
            mapType: currentMapType,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 18.0,
            ),
            polylines: polylines,
          ),
          Positioned(
            top: 40.0,
            left: 15.0,
            right: 15.0,
            child: GooglePlacesAutoCompleteTextFormField(
              maxLines: 1,
              decoration: InputDecoration(
                filled: true,
                suffixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  gapPadding: 2,
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.white,
                hintText: "Search",
              ),
              textEditingController: textController,
              googleAPIKey: "AIzaSyBEjfX9jrWudgRcWl2scld4R7s0LtlaQmQ",
              debounceTime: 400, // defaults to 600 ms
              isLatLngRequired: true, // if you require the coordinates from the place details
              getPlaceDetailWithLatLng: (prediction) {
                print("Coordinates: (${prediction.lat}, ${prediction.lng})");
                // Move camera to the searched location
                myController.animateCamera(
                  CameraUpdate.newLatLng(
                    LatLng(double.parse(prediction.lat!), double.parse(prediction.lng!)),
                  ),
                );
              },
              itmClick: (prediction) {
                textController.text = prediction.description!;
                textController.selection = TextSelection.fromPosition(
                  TextPosition(offset: prediction.description!.length),
                );
              },
            ),
          ),
          Positioned(
            top: 100,
            right: 10,
            child: PopupMenuButton(
              icon: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(5),
                child: const Icon(Icons.map),
              ),
              onSelected: (value) {
                currentMapType = value;
                setState(() {});
              },
              itemBuilder: (context) {
                return [
                  for (var i in typeMap)
                    PopupMenuItem(
                      value: i,
                      child: Text(i.name),
                    ),
                ];
              },
            ),
          ),
          Positioned(
            top: 100,
            left: 10,
            child: PopupMenuButton(
              icon: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(5),
                child: const Icon(Icons.travel_explore),
              ),
              onSelected: (value) {
                currentTravelMode = value;
                addLocationMarker();
                setState(() {});
              },
              itemBuilder: (context) {
                return [
                  for (var i in travleModes)
                    PopupMenuItem(
                      value: i,
                      child: Text(i.name),
                    ),
                ];
              },
            ),
          )
        ],
      ),
    );
  }
}
