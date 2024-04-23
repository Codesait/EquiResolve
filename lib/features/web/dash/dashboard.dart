import 'package:equiresolve/service/report.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool showList = false;

  List<dynamic> _reports = [];

  @override
  void initState() {
    initDash();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EquiResolve',
        ),
      ),
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Stack(
          children: [
            Positioned(
              right: 0,
              child: AnimatedContainer(
                width: showList ? size.width - 300 : size.width,
                height: size.height,
                duration: const Duration(milliseconds: 100),
                child: _MapWidget(
                  reports: _reports,
                ),
              ),
            ),
            Positioned(
              left: 0,
              child: Visibility(
                  visible: showList, child: _AllReports(reports: _reports)),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            showList = !showList;
          });
        },
        label: const SizedBox(
          child: Text('Report List'),
        ),
        icon: const Icon(Icons.list),
      ),
    );
  }

  Future<void> initDash() async {
    //* start fetching all reports made by
    //* users
    await Report().fetchAllReports().then(
      (value) {
        setState(() {
          _reports = value;
          if (kDebugMode) {
            print(_reports);
          }
        });
      },
    );
  }
}

//* All Report List
class _AllReports extends StatefulWidget {
  const _AllReports({required this.reports});
  final List<dynamic> reports;

  @override
  State<_AllReports> createState() => __AllReportsState();
}

class __AllReportsState extends State<_AllReports> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height,
      width: 300,
      decoration: BoxDecoration(
        color: Colors.purpleAccent.withOpacity(.4),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 60),
        children: widget.reports
            .map(
              (e) => Card(
                elevation: 3,
                child: ListTile(
                  title: Text(
                    'Report Title: ${e['title']}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      Text(
                        'Report Description: ${e['reportDescription']}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox.square(dimension: 10),
                      Text(
                        'address: ${e['address']}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox.square(dimension: 10),
                      Text(
                        'location:${e['longitude']}, ${e['latitude']}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

//* Map Widget
class _MapWidget extends StatefulWidget {
  const _MapWidget({required this.reports});
  final List<dynamic> reports;

  @override
  State<_MapWidget> createState() => __MapWidgetState();
}

class __MapWidgetState extends State<_MapWidget> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return const GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(-33.86, 151.20),
        zoom: 11.0,
      ),
      markers: {
        Marker(
          markerId: MarkerId('Sydney'),
          position: LatLng(-33.86, 151.20),
        ),
      },
    );
  }
}
