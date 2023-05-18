import 'package:flutter/material.dart';
import 'package:hacka_flutter_app/AIRecommendations.dart';
import 'package:url_launcher/url_launcher.dart';

class PlacesScreen extends StatelessWidget {
  final List<Results>? placesList;

  const PlacesScreen({required this.placesList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Places List'),
      ),
      body: ListView.builder(
        itemCount: placesList?.length ?? 0,
        itemBuilder: (context, index) {
          List<ListTile> not_recommended_places = [];
          placesList?[index].recommendations?.forEach((element) {
            not_recommended_places.add(ListTile(
                title: Text(style: TextStyle(color: Colors.blue),element ?? "error")));
          });
          placesList?[index].avoidNeighborhoods?.forEach((element) {
            not_recommended_places.add(ListTile(
                onTap: () {
                  openGoogleMaps(element.lat, element.long);
                  },
                title: Text(style: TextStyle(color: Colors.red),element.name ?? "error")));
          });
          return ExpansionTile(
              title: Text(placesList?[index].city ?? "Error"),
              children: not_recommended_places);
        },
      ),
    );
  }

  void openGoogleMaps(double? latitude, double? longitude) async {
    Uri googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }
}
