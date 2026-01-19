// ignore_for_file: prefer_const_constructors, sort_child_properties_last, file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, //change your color
        ),
        backgroundColor: Colors.black,
        title: const Text(
          "Forgot Password",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    "Forgot Password",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Please enter your email and we will send \nyou a link to return to your account",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                  // const SizedBox(height: 16),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                  const ForgotPasswordForm(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),

                  // const NoAccountText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const authOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFF757575)),
  borderRadius: BorderRadius.all(Radius.circular(100)),
);

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final TextEditingController _emailController = TextEditingController();
  String? _message;

  forgetpw() async {
    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: _emailController.text);
  }

  void _resetPassword() {
    // final email = _emailController.text;

    // Simulate a password reset process
    if (_emailController.text.isNotEmpty) {
      setState(() {
        // _message = 'Password reset link sent to ${_emailController.text}';
        Get.snackbar(
            "Message", "Password reset link sent to ${_emailController.text}",
            colorText: Colors.white);
        forgetpw();
      });
    } else {
      setState(() {
        // _message = 'Please enter your email';
        Get.snackbar("Message", "Please enter your Email",
            colorText: Colors.white);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            style: TextStyle(
              color: Colors.white,
            ),
            controller: _emailController,
            onSaved: (email) {},
            onChanged: (email) {},
            decoration: InputDecoration(
                hintText: "Enter your email",
                labelText: "Email",
                labelStyle: TextStyle(color: Colors.white),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintStyle: const TextStyle(color: Colors.white),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                // suffix: SvgPicture.string(
                //   // mailIcon,
                // ),
                border: authOutlineInputBorder,
                enabledBorder: authOutlineInputBorder,
                focusedBorder: authOutlineInputBorder.copyWith(
                    borderSide: const BorderSide(color: Color(0xFFFF7643)))),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          ElevatedButton(
            onPressed: (() => _resetPassword()),
            child: Text('Send Reset Link'),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFFFF7643),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
          ),
          SizedBox(height: 20),
          if (_message != null)
            Text(
              _message!,
              style: TextStyle(color: Colors.white),
            ),
        ],
      ),
    );
  }
}
