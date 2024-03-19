import 'package:cached_network_image/cached_network_image.dart';
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
  final firebaseAuth = FirebaseAuth.instance;

  /// `User` object from the Firebase authentication system
  /// or it can be `null` if no user is currently authenticated.
  User? user;

  @override
  void initState() {
    firebaseAuth.authStateChanges().listen(
      (account) {
        setState(() {
          user = account!;
        });

        if (user != null) {
          if (kDebugMode) {
            print('Active User ${user!.email!}');
          }
        }
      },
      onError: (e) {
        if (kDebugMode) {
          print('USER ERROR: $e');
        }
      },
    );

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
              imageUrl: userDetails.photoURL!,
              height: 10,
              fit: BoxFit.cover,
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
