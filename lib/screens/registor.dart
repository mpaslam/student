import 'package:finalapp/screens/addstudents.dart';
import 'package:finalapp/screens/listScreen.dart';
import 'package:finalapp/screens/login.dart';
import 'package:finalapp/screens/phonauth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegistrationPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  void _register(BuildContext context) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // User has successfully registered
      print("User registered: ${userCredential.user!.uid}");

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      // Navigate to the login page after successful registration
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    } catch (e) {
      // Handle registration errors
      print("Registration error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("check your email")),
      );
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn _googleSignIn = GoogleSignIn();

      // Sign out of Google
      await _googleSignIn.signOut();

      // Start the Google sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print("Google Sign-In canceled by user.");
        return;
      }

      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final User? user = userCredential.user;

      print('Signed in with Google:');
      print('User ID: ${user?.uid}');
      print('Email: ${user?.email}');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StudentListScreen()),
      );
    } catch (error) {
      print('Sign in with Google failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            "Registration",
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          backgroundColor: Colors.purple[600]),
      body: Padding(
          padding: const EdgeInsets.only(top: 100, left: 30, right: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _register(context);
                },
                child: Text('Register'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginPage()));
                },
                child: Text('Already have an account'),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PhoneAuthScreen(),
                          ));
                    },
                    child: Icon(Icons.phone)),
                SizedBox(
                  width: 20,
                ),
                //       ElevatedButton(
                //           onPressed: () => _signInWithGoogle(context),
                //           child: Image.network(
                //     'http://pngimg.com/uploads/google/google_PNG19635.png',
                //     fit:BoxFit.cover
                // )               )
                InkWell(
                    onTap: () {
                      _signInWithGoogle(context);

                      print('Avatar pressed!');
                    },
                    child: const CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage(
                          'http://pngimg.com/uploads/google/google_PNG19635.png',
                        )))
              ])
            ],
          )),
    );
  }
}
