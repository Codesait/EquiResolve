import 'dart:convert';
import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:equiresolve/service/report.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool showList = false;

  // ignore: prefer_final_fields
  List<dynamic> _reports = [];

  @override
  void initState() {
    initDash();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant Dashboard oldWidget) {
    setState(() {});
    super.didUpdateWidget(oldWidget);
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
                width: showList ? size.width - 350 : size.width,
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
    await fetchAllReports();
  }

  final reportService = Report();

  Future<void> fetchAllReports() async {
    try {
      BotToast.showLoading();

      //* subcribe to firebase real-time db
      reportService.databaseReference
        ..onChildChanged.listen((event) {
          reportService.showToast(msg: 'Report Updated');
          // DataSnapshot dataSnapshot = event.snapshot;
          // Map<dynamic, dynamic> values =
          //     dataSnapshot.value as Map<dynamic, dynamic>;

          // print('UPDATE: $values');

          // //* Find the index of the item in the report list based on its ID
          // int indexToUpdate = _reports.indexWhere(
          //     (reportItem) => reportItem['id'] == values['data']['id']);

          // //* Check if the item with the same ID exists in the report list
          // if (indexToUpdate != -1) {
          //   //* Update the properties of the item in the report list
          //   setState(() {
          //     _reports[indexToUpdate]['title'] = values['data']['title'];
          //     _reports[indexToUpdate]['latitude'] = values['data']['latitude'];
          //     _reports[indexToUpdate]['longitude'] =
          //         values['data']['longitude'];
          //     _reports[indexToUpdate]['reportStatus'] =
          //         values['data']['reportStatus'];
          //     _reports[indexToUpdate]['createdAt'] =
          //         values['data']['createdAt'];
          //     // Update other properties as needed
          //   });
          // }
        })
        ..onChildAdded.listen((event) {
          reportService.showToast(msg: 'New Report Added');
        })
        ..onValue.listen((event) {
          DataSnapshot dataSnapshot = event.snapshot;
          Map<dynamic, dynamic> values =
              dataSnapshot.value as Map<dynamic, dynamic>;

          if (values.isNotEmpty) {
            _reports.clear();
            //* stop loader indicator
            BotToast.closeAllLoading();

            //* then set ui data
            setState(() {
              values.forEach((key, value) {
                _reports.add({
                  'id': key,
                  ...value['data'],
                });
              });

              if (kDebugMode) {
                print('REPORTS $_reports');
              }
            });
          }
        }).onError((e) {
          reportService.showToast(msg: 'Fetch Report Error: $e', isError: true);
        });

      //* Return the list of documents as QueryDocumentSnapshot
    } catch (e) {
      log('FETCH REPORT BY USER ERROR: ${e.toString()}');
      rethrow; // Rethrow the error for handling in the UI
    }
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
      width: 350,
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
                  title: SizedBox(
                    width: 250,
                    child: Row(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: e['reportStatus'] == 'AWAITING'
                                ? Colors.red.withOpacity(.5)
                                : e['reportStatus'] == 'RESOLVED'
                                    ? Colors.green.withOpacity(.5)
                                    : Colors.orange.withOpacity(.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const SizedBox.square(
                            dimension: 40,
                            child: Icon(
                              Icons.report,
                              size: 25,
                            ),
                          ),
                        ),
                        const SizedBox.square(dimension: 10),
                        Flexible(
                          child: Text(
                            'Report Title: ${e['title']}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
                        'location: ${e['longitude']}, ${e['latitude']}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox.square(dimension: 10),
                      SizedBox(
                        width: 340,
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ' status: ${e['reportStatus']} -',
                              style: GoogleFonts.aBeeZee(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                backgroundColor: e['reportStatus'] == 'AWAITING'
                                    ? Colors.red.withOpacity(.5)
                                    : e['reportStatus'] == 'RESOLVED'
                                        ? Colors.green.withOpacity(.5)
                                        : Colors.orange.withOpacity(.5),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Opacity(
                                  opacity: e['reportStatus'] == 'IN_PROGRESS'
                                      ? .3
                                      : 1,
                                  child: SizedBox.square(
                                    dimension: 50,
                                    child: Card(
                                      child: IconButton(
                                        onPressed: () =>
                                            e['reportStatus'] != 'IN_PROGRESS'
                                                ? updateReport(
                                                    reportId: e['id'],
                                                    uId: e['uniqueId'],
                                                    status: 'IN_PROGRESS',
                                                    longitude: e['longitude'],
                                                    latitude: e['latitude'],
                                                    title: e['title'],
                                                    address: e['address'],
                                                    reportDescription:
                                                        e['reportDescription'],
                                                  )
                                                : null,
                                        tooltip: 'Mark as IN PROGRESS',
                                        icon: const Icon(
                                          Icons.timelapse,
                                          size: 20,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox.square(dimension: 8),
                                Opacity(
                                  opacity:
                                      e['reportStatus'] == 'RESOLVED' ? .3 : 1,
                                  child: SizedBox.square(
                                    dimension: 50,
                                    child: Card(
                                      child: IconButton(
                                        onPressed: () {
                                          if (e['reportStatus'] != 'RESOLVED') {
                                            updateReport(
                                              reportId: e['id'],
                                              uId: e['uniqueId'],
                                              status: 'RESOLVED',
                                              longitude: e['longitude'],
                                              latitude: e['latitude'],
                                              title: e['title'],
                                              address: e['address'],
                                              reportDescription:
                                                  e['reportDescription'],
                                            );
                                          }
                                        },
                                        tooltip: 'Mark as RESOLVED',
                                        icon: const Icon(
                                          Icons.local_police_rounded,
                                          size: 20,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
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

  final reportService = Report();

  Future<void> updateReport({
    required String reportId,
    required String uId,
    required String longitude,
    required String latitude,
    required String title,
    required String address,
    required String reportDescription,
    required String status,
  }) async {
    BotToast.showLoading();
    try {
      await reportService.databaseReference.child(reportId).update({
        'data': {
          'uniqueId': uId,
          'title': title,
          'reportDescription': reportDescription,
          'longitude': longitude,
          'latitude': latitude,
          'address': address,
          'reportStatus': status,
          'createdAt': DateTime.now().toString(),
        },
      }).whenComplete(() {
        BotToast.closeAllLoading();
      });
    } catch (e) {
      log(e.toString()); // Return error message if any
    }
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
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(
    8.9759323,
    7.1778177,
  );

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = {};

    ///* This code snippet is iterating over the list of reports stored in `widget.reports`. For each
    ///* `reportItem` in the reports list, it extracts the `title`, `latitude`, `longitude`, and `id`
    ///* values. If any of these values are `null`, it provides default values (`'Unknown Title'` for
    ///* title, `0.0` for latitude and longitude, and an empty string for id) using the null-aware
    ///* operator `??`.
    for (var reportItem in widget.reports) {
      String title = reportItem['title'] ?? 'Unknown Title';
      var latitude = reportItem['latitude'];
      var longitude = reportItem['longitude'];
      String id = reportItem['id'] ?? '';

      setState(() {
        markers.add(
          Marker(
            markerId: MarkerId(id),
            position:
                LatLng(convertPosition(latitude), convertPosition(longitude)),
            infoWindow: InfoWindow(title: title),
          ),
        );
      });
    }

    return GoogleMap(
      onMapCreated: (controller) => _onMapCreated(controller),
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: 6.0,
      ),
      markers: markers,
    );
  }

  double convertPosition(var data) {
    if (data is String) {
      return double.parse(data);
    } else {
      return data;
    }
  }
}
