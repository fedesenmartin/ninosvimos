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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/segundo2.jpeg"),
            fit: BoxFit.fill,
          ),
        ),
        child: ListView.builder(
          itemCount: placesList?.length ?? 0,
          itemBuilder: (context, index) {
            List<Widget> tileInfo = [];
            tileInfo.add(
              Text("Estimated price:${placesList?[index].estimatedCost}"),
            );
            tileInfo.add(
              Text("Activities:"),
            );
            placesList?[index].recommendations?.forEach((element) {
              tileInfo.add(ListTile(
                  title: Text(
                      style: TextStyle(color: Colors.blue),
                      element ?? "error")));
            });
            tileInfo.add(
              Text("Avoid places:"),
            );
            placesList?[index].avoidNeighborhoods?.forEach((element) {
              tileInfo.add(ListTile(
                  onTap: () {
                    openGoogleMaps(element.lat, element.long);
                  },
                  title: Text(
                      style: TextStyle(color: Colors.red),
                      element.name ?? "error")));
            });
            ExpansionTile title = ExpansionTile(
                children: tileInfo,
                title: Text(
                  placesList?[index].city ?? "Error",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 20),
                ));

            return Card(child: title);
          },
        ),
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
