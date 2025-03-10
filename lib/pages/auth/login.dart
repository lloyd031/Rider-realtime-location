
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rider_realtime_location/pages/loading.dart';
import 'package:rider_realtime_location/services/auth.dart';
import 'package:rider_realtime_location/pages/startpage.dart';

class LogIn extends StatefulWidget {
  final Function switchAuth;
  const LogIn({super.key, required this.switchAuth});
  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final  auth=AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey=GlobalKey<FormState>();
  String error=" ";
  bool loading=false;
  @override
  void dispose() {
    // TODO: implement dispose
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    
    return (loading==true)?Loading() :Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Expanded(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val)=>val!.isEmpty?"Rquired":null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val)=>val!.isEmpty?"Rquired":null,
                  obscureText: true,
                ),
                SizedBox(height: 16),
                Text(error , style: TextStyle(color: Colors.red),),
                SizedBox(height: 16),
                TextButton(onPressed:(){widget.switchAuth();}, child:Text("Signup instead")),
                  SizedBox(height: 16),
                ElevatedButton(
                  onPressed: ()async{
                    if(_formKey.currentState!.validate()){
                        setState(() {
                          loading=true;
                        });
                        dynamic result= await auth.signIn(emailController.text, passwordController.text);
                        if(result==null){
                          setState(() {
                             error="Invalid email or password";
                             loading=false;
                          });;
                        }else{}
                    }
                  },
                  child: Text('Log In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
