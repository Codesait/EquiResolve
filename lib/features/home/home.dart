import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:equiresolve/service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final firebaseAuth = AuthService().firebaseAuth;

  /// `User` object from the Firebase authentication system
  /// or it can be `null` if no user is currently authenticated.
  User? user;

  @override
  void initState() {
    checkForCurrentUser();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: size.height,
          width: size.width,
          child: user != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _UserWidget(userDetails: user!),
                    ),
                    const Expanded(
                      flex: 7,
                      child: _Reports(),
                    )
                  ],
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.report),
        label: const Text('Report'),
      ),
    );
  }

  void checkForCurrentUser() {
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
      ],
    );
  }
}

class _Reports extends StatelessWidget {
  const _Reports();

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My reports',
            style: GoogleFonts.aBeeZee(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}
