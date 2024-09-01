import 'package:flutter/material.dart';
import 'api_service.dart';
import 'data_models.dart';
import 'graph_widget.dart';

void main() {
  runApp(MyApp());
}

/// The main application widget.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interactive Graph App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

/// The home page of the application, displaying a graph of location data.
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Map of training locations with their respective IDs
  final Map<String, String> trainingLocations = {
    "Gløshaugen": "306",
    "Dragvoll": "307",
    "Portalen": "308",
    "DMMH": "402",
    "Moholt": "540",
    "Øya": "2825",
  };

  late Future<LocationData> futureLocationData; // Future for fetching location data
  late String selectedDay; // The currently selected day
  String selectedLocation = "Øya"; // Default selected location

  @override
  void initState() {
    super.initState();
    selectedDay = _getCurrentDay(); // Initialize selectedDay to the current day
    futureLocationData = ApiService().fetchData(trainingLocations[selectedLocation]!);
  }

  /// Gets the current day of the week.
  ///
  /// Returns a string representing the current day of the week.
  String _getCurrentDay() {
    final DateTime now = DateTime.now();
    final List<String> daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return daysOfWeek[now.weekday - 1]; // DateTime.weekday returns 1 for Monday and 7 for Sunday
  }

  /// Fetches data for the selected location.
  ///
  /// [location] is the key for the selected location from [trainingLocations].
  void _fetchDataForLocation(String location) {
    setState(() {
      selectedLocation = location;
      futureLocationData = ApiService().fetchData(trainingLocations[location]!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(20.0), // Smaller AppBar height
        child: AppBar(
          title: Text(
            'SiT Training Center Vacancy',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold), // Smaller title font size
          ),
          centerTitle: true, // Centered title
        ),
      ),
      body: Column(
        children: [
          // Row to place dropdowns next to each other
          Padding(
            padding: const EdgeInsets.all(8.0), // Added padding for spacing
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Dropdown for selecting location
                DropdownButton<String>(
                  value: selectedLocation,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      _fetchDataForLocation(newValue);
                    }
                  },
                  items: trainingLocations.keys.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                SizedBox(width: 20), // Space between the dropdowns
                // Dropdown for selecting day
                DropdownButton<String>(
                  value: selectedDay,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDay = newValue!;
                    });
                  },
                  items: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<LocationData>(
              future: futureLocationData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show a loading indicator while waiting for data
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  // Check for no network error specifically
                  if (snapshot.error.toString().contains('No network connection')) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('No network connection. Please check your internet settings.'),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              // Retry fetching data
                              setState(() {
                                futureLocationData = ApiService().fetchData(trainingLocations[selectedLocation]!);
                              });
                            },
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Display a generic error message for other errors
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                } else if (snapshot.hasData) {
                  var locationData = snapshot.data!;

                  // Convert selectedDay to lowercase to match the keys in the map
                  String dayKey = selectedDay.toLowerCase();

                  if (locationData.days.containsKey(dayKey)) {
                    // The day exists in the map
                    var dayData = locationData.days[dayKey]!;

                    return Column(
                      children: [
                        Expanded(
                          child: GraphWidget(dayData: dayData),
                        ),
                      ],
                    );
                  } else {
                    // If the day is not found, show a message
                    return Center(child: Text('Data for $selectedDay is not available.'));
                  }
                } else {
                  // If snapshot doesn't have data, show an appropriate message
                  return Center(child: Text('No data available.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
