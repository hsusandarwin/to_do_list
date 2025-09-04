import 'package:coffee_shop/screens/home.dart';
import 'package:coffee_shop/screens/login.dart';
import 'package:coffee_shop/screens/verify_email.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(), 
        builder: (context,snapshot){
          if(snapshot.hasData){
            if(snapshot.data!.emailVerified){
              return Home();
            }else{
              return VerifyEmail();
            }
            
          }else{
            return Login();
          }
        }
        ),
    );
  }
}