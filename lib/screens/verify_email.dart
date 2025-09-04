import 'package:coffee_shop/screens/wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  @override
  void initState(){
    sendverifylink();
    super.initState();
  }

  sendverifylink() async{
    final user = FirebaseAuth.instance.currentUser!;
    await user.sendEmailVerification().then((value) =>
    Get.snackbar('Link Sent', 'A link has been sent to your email !',snackPosition: SnackPosition.BOTTOM)
    );
  }

  reload() async{
    await FirebaseAuth.instance.currentUser!.reload().then((value)=> Get.offAll(Wrapper()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Email Verification'),),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text('Open Your email and check on the link provided to verify email & reload this page'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (()=>reload()),
          child: Icon(Icons.restart_alt_rounded),
          ),
    );
  }
}