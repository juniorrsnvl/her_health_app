import 'package:flutter/material.dart';
import 'health_setup_screen.dart';
import 'register_screen.dart';



class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});


  @override
  State<LoginScreen> createState() => _LoginScreenState();

}



class _LoginScreenState extends State<LoginScreen> {


  final emailController = TextEditingController();

  final passwordController = TextEditingController();


  bool hidePassword = true;




  @override
  Widget build(BuildContext context) {


    return Scaffold(


      body: Stack(


        fit: StackFit.expand,


        children: [




          // Background image

          Image.asset(

            'assets/images/backgrounds/background.jpeg',

            fit: BoxFit.cover,

          ),





          // Soft overlay

          Container(

            color: Colors.white.withOpacity(0.25),

          ),





          SafeArea(


            child: Center(


              child: SingleChildScrollView(


                padding: const EdgeInsets.all(25),



                child: Column(



                  children: [





                    Image.asset(


                      'assets/images/logo/logo.png',


                      height:120,


                    ),





                    const SizedBox(height:20),





                    const Text(



                      "Welcome Back 🌸",



                      style:TextStyle(



                        fontSize:32,



                        fontWeight:FontWeight.bold,



                        color:Color(0xFF959B7D),



                      ),



                    ),





                    const SizedBox(height:10),





                    const Text(



                      "Welcome back, Name ❤️",



                      style:TextStyle(



                        fontSize:18,



                        color:Color(0xFF959B7D),



                      ),



                    ),







                    const SizedBox(height:30),







                    Container(



                      padding:const EdgeInsets.all(25),



                      decoration:BoxDecoration(



                        color:Colors.white.withOpacity(0.92),



                        borderRadius:

                        BorderRadius.circular(30),




                        boxShadow:[



                          BoxShadow(



                            color:Colors.black12,



                            blurRadius:15,



                            offset:Offset(0,5),



                          )



                        ],



                      ),





                      child:Column(



                        children:[





                          buildField(



                            "📧 Email Address",



                            emailController,



                            false,



                          ),






                          buildField(



                            "🔒 Password",



                            passwordController,



                            true,



                          ),






                          const SizedBox(height:20),







                          SizedBox(



                            width:double.infinity,



                            height:55,



                            child:ElevatedButton(



                              style:ElevatedButton.styleFrom(



                                backgroundColor:

                                const Color(0xFFE89CB0),




                                shape:RoundedRectangleBorder(



                                  borderRadius:

                                  BorderRadius.circular(30),



                                ),



                              ),





                              onPressed:(){



                                // Backend authentication will be connected later



                                Navigator.push(



                                  context,



                                  MaterialPageRoute(



                                    builder:(context)=>

                                    const HealthSetupScreen(),



                                  ),



                                );



                              },






                              child:const Text(



                                "Login 🌸",



                                style:TextStyle(



                                  color:Colors.white,



                                  fontSize:18,



                                  fontWeight:FontWeight.bold,



                                ),



                              ),



                            ),



                          ),








                          const SizedBox(height:15),







                          TextButton(



                            onPressed:(){



                              // Forgot password backend later



                            },



                            child:const Text(



                              "Forgot Password?",



                              style:TextStyle(



                                color:Color(0xFF959B7D),



                              ),



                            ),



                          ),








                          const Divider(),







                          const Text(



                            "Don't have an account?",



                            style:TextStyle(



                              color:Colors.black54,



                            ),



                          ),







                          const SizedBox(height:10),








                          OutlinedButton(



                            style:OutlinedButton.styleFrom(



                              side:const BorderSide(



                                color:Color(0xFFE89CB0),



                              ),




                              shape:RoundedRectangleBorder(



                                borderRadius:

                                BorderRadius.circular(30),



                              ),



                            ),






                            onPressed:(){



                              Navigator.push(



                                context,



                                MaterialPageRoute(



                                  builder:(context)=>

                                  const RegisterScreen(),



                                ),



                              );



                            },






                            child:const Text(



                              "Create Account",



                              style:TextStyle(



                                color:Color(0xFFE89CB0),



                                fontSize:16,



                              ),



                            ),



                          )





                        ],



                      ),



                    )





                  ],



                ),



              ),



            ),



          )





        ],



      ),



    );



  }







  Widget buildField(



      String label,



      TextEditingController controller,



      bool password



      ){



    return Padding(



      padding:

      const EdgeInsets.only(bottom:15),




      child:TextField(



        controller:controller,



        obscureText:

        password ? hidePassword : false,






        decoration:InputDecoration(



          labelText:label,




          filled:true,



          fillColor:

          Colors.grey.shade100,







          suffixIcon:



          password

              ? IconButton(



            icon:Icon(



              hidePassword

                  ? Icons.visibility_off

                  : Icons.visibility,



              color:

              const Color(0xFF959B7D),



            ),




            onPressed:(){



              setState(() {



                hidePassword = !hidePassword;



              });



            },



          )

              : null,








          border:OutlineInputBorder(



            borderRadius:

            BorderRadius.circular(20),




            borderSide:BorderSide.none,



          ),



        ),



      ),



    );



  }



}