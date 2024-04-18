import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Report {
  factory Report() => _instance ??= Report._();

  Report._();
  static Report? _instance;

  late DatabaseReference databaseReference;
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref().child('reports');

  Future<dynamic> createReport(
    BuildContext context, {
    required String user,
    required String longitude,
    required String latitude,
    required String title,
    String? address,
    String? reportDescription,
  }) async {
    BotToast.showLoading();
    try {
      await _databaseReference.push().set({
        'user': user,
        'data': {
          'title': title,
          'reportDescription': reportDescription,
          'longitude': longitude,
          'latitude': latitude,
          'address': address,
          'reportStatus': 'AWAITING',
          'createdAt': DateTime.now().toString(),
        },
      }).then((value) {
        BotToast.closeAllLoading();
        context.pop();
        showToast(msg: 'Report Created');
      });
      return true; // Indicate success
    } catch (e) {
      BotToast.closeAllLoading();
      showToast(msg: e.toString(), isError: true);
      log('CREATE REPORT ERROR ${e.toString()}');
      return e.toString(); // Return error message if any
    }
  }

  Future<List<dynamic>> fetchReportByUser(String user) async {
    List<dynamic> reports = [];
    try {
      // Create a query to fetch reports where 'user' field matches userId
      final query = _databaseReference.orderByChild('user').equalTo(user);

      // Get a snapshot of the query results
      final querySnapshot = await query.get();

      /// cast the `value` property of the
      /// `querySnapshot` object to a `Map<dynamic, dynamic>` type.

      if (querySnapshot.value != null) {
        Map<dynamic, dynamic> reportsMap =
            querySnapshot.value as Map<dynamic, dynamic>;

        

        reportsMap.forEach((key, value) {
          reports.add({
            'id': key,
            ...value['data'],
          });
        });

        if (kDebugMode) {
          log('REPORTS $reports');
        }
      }

      if (kDebugMode) {
        print(querySnapshot.value.toString());
      }

      // Return the list of documents as QueryDocumentSnapshot
      return reports;
    } catch (e) {
      log('FETCH REPORT BY USER ERROR: ${e.toString()}');
      rethrow; // Rethrow the error for handling in the UI
    }
  }

  Future<dynamic> updateReport({
    required String reportId,
    required String title,
    String? reportDescription,
    required String longitude,
    required String latitude,
  }) async {
    try {
      await _databaseReference.child(reportId).update({
        'data': {
          'title': title,
          'reportDescription': reportDescription,
          'longitude': longitude,
          'latitude': latitude,
        },
      });
      return true; // Indicate success
    } catch (e) {
      return e.toString(); // Return error message if any
    }
  }

  Future<dynamic> deleteReport(String reportId) async {
    try {
      await _databaseReference.child(reportId).remove();
      return true; // Indicate success
    } catch (e) {
      return e.toString(); // Return error message if any
    }
  }

  void showToast({required String msg, bool isError = false}) {
    BotToast.showSimpleNotification(
      title: msg,
      backgroundColor: isError ? Colors.red : Colors.green,
      titleStyle: const TextStyle(
        color: Colors.white,
      ),
    );
  }

  void showSnackbarMessage(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 100, right: 20, left: 20),
      ),
    );
  }
}
