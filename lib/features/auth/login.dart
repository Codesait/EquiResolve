import 'package:equiresolve/app/color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: AppColors.primary,
        body: Container(
          height: size.height,
          width: size.width,
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
                  dimension: 20,
                ),


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
    super.key,
  });
  final String authType;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 200,
      child: Row(
        children: [
          
        ],
      ),
    );
  }
}
