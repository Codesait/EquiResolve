// ignore_for_file: slash_for_doc_comments

import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:equiresolve/router/route_names.dart';
import 'package:equiresolve/service/auth_service.dart';
import 'package:equiresolve/service/location.dart';
import 'package:equiresolve/service/report.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final firebaseAuth = AuthService().firebaseAuth;

  final formKey = GlobalKey<FormState>();

  List<dynamic> _reports = [];

  /**
    report entry controllers
   */
  TextEditingController? titleController;
  TextEditingController? descController;

  /// `User` object from the Firebase authentication system
  /// or it can be `null` if no user is currently authenticated.
  User? user;

  final reportService = Report();
  final locationService = EQLocationService();

  String? _currentAddress;
  Position? _currentPosition;

  Future<void> initDash() async {
    /**
      sget user first
     */
    await checkForCurrentUser();

    /**
      start fetching report made by
      existing user
     */
    BotToast.showLoading();
    await reportService.fetchReportByUser(user!.email!).then((value) {
      setState(() {
        _reports = value;
      });
      BotToast.closeAllLoading();
    });
  }

  @override
  void initState() {
    titleController = TextEditingController();
    descController = TextEditingController();
    initDash();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    locationService.handleLocationPermission(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      onPopInvoked: (didPop) {
        context.pushReplacementNamed(NamedRoutes.splash.name);
      },
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () {
              return initDash();
            },
            child: SingleChildScrollView(
              child: SizedBox(
                height: size.height,
                width: size.width,
                child: user != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _UserWidget(userDetails: user!),
                          ),
                          Expanded(
                            flex: 7,
                            child: _Reports(
                              reports: _reports,
                            ),
                          )
                        ],
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showReportModal(size),
          icon: const Icon(Icons.report),
          label: const Text('Report'),
        ),
      ),
    );
  }

  Future<dynamic> checkForCurrentUser() async {
    BotToast.showLoading();
    try {
      firebaseAuth.authStateChanges().listen(
        (account) {
          if (account != null) {
            setState(() {
              user = account;
            });

            BotToast.closeAllLoading();

            if (kDebugMode) {
              print('USER SIGNED IN $user');
            }
          }
        },
        onDone: () {
          if (kDebugMode) {
            print('CHECKING FOR EXISTING USER DONE');
          }
        },
        onError: (e) {
          if (kDebugMode) {
            print('SIGN IN ERROR: $e');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error $e');
      }
    }
  }

  void showReportModal(Size size) {
    showModalBottomSheet(
        backgroundColor: Colors.blue,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(0.0)),
        ),
        constraints: BoxConstraints(minHeight: size.height * 0.6),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, updateState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                height: size.height * .7,
                width: size.width,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      // title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Report',
                            style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.cancel_sharp))
                        ],
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      CustomTextField(
                        controller: titleController!,
                        hintText: 'Title',
                        validator: (value) {
                          return value != null ? null : 'required';
                        },
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      CustomTextField(
                        controller: descController!,
                        hintText: 'Description (optional)',
                        maxLines: 10,
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),

                      SizedBox(
                        width: size.width,
                        height: 35,
                        child: TextButton(
                          onPressed: () async {
                            await locationService
                                .getCurrentPosition(context)
                                .then((value) {
                              updateState(() {
                                _currentPosition = value;
                              });

                              //* log positions
                              log(value.toString());
                            });

                            //*use positions to get address
                            await locationService
                                .getAddressFromLatLng(_currentPosition!)
                                .then((value) {
                              final placemarks = value as List<Placemark>;

                              Placemark place = placemarks[0];
                              updateState(() {
                                _currentAddress =
                                    '${place.street}, ${place.subLocality} ${place.subAdministrativeArea}, ${place.postalCode}';
                              });

                              /** 
                                then log address
                              */
                              log(_currentAddress!);
                            });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: _currentPosition != null
                                ? Colors.green
                                : Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          child: Text(
                            _currentAddress != null
                                ? _currentAddress!
                                : _currentPosition != null
                                    ? 'Location Picked'
                                    : 'Get My Location',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 20.0,
                      ),

                      InkWell(
                        onTap: () {
                          if (titleController!.text.isEmpty) {
                            reportService.showToast(
                              msg: 'Report title is required',
                              isError: true,
                            );
                          } else if (_currentPosition == null) {
                            reportService.showToast(
                              msg: 'Location is required',
                              isError: true,
                            );
                          } else {
                            reportService
                                .createReport(
                              context,
                              user: user!.email!,
                              longitude: _currentPosition!.longitude.toString(),
                              latitude: _currentPosition!.latitude.toString(),
                              address: _currentAddress,
                              title: titleController!.text.trim(),
                              reportDescription: descController!.text.trim(),
                            )
                                .whenComplete(() {
                              _currentPosition = null;
                              _currentAddress = null;
                            });
                          }
                        },
                        child: Container(
                          height: 50,
                          width: size.width / 1.2,
                          decoration: BoxDecoration(
                            color: Colors.purple,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                              child: Text(
                            'Submit report',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          });
        },
        isScrollControlled: true);
  }
}

class _UserWidget extends StatelessWidget {
  const _UserWidget({
    required this.userDetails,
  });
  final User userDetails;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 100,
          width: 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: CachedNetworkImage(
              imageUrl: userDetails.photoURL ?? '',
              height: 10,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => CircleAvatar(
                backgroundColor: Colors.purple.withOpacity(.2),
                child: const Icon(Icons.person),
              ),
            ),
          ),
        ),
        const SizedBox.square(
          dimension: 10,
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: userDetails.email),
            ],
          ),
          style: GoogleFonts.poppins(
              color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox.square(dimension: 10),
        SizedBox(
          width: 130,
          child: ElevatedButton(
            onPressed: () {
              AuthService().signOut(context).then((value) {
                context.pushReplacementNamed(NamedRoutes.signIn.name);
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Logout ',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Icon(
                  Icons.exit_to_app_rounded,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        const SizedBox.square(dimension: 10),
      ],
    );
  }
}

class _Reports extends StatelessWidget {
  const _Reports({required this.reports});
  final List<dynamic> reports;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 10,
      ),
      color: Colors.grey.withOpacity(.2),
      child: reports.isEmpty
          ? Center(
              child: Text(
                'No reports',
                style: GoogleFonts.aBeeZee(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My reports',
                  style: GoogleFonts.aBeeZee(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox.square(dimension: 20),
                Container(
                  height: size.height / 1.6,
                  width: size.width,
                  padding: const EdgeInsets.only(bottom: 50),
                  child: ListView.builder(
                      itemCount: reports.length,
                      itemBuilder: (context, int i) {
                        final report = reports[i];
                        return ListTile(
                          style: ListTileStyle.list,
                          leading: DecoratedBox(
                            decoration: BoxDecoration(
                              color: report['reportStatus'] == 'AWAITING'
                                  ? Colors.red.withOpacity(.5)
                                  : report['reportStatus'] == 'RESOLVED'
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
                          title: Text(
                            report['title'],
                            style: GoogleFonts.aBeeZee(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                report['reportDescription'] ?? 'No Description',
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.aBeeZee(
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox.square(dimension: 7),
                              Text(
                                ' status: ${report['reportStatus']} -',
                                style: GoogleFonts.aBeeZee(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  backgroundColor:
                                      report['reportStatus'] == 'AWAITING'
                                          ? Colors.red.withOpacity(.5)
                                          : report['reportStatus'] == 'RESOLVED'
                                              ? Colors.green.withOpacity(.5)
                                              : Colors.orange.withOpacity(.5),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                )
              ],
            ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {Key? key,
      required this.controller,
      this.hintText,
      this.prefix,
      this.suffixIcon,
      this.labelText,
      this.validator,
      this.obscureText,
      this.readOnly = false,
      this.autoFocus = false,
      this.inputType,
      this.maxLines = 1,
      this.maxLength,
      this.focusNode,
      this.onChange,
      this.fillColor,
      this.onTap,
      this.prefixColor,
      this.fontSize})
      : super(key: key);
  final TextEditingController controller;
  final String? hintText;
  final Widget? prefix;
  final Widget? suffixIcon;
  final String? labelText;
  final FormFieldValidator<String>? validator;
  final bool? obscureText;
  final TextInputType? inputType;
  final bool readOnly;
  final bool autoFocus;
  final int? maxLines;
  final int? maxLength;
  final FocusNode? focusNode;
  final void Function()? onTap;
  final Function(String? val)? onChange;
  final Color? fillColor;
  final Color? prefixColor;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      readOnly: readOnly,
      autofocus: autoFocus,
      onChanged: onChange,
      maxLines: maxLines,
      maxLength: maxLength,
      focusNode: focusNode,
      obscureText: obscureText ?? false,
      onTap: onTap,
      style: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(fontSize: fontSize ?? 14),
      keyboardType: inputType,
      cursorColor: Colors.grey,
      decoration: InputDecoration(
          hintStyle: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey, fontSize: fontSize ?? 14),
          counterStyle: const TextStyle(
              color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
          hintText: hintText,
          prefixIcon: prefix,
          prefixIconColor: prefixColor ??
              MaterialStateColor.resolveWith(
                (states) => states.contains(MaterialState.focused)
                    ? Colors.black
                    : const Color(0xFF9E9E9E),
              ),
          suffixIcon: suffixIcon,
          suffixIconColor: MaterialStateColor.resolveWith(
            (states) => states.contains(MaterialState.focused)
                ? Colors.black
                : const Color(0xFF9E9E9E),
          ),
          labelText: labelText,
          labelStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 15),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Colors.purple.withOpacity(.5), width: 1.0),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: readOnly || maxLength != null
                ? BorderSide.none
                : const BorderSide(color: Colors.purple, width: 2.0),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          filled: true,
          fillColor: fillColor ?? Colors.white),
    );
  }
}
