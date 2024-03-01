import 'package:equiresolve/app/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool authLoading = false;

  ///  instance of the`FirebaseAuth` class using the `instance` property.
  final firebaseAuth = FirebaseAuth.instance;

  /// `User` object from the Firebase authentication system
  /// or it can be `null` if no user is currently authenticated.
  User? user;

  final googleAuth = GoogleAuthProvider();

  ///* google singin instance
  final _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'emails',
      'profile',
    ],
  );

  ///* will store signed in account when ready
  late GoogleSignInAccount _currentSignedInAccount;

  //
  void checkForCurrentUser() {
    // /**
    //  * start loading indicator
    //  */
    // authLoading = true;

    firebaseAuth.authStateChanges().listen(
      (account) {
        setState(() {
          user = account!;
        });

        if (_currentSignedInAccount.displayName != null) {
          if (kDebugMode) {
            print('USER SIGNED IN ${_currentSignedInAccount.email}');
          }
        }
      },
      onDone: () {
        /**
       * stop loading indicator 
       */
        setState(() => authLoading = false);
        if (kDebugMode) {
          print('CHECKING FOR EXISTING USER DONE');
        }
      },
      onError: (e) {
        /**
         * stop loader and print error
         */
        setState(() => authLoading = false);
        if (kDebugMode) {
          print('SIGN IN ERROR: $e');
        }
      },
    );
    _googleSignIn.signInSilently();
  }

  Future<void> handleNewSignIn() async {
    setState(() => authLoading = true);
    try {
      firebaseAuth
          .signInWithProvider(googleAuth)
          .then((value) {
            if (kDebugMode) {
              print('USER: $value');
            }
          })
          .whenComplete(() => setState(() => authLoading = false))
          .onError((error, stackTrace) {
            if (kDebugMode) {
              print('SIGN IN ERROR: $error');
            }
          });
    } catch (e) {
      if (kDebugMode) {
        print('SIGN IN ERROR: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    checkForCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: AppColors.primary,
        body: Container(
          height: size.height,
          width: size.width,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // illustration
                Image.asset('asset/images/login_ill.jpeg'),

                // about app
                Text.rich(
                  TextSpan(children: [
                    const TextSpan(text: 'Combat'),
                    TextSpan(
                      text: '\nJungle Justice ',
                      style: GoogleFonts.inter(
                        color: Colors.amber,
                      ),
                    ),
                    const TextSpan(text: 'with\n Keen '),
                    TextSpan(
                      text: 'Resolve',
                      style: GoogleFonts.inter(
                        color: Colors.greenAccent,
                      ),
                    ),
                  ]),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox.square(
                  dimension: 10,
                ),

                SizedBox(
                  width: 260,
                  child: Text(
                    'Create or record reports with a click, login and continue',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white54,
                        fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox.square(
                  dimension: 40,
                ),

                _OauthBtn(
                  authType: 'Google',
                  onTap: () {
                    handleNewSignIn();
                  },
                  isLoading: authLoading,
                )
              ],
            ),
          ),
        ));
  }
}

class _OauthBtn extends StatelessWidget {
  const _OauthBtn({
    required this.authType,
    required this.onTap,
    required this.isLoading,
  });
  final String authType;
  final void Function() onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: 250,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Row(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox.square(
                    dimension: 10,
                  ),
                  SvgPicture.asset(
                    'asset/svg/google.svg',
                    height: 35,
                  ),
                  const SizedBox.square(
                    dimension: 20,
                  ),
                  Center(
                    child: Text(
                      ' with $authType Account',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
