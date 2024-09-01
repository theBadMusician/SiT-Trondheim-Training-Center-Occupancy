import 'dart:convert'; // Provides utilities for encoding and decoding JSON
import 'package:http/http.dart' as http; // HTTP client package
import 'package:connectivity_plus/connectivity_plus.dart'; // Connectivity package
import 'data_models.dart'; // Import your data models

/// A service class responsible for fetching data from the API.
class ApiService {
  /// The base URL of the API endpoint for fetching location data.

  /*
  Fetches data for a specific location by [locationId].
  Checks network connectivity before sending a GET request to the API using
  the [locationId] to retrieve data. If the request is successful (status code 200),
  it parses the response body into a [LocationData] object. If the request fails or
  there is no network connection, it throws an exception.
  Throws:
  - [Exception] if there is no network connection.
  - [Exception] if the request fails or returns a non-200 status code.
  Returns:
  A [Future] that completes with a [LocationData] object if the request is successful.
  */
  Future<LocationData> fetchData(String locationId) async {
    // Check the current network connectivity status
    final connectivityResult = await (Connectivity().checkConnectivity());

    // If there is no network connection, throw an exception
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('No network connection. Please check your internet settings.');
    }

    final url = '$baseUrl$locationId'; // Construct the full API URL
    final response = await http.get(Uri.parse(url)); // Perform the GET request

    // Check if the response was successful
    if (response.statusCode == 200) {
      // Parse the response body and convert it to a LocationData object
      return LocationData.fromJson(json.decode(response.body));
    } else {
      // Throw an exception if the response was not successful
      throw Exception('Failed to load data');
    }
  }

  final String baseUrl = 'https://api.sit.no/api/ibooking/demand/';
}
