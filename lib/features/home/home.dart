import 'dart:ui';

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
    TextEditingController passwordController = TextEditingController();
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
        onPressed: () {
          showModalBottomSheet(
            backgroundColor: Colors.blue,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(0.0)),
              ),
              constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.6),
              context: context, builder: (BuildContext context){
            return  Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              height: size.height * .7,
              width: size.width,
              color: Colors.white,
              padding:const EdgeInsets.symmetric(horizontal: 20),
              child:  Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Report', style: GoogleFonts.poppins(color: Colors.black, fontSize:20, fontWeight: FontWeight.bold),),
                      IconButton(onPressed: (){Navigator.pop(context);}, icon: const Icon(Icons.cancel_sharp))
                    ],
                  ),
                  const SizedBox(height: 20.0,),
                  CustomTextField(
                    controller: passwordController,
                    hintText: 'Title',
                  ),
                  const SizedBox(height: 20.0,),
                  CustomTextField(
                    controller: passwordController,
                    hintText: 'Description (optional)',
                    maxLines: 10,
                  ),
                  const SizedBox(height: 20.0,),
                  CustomTextField(
                    controller: passwordController,
                    prefix: const Icon(Icons.location_on),
                    hintText: 'location picked'
                  ),
                  const SizedBox(height: 20.0,),
                  Container(
                    height: 50,
                    width: size.width / 1.2,
                    decoration: BoxDecoration(color: Colors.purple,borderRadius: BorderRadius.circular(15)),
                    child: Center(child: Text('Submit report', style: GoogleFonts.poppins(color:Colors.white,fontSize: 15, fontWeight: FontWeight.bold),)),
                  )
                ],

              ),
            ),
          );
            },
              isScrollControlled: true
          );
        },
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


class CustomTextField extends StatelessWidget {

  const CustomTextField({
    Key? key,
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
    this.fontSize
  }) : super(key: key);
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
      style:  Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: fontSize ?? 14),
      keyboardType: inputType,
      cursorColor: Colors.grey,
      decoration: InputDecoration(
          hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
              fontSize: fontSize ?? 14
          ),
          counterStyle: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500
          ),
          hintText: hintText,
          prefixIcon: prefix,
          prefixIconColor: prefixColor ?? MaterialStateColor.resolveWith(
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
          enabledBorder:  OutlineInputBorder(
            borderSide: BorderSide(color: Colors.purple.withOpacity(.5), width: 1.0),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          focusedBorder:  OutlineInputBorder(
            borderSide: readOnly || maxLength != null ? BorderSide.none : const BorderSide(color: Colors.purple, width: 2.0),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          filled: true,
          fillColor: fillColor ?? Colors.white),
    );
  }
}