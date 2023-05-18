class PlacesAI {
  List<Results>? results;

  PlacesAI({this.results});

  PlacesAI.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <Results>[];
      json['results'].forEach((v) {
        results!.add(new Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.results != null) {
      data['results'] = this.results!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Results {
  String? city;
  List<String>? recommendations;
  List<AvoidNeighborhoods>? avoidNeighborhoods;
  int? estimatedCost;

  Results({this.city, this.recommendations, this.avoidNeighborhoods});

  Results.fromJson(Map<String, dynamic> json) {
    city = json['city'];
    estimatedCost = json['estimated_cost'];
    recommendations = json['activities'].cast<String>();
    if (json['avoid_neighborhoods'] != null) {
      avoidNeighborhoods = <AvoidNeighborhoods>[];
      json['avoid_neighborhoods'].forEach((v) {
        avoidNeighborhoods!.add(new AvoidNeighborhoods.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['city'] = this.city;
    data['activities'] = this.recommendations;
    if (this.avoidNeighborhoods != null) {
      data['avoid_neighborhoods'] =
          this.avoidNeighborhoods!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AvoidNeighborhoods {
  double? lat;
  double? long;
  String? name;

  AvoidNeighborhoods({this.lat, this.long, this.name});

  AvoidNeighborhoods.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    long = json['long'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lat'] = this.lat;
    data['long'] = this.long;
    data['name'] = this.name;
    return data;
  }
}
