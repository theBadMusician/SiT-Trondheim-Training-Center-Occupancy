import 'package:flutter/material.dart';
import 'api_service.dart';
import 'data_models.dart';
import 'graph_widget.dart';

void main() {
  runApp(MyApp());
}

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

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Map<String, String> trainingLocations = {
    "Gløshaugen": "306",
    "Dragvoll": "307",
    "Portalen": "308",
    "DMMH": "402",
    "Moholt": "540",
    "Øya": "2825",
  };

  late Future<LocationData> futureLocationData;
  late String selectedDay; // Declare selectedDay late
  String selectedLocation = "Øya"; // Default selected location

  @override
  void initState() {
    super.initState();
    selectedDay = _getCurrentDay(); // Set selectedDay to the current day
    futureLocationData = ApiService().fetchData(trainingLocations[selectedLocation]!);
  }

  // Function to get the current day of the week
  String _getCurrentDay() {
    final DateTime now = DateTime.now();
    final List<String> daysOfWeek = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return daysOfWeek[now.weekday - 1]; // DateTime.weekday returns 1 for Monday and 7 for Sunday
  }

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
                  items: trainingLocations.keys
                      .map<DropdownMenuItem<String>>((String value) {
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
                  items: [
                    'Monday',
                    'Tuesday',
                    'Wednesday',
                    'Thursday',
                    'Friday',
                    'Saturday',
                    'Sunday'
                  ].map<DropdownMenuItem<String>>((String value) {
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
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
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
                  // If snapshot doesn't have data, show an empty container or appropriate message
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
