
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rider_realtime_location/pages/loading.dart';
import 'package:rider_realtime_location/services/auth.dart';
import 'package:rider_realtime_location/pages/startpage.dart';

class SignUp extends StatefulWidget {
  final Function switchAuth;
  const SignUp({super.key, required this.switchAuth});
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final  auth=AuthService();
  final TextEditingController fnameController = TextEditingController();
  final TextEditingController lnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey=GlobalKey<FormState>();
  String error= "";
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
    return(loading==true)?Loading(): Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: fnameController,
                  decoration: InputDecoration(
                    labelText: 'First name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val)=>val!.isEmpty?"Rquired":null,
                  keyboardType: TextInputType.name,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: lnameController,
                  decoration: InputDecoration(
                    labelText: 'Last name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val)=>val!.isEmpty?"Rquired":null,
                  keyboardType: TextInputType.name,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val)=>val!.isEmpty?"Rquired":null,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val)=>(val!.length<6)?"Password must be at least 6 characters long":null,
                  obscureText: true,
                ),
                SizedBox(height: 16),
                Text(error , style: TextStyle(color: Colors.red),),
                SizedBox(height: 16),
                TextButton(onPressed:(){widget.switchAuth();}, child:Text("Login instead")),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: ()async{
                    //_signUp 
                      if(_formKey.currentState!.validate()){
                        setState(() {
                          loading=true;
                        });
                        dynamic result= await auth.signUp(emailController.text, passwordController.text,fnameController.text,lnameController.text);
                        if(result==null){
                          setState(() {
                             error="Invallid email";
                             loading=false;
                          });
                        }else{}
                    }
                    
                  },
                  child: Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}