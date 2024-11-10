import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/hourly_forcast_item.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  Future<Map<String, dynamic>> getCurrentWeather(
      [String cityName = "Islamabad"]) async {
    try {
      final res = await http.get(
        Uri.parse(
          "http://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherApiKey",
        ),
      );
      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw 'An unexpected error occurred';
      }

      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  final border = OutlineInputBorder(
    borderSide: const BorderSide(
      color: Colors.black,
      width: 2.0,
      style: BorderStyle.solid,
      strokeAlign: BorderSide.strokeAlignOutside,
    ),
    borderRadius: BorderRadius.circular(15),
  );

  void _startSearch() {
    setState(() {
      isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      isSearching = false;
      _searchController.clear();
      FocusScope.of(context).unfocus();
    });
  }

  void _performSearch() {
    if (_searchController.text.isNotEmpty) {
      setState(() {
        weather = getCurrentWeather(_searchController.text);
        _stopSearch();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weather = getCurrentWeather();
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: TextField(
              controller: _searchController,
              onTap: _startSearch,
              onSubmitted: (value) => _performSearch(),
              textInputAction: TextInputAction.search,
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: "Search for City",
                hintStyle: const TextStyle(
                  color: Colors.white,
                ),
                hintMaxLines: 1,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: isSearching
                    ? IconButton(
                        icon: const Icon(Icons.cancel),
                        onPressed: _stopSearch,
                      )
                    : null,
                iconColor: Colors.white,
                filled: true,
                fillColor: Colors.white10,
                focusedBorder: border,
                enabledBorder: border,
              ),
            ),
          ),
          Flexible(
            child: FutureBuilder(
              future: weather,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }

                final data = snapshot.data!;
                final currentWeatherData = data['list'][0];
                final currentTemp = currentWeatherData['main']['temp'];
                final currentTempC = currentTemp - 273.15;
                final currentSky = currentWeatherData['weather'][0]['main'];
                final currentPressure = currentWeatherData['main']['pressure'];
                final currentWindSpeed = currentWeatherData['wind']['speed'];
                final currentHumidity = currentWeatherData['main']['humidity'];

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Card(
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        "${currentTempC != 0 ? currentTempC.toStringAsFixed(2) : currentTempC.toStringAsFixed(0)}°C",
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Icon(
                                        currentSky == 'Clouds' ||
                                                currentSky == 'Rain'
                                            ? Icons.cloud
                                            : Icons.sunny,
                                        size: 60,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        currentSky,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Weather Forecast",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            itemCount: 5,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final hourlyForecast = data['list'][index + 1];
                              final hourlySky =
                                  data['list'][index + 1]['weather'][0]['main'];
                              final time = DateTime.parse(
                                hourlyForecast['dt_txt'].toString(),
                              );
                              return HourlyForecestItem(
                                icon: hourlySky == 'Clouds' ||
                                        hourlySky == 'Rainy'
                                    ? Icons.cloud
                                    : Icons.sunny,
                                time: DateFormat.j().format(time),
                                temperator:
                                    hourlyForecast['main']['temp'].toString(),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Additional Information",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            AdditionalInfoItem(
                              icon: Icons.water_drop,
                              label: "Humidity",
                              value: currentHumidity.toString(),
                            ),
                            AdditionalInfoItem(
                              icon: Icons.air,
                              label: "Wind Speed",
                              value: currentWindSpeed.toString(),
                            ),
                            AdditionalInfoItem(
                              icon: Icons.beach_access,
                              label: "Pressure",
                              value: currentPressure.toString(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
