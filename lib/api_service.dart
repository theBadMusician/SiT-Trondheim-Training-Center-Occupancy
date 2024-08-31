import 'dart:convert';
import 'package:http/http.dart' as http;
import 'data_models.dart';

class ApiService {
  final String baseUrl = 'https://api.sit.no/api/ibooking/demand/';

  Future<LocationData> fetchData(String locationId) async {
    final url = '$baseUrl$locationId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return LocationData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load data');
    }
  }
}
