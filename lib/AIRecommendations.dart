class PlacesAI {
  List<Results>? results;

  PlacesAI({this.results});

  PlacesAI.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <Results>[];
      json['results'].forEach((v) {
        results!.add(Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (results != null) {
      data['results'] = results!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Results {
  String? city;
  List<String>? recomendations;
  List<AvoidNeiberhoods>? avoidNeiberhoods;

  Results({this.city, this.recomendations, this.avoidNeiberhoods});

  Results.fromJson(Map<String, dynamic> json) {
    city = json['city'];

    recomendations = json['recommendations'].cast<String>();
    if (json['avoid_neighborhoods'] != null) {
      avoidNeiberhoods = <AvoidNeiberhoods>[];
      json['avoid_neighborhoods']?.forEach((v) {
        avoidNeiberhoods!.add(AvoidNeiberhoods.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['city'] = city;
    data['recommendations'] = recomendations;
    if (avoidNeiberhoods != null) {
      data['avoid_neighborhoods'] =
          avoidNeiberhoods!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AvoidNeiberhoods {
  double? lat;
  double? long;
  String? name;

  AvoidNeiberhoods({this.lat, this.long, this.name});

  AvoidNeiberhoods.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    long = json['long'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lat'] = lat;
    data['long'] = long;
    data['name'] = name;
    return data;
  }
}
