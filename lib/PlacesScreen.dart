import 'package:flutter/material.dart';
import 'package:hacka_flutter_app/AIRecommendations.dart';

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
        itemCount: placesList?.length ?? 1,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(placesList?[index].city ?? "Error"),
            subtitle: Text(placesList?[index].recomendations.toString() ?? "Error"),
            // Customize the ListTile based on your needs
          );
        },
      ),
    );
  }
}
