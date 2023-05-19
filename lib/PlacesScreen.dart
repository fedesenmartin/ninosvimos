import 'package:flutter/material.dart';
import 'package:hacka_flutter_app/AIRecommendations.dart';
import 'package:hacka_flutter_app/detailActivity.dart';
import 'package:url_launcher/url_launcher.dart';

class PlacesScreen extends StatelessWidget {
  final List<Results>? placesList;

  const PlacesScreen({required this.placesList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Recommendations'),
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
            List<ListTile> tileInfo = [];
            tileInfo.add(
              ListTile(
                  style: ListTileStyle.list,
                  title: Text(
                      style: TextStyle(fontWeight:FontWeight.bold ),
                      textAlign: TextAlign.left,
                      "Estimated price: ${placesList?[index].estimatedCost}")),
            );
            tileInfo.add(ListTile(
                title: Text(
                    style: TextStyle(fontSize: 14, color: Colors.blue),
                    textAlign: TextAlign.left,
                    "Activities")));
            placesList?[index].recommendations?.forEach((element) {
              tileInfo.add(ListTile(
                onTap: () {
                  var details = " at ${placesList?[index].city}";
                  Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (BuildContext context) {
                            return MyScreen(myString: element + details);
                          }));
                },
                  title: Text(
                      style: TextStyle(color: Colors.black54),
                      element ?? "error")));
            });
            tileInfo.add(ListTile(
                title: Text(
                    style: TextStyle(fontSize: 14, color: Colors.red),
                    textAlign: TextAlign.left,
                    "Avoid Places")));
            placesList?[index].avoidNeighborhoods?.forEach((element) {
              tileInfo.add(ListTile(
                  onTap: () {
                    openGoogleMaps(element.lat, element.long);
                  },
                  title: Text(
                      style: TextStyle(color: Colors.black54),
                      element.name ?? "error")));
            });
            ExpansionTile title = ExpansionTile(
                children: tileInfo,
                title: Text(
                  placesList?[index].city ?? "Error",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
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
