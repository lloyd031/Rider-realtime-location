
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return(loading==true)?Scaffold(
        body: Container(
          height: double.maxFinite,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Loading(),
            ],
          ),
        ),
      ): Scaffold(
      
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment:CrossAxisAlignment.start,
                children: [
                  Text(
                      "Create Account",
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: Color.fromRGBO(51, 51, 51, 1),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      "Sign up and take your first ride.",
                      style: GoogleFonts.inter(
                        textStyle: TextStyle(
                          color: Color.fromRGBO(155, 155, 155, 1),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  Form(
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
                        Text(error , style: TextStyle(color: Colors.red),),
                        SizedBox(height:8),
                        
                     
                        InkWell(
                          onTap: ()async{
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
                          child: Container(
                              width: double.maxFinite,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(119, 95, 231, 1.0),
                                borderRadius: BorderRadius.circular(8)
                              ),
                              child: Center(child: Text(
                        "Sign up",
                        style: GoogleFonts.inter(
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),)),
                        ),
                        Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                        "Already have an account ?",
                        style: GoogleFonts.inter(
                          textStyle: TextStyle(
                            color: Color.fromRGBO(51, 51, 51, 1),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                              TextButton(onPressed:(){widget.switchAuth();}, child:Text("Login")),
                            ],
                          )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}