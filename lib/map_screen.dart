import 'package:flutter/material.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';
import 'package:logger/logger.dart';

class MapScreen extends StatefulWidget {
  final Map<String, double> origin;
  final Map<String, double> destination;

  const MapScreen({required this.origin, required this.destination, super.key});

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  late NextbillionMapController controller;
  final logger = Logger();
  List<DirectionsRoute> routes = [];

  @override
  void initState() {
    super.initState();
    NextBillion.initNextBillion('YOUR_KEY');
    NBNavigation.setUserId('miguel-first-nb');
    NBNavigation.getNBId().then((value) {
      logger.i('nb_id: $value');
      logger.i('origin: ${widget.origin['latitude']}, ${widget.origin['longitude']}');
      logger.i('destination: ${widget.destination['latitude']}, ${widget.destination['longitude']}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Route Map')),
      body: Stack(
        children: [
          NBMap(
            onMapCreated: onMapCreated,
            initialCameraPosition: CameraPosition(target: LatLng(widget.destination['latitude']!, widget.destination['longitude']!), zoom: 6),
          ),
          Positioned(
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final navNextBillionMap = await NavNextBillionMap.create(controller);
                    navNextBillionMap.clearRoute();
                  },
                  child: const Text('Clear Routes')
                ),
                ElevatedButton(
                  onPressed: () {
                    NavigationLauncherConfig config = NavigationLauncherConfig(route: routes.first, routes: routes, shouldSimulateRoute: true, themeMode: NavigationThemeMode.dark);
                    NBNavigation.startNavigation(config);
                  },
                  child: const Text('Start Navigation')
                ),
              ],
            ),
          )
        ],
      ) 
      
    );
  } 

  Future<void> onMapCreated(NextbillionMapController mapController) async {
    controller = mapController;
    await plotRoute();
  }

  Future<void> plotRoute() async {
    try {
      RouteRequestParams requestParams = RouteRequestParams(
        origin: LatLng(widget.origin['latitude']!, widget.origin['longitude']!),
        destination: LatLng(widget.destination['latitude']!, widget.destination['longitude']!),
        language: 'en',
        mode: ValidModes.truck,
      );

      final result = await NBNavigation.fetchRoute(requestParams);
      final navNextBillionMap = await NavNextBillionMap.create(controller);
      await navNextBillionMap.drawRoute(result.directionsRoutes);
      routes = result.directionsRoutes;
    } catch (e) {
      logger.e(e);
    }
  }
}