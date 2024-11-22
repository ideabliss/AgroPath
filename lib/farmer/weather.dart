import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class WeatherTab extends StatefulWidget {
  const WeatherTab({super.key});

  @override
  State<WeatherTab> createState() => _WeatherTabState();
}

class _WeatherTabState extends State<WeatherTab> {
  String city = "";
  String temperature = "";
  String description = "";
  String weatherIcon = "";
  String maxTemp = "";
  String minTemp = "";
  String humidity = "";
  String windSpeed = "";
  String collectedTime = "";
  bool isLoading = false;
  final TextEditingController _controller = TextEditingController();

  // Replace with your OpenWeatherMap API Key
  final String apiKey = '4f4271a79e19517a509631817b0c7f31';

  // Fetch weather data for a city
  Future<void> fetchWeather(String city) async {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric');

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(url);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Formatting the time of data collection
        DateTime collectedDate = DateTime.fromMillisecondsSinceEpoch(data['dt'] * 1000);
        collectedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(collectedDate);

        setState(() {
          temperature = "${data['main']['temp']}°C";
          description = data['weather'][0]['description'];
          weatherIcon = data['weather'][0]['icon'];
          maxTemp = "${data['main']['temp_max']}°C";
          minTemp = "${data['main']['temp_min']}°C";
          humidity = "${data['main']['humidity']}%";
          windSpeed = "${data['wind']['speed']} m/s";
          city = data['name'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          temperature = "Error fetching data";
          description = "Please try again.";
          weatherIcon = "";
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
        temperature = "Error fetching data";
        description = "Please try again.";
        weatherIcon = "";
      });
    }
  }

  // Fetch weather based on current location
  Future<void> fetchWeatherForCurrentLocation() async {
    // Get current position
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    double latitude = position.latitude;
    double longitude = position.longitude;

    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric');

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(url);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Formatting the time of data collection
        DateTime collectedDate = DateTime.fromMillisecondsSinceEpoch(data['dt'] * 1000);
        collectedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(collectedDate);

        setState(() {
          temperature = "${data['main']['temp']}°C";
          description = data['weather'][0]['description'];
          weatherIcon = data['weather'][0]['icon'];
          maxTemp = "${data['main']['temp_max']}°C";
          minTemp = "${data['main']['temp_min']}°C";
          humidity = "${data['main']['humidity']}%";
          windSpeed = "${data['wind']['speed']} m/s";
          city = data['name'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          temperature = "Error fetching data";
          description = "Please try again.";
          weatherIcon = "";
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
        temperature = "Error fetching data";
        description = "Please try again.";
        weatherIcon = "";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch weather based on current location when the app starts
    fetchWeatherForCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: Text("Weather",   style: TextStyle(
            fontFamily: 'ProtestStrike',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E5B3D),
          ),),
        backgroundColor: Color(0xFFA5DAA3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Search bar
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "Enter City",
                filled: true,
                fillColor: Color.fromARGB(255, 203, 199, 199),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                // Fetch weather for city as soon as user types
                if (value.isNotEmpty) {
                  fetchWeather(value);
                }
              },
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator(
                    color: Color(0xFF2C6B8D),
                  )
                : weatherIcon.isEmpty
                    ? Text(
                        "Enter a city to get the weather.",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      )
                    : Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              // Weather details
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: EdgeInsets.all(20),
                                margin: EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                  children: [
                                    Text(
                                      "Weather for $city",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "Data collected at: $collectedTime",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      temperature,
                                      style: TextStyle(
                                        fontSize: 60,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Image.network(
                                      'https://openweathermap.org/img/wn/$weatherIcon.png',
                                      height: 100,
                                      width: 100,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      description,
                                      style: TextStyle(fontSize: 20, color: Colors.black),
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              "Max Temp: $maxTemp",
                                              style: TextStyle(fontSize: 18),
                                            ),
                                            Text(
                                              "Min Temp: $minTemp",
                                              style: TextStyle(fontSize: 18),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              "Humidity: $humidity",
                                              style: TextStyle(fontSize: 18),
                                            ),
                                            Text(
                                              "Wind Speed: $windSpeed",
                                              style: TextStyle(fontSize: 18),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
