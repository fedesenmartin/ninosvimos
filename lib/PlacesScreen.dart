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
          return ListTile(
            onTap: () {
              openGoogleMaps(placesList?[index].avoidNeiberhoods?.first.lat, placesList?[index].avoidNeiberhoods?.first.long);
            },
            title: Text(placesList?[index].city ?? "Error"),
            subtitle: Text(placesList?[index].avoidNeiberhoods?.first.name  ?? "Error"),
            // Customize the ListTile based on your needs
          );
        },
      ),
    );
  }

  void openGoogleMaps(double? latitude, double? longitude) async {
    Uri googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }
}


