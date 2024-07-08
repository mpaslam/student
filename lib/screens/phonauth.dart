import 'package:finalapp/screens/addstudents.dart';
import 'package:finalapp/screens/listScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class PhoneAuthScreen extends StatefulWidget {
  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _verificationId = '';

  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'US');

  Future<void> _verifyPhoneNumber(BuildContext context) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: _phoneNumber.phoneNumber!,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Automatically handle verification if the phone number can be verified without user intervention.
        // For example, in case of re-installing the app on the same device.
        //await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Verification Failed: ${e.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "The phone nuber was incorrect ! plase enter correct one."),
          ),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPScreen(
              verificationId: _verificationId,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phone Auth'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber number) {
                setState(() {
                  _phoneNumber = number;
                });
              },
              onInputValidated: (bool value) {},
              selectorConfig: SelectorConfig(
                selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
              ),
              hintText: 'Enter Phone Number',
            ),
            ElevatedButton(
              onPressed: () => _verifyPhoneNumber(context),
              child: Text('Send OTP'),
            ),
          ],
        ),
      ),
    );
  }
}

class OTPScreen extends StatelessWidget {
  final String verificationId;

  OTPScreen({required this.verificationId});

  @override
  Widget build(BuildContext context) {
    String _smsCode = '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Enter OTP'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: (value) {
                _smsCode = value;
              },
              decoration: InputDecoration(
                hintText: 'Enter OTP',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _signInWithPhoneNumber(context, _smsCode);
              },
              child: Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signInWithPhoneNumber(
      BuildContext context, String smsCode) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    try {
      await _auth.signInWithCredential(credential);
      print('Successfully signed in');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StudentListScreen(),
        ),
      );
    } catch (e) {
      print('Error signing in: $e');
    }
  }
}
