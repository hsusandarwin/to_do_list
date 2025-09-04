// import 'package:coffee_shop/screens/verify_email.dart';
import 'package:coffee_shop/screens/wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

   TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController name = TextEditingController();


  signUp() async{
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email.text, password: password.text);
    await userCredential.user!.updateDisplayName(name.text.trim());
    Get.offAll(Wrapper());
    Get.snackbar('Singin Successful ✅',' ',backgroundColor: Colors.green.shade300,);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(title: Text('Sign Up'),),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 10.0),
              child: TextField(
                decoration: InputDecoration(border: OutlineInputBorder(),labelText: 'Enter Your Name....'),
                controller: name,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 30.0),
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
              child: ElevatedButton(onPressed: (()=>signUp()), child: Text('Sign Up'))
              ),
          ], 
        ),
      ),
    );
  }
}