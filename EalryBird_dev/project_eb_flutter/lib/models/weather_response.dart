class WeatherResponse {
  final Response response;
  WeatherResponse({required this.response});

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    return WeatherResponse(
      response: Response.fromJson(json['response']),
    );
  }
}

class Response {
  final Body body;
  Response({required this.body});
  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(
      body: Body.fromJson(json['body']),
    );
  }
}

class Body {
  final Items items;
  Body({required this.items});
  factory Body.fromJson(Map<String, dynamic> json) {
    return Body(
      items: Items.fromJson(json['items']),
    );
  }
}

class Items {
  final List<Item> item;
  Items({required this.item});
  factory Items.fromJson(Map<String, dynamic> json) {
    return Items(
      item: List<Item>.from(
        (json['item'] as List).map((e) => Item.fromJson(e as Map<String, dynamic>)),
      ),
    );
  }
}

class Item {
  final String category;
  final String fcstValue;
  final String fcstTime;
  final String fcstDate;

  Item({
    required this.category,
    required this.fcstValue,
    required this.fcstTime,
    required this.fcstDate,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      category:  json['category']  as String,
      fcstValue: json['fcstValue'] as String,
      fcstTime:  json['fcstTime']  as String,
      fcstDate:  json['fcstDate']  as String,
    );
  }
}
