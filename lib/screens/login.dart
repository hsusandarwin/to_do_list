import 'package:coffee_shop/screens/forget.dart';
import 'package:coffee_shop/screens/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  bool isloading = false;

  signIn() async{
    setState(() {
      isloading =true;
    });
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.text, password: password.text);
      Get.snackbar('Singin Successful ✅',' ',backgroundColor: Colors.green.shade300,);
    }on FirebaseAuthException catch(e){
      String message = "Error: ${e.code}";

    if (e.code == 'invalid-credential') {
      message = "You are not registered ❌";
    } else if (e.code == 'user-not-found') {
      message = "No account found for this email ❌";
    } else if (e.code == 'wrong-password') {
      message = "Incorrect password ❌";
    }

    Get.snackbar(
      'Error Message',
      message,
      backgroundColor: Colors.red.shade300,
    );
    }catch (e){
      Get.snackbar('Error Message', e.toString(),backgroundColor: Colors.red.shade300);
    }
    setState(() {
      isloading = false;
    });
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();

login() async {
  try {
    await _googleSignIn.signOut();

    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    // ignore: unnecessary_null_comparison
    if(userCredential != null && (userCredential.user!.displayName == null || userCredential.user!.displayName!.isEmpty)){
      await userCredential.user!.updateDisplayName(googleUser.displayName);
      await userCredential.user!.reload();
    }

    Get.snackbar('Singin Successful ✅',' ',backgroundColor: Colors.green.shade300,);
    return userCredential;
  } catch (e) {
    Get.snackbar("Error", e.toString());
    return null;
  }
}

  @override
  Widget build(BuildContext context) {
    return isloading?Center(child: CircularProgressIndicator(),) : Scaffold(
      appBar: AppBar(title: Text('Login'),),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 10.0),
              child: TextField(
                decoration: InputDecoration(border: OutlineInputBorder(),labelText: 'Enter Email....'),
                controller: email,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 30.0),
              child: TextField(
                decoration: InputDecoration(border: OutlineInputBorder(),labelText: 'Enter Password...'),
                controller: password,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              child: ElevatedButton(onPressed: (()=>signIn()), child: Text('Login'))
              ),
              Container(
              margin: EdgeInsets.only(top: 20),
              child: ElevatedButton(onPressed: (()=>Get.to(SignUp())), child: Text('Register Now'))
              ),
              Container(
              margin: EdgeInsets.only(top: 20),
              child: TextButton(onPressed: (()=>Get.to(ForgetPassword())), child: Text('Forget Password'))
              ),
              Container(
              margin: EdgeInsets.only(top: 20),
              child: IconButton(onPressed: (()=>login()), icon: FaIcon(FontAwesomeIcons.google,color: Colors.red,))
              ),
          ],
        ),
      ),
    );
  }
}