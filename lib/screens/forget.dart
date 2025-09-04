import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {

  
   TextEditingController email = TextEditingController();

  reset()async{
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Email Sent to change your password ✅ '),margin: EdgeInsets.all(20),padding: EdgeInsets.all(20),behavior: SnackBarBehavior.floating,) 
    );
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error : $e ❌'),margin: EdgeInsets.all(20),padding: EdgeInsets.all(20),behavior: SnackBarBehavior.floating,) 
    );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(title: Text('Forget Password'),),
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
              margin: EdgeInsets.only(top: 20),
              child: ElevatedButton(onPressed: (()=>reset()), child: Text('Send Link'))
              ),
          ], 
        ),
      ),
    );
  }
}