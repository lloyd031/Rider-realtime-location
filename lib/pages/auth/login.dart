import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rider_realtime_location/pages/loading.dart';
import 'package:rider_realtime_location/services/apiService.dart';

class LogIn extends StatefulWidget {
  final Function switchAuth;
  final Function login;
  const LogIn({super.key, required this.switchAuth, required this.login});
  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final auth = Apiservice();

  final _formKey = GlobalKey<FormState>();
  String error = " ";
  bool loading = false;
  String uname = "";
  String pw = "";

  @override
  Widget build(BuildContext context) {
    return (loading == true)
        ? Scaffold(
          body: Container(
            height: double.maxFinite,
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Loading()],
            ),
          ),
        )
        : Scaffold(
          body: SafeArea(
            child: Padding(
              
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Let's Sign you in",
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        color: Color.fromRGBO(51, 51, 51, 1),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    "Sign in and start your ride.",
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
                          decoration: InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (val) {
                            setState(() {
                              uname = val;
                            });
                          },
                          validator: (val) => val!.isEmpty ? "Rquired" : null,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (val) {
                            setState(() {
                              pw = val;
                            });
                          },
                          validator: (val) => val!.isEmpty ? "Rquired" : null,
                          obscureText: true,
                        ),
                        
                        Text(error, style: TextStyle(color: Colors.red)),
                        
                       
                        SizedBox(height: 8,),
                        InkWell(
                          
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                loading = true;
                              });
                              dynamic result = await auth.login(uname, pw);
                              if (result == null) {
                                setState(() {
                                  error = "Invalid email or password";
                                  loading = false;
                                });
                                ;
                              } else {
                                widget.login();
                              }
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
                      "Sign in",
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
                      "Dont have an account ?",
                      style: GoogleFonts.inter(
                        textStyle: TextStyle(
                          color: Color.fromRGBO(51, 51, 51, 1),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                            TextButton(onPressed:(){widget.switchAuth();}, child:Text("Signup")),
                          ],
                        ),
                        
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
  }
}
