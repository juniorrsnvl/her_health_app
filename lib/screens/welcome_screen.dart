import 'package:flutter/material.dart';
import 'onboarding_screen.dart';



class WelcomeScreen extends StatelessWidget {

  const WelcomeScreen({super.key});



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Stack(

        fit: StackFit.expand,

        children: [


          // Background image (clear - no blur)
          Container(color: const Color(0xFFFAF6F3), width: double.infinity, height: double.infinity),



          // Soft overlay
          Container(

            color: Colors.white.withOpacity(0.20),

          ),




          // Main content
          Center(

            child: Column(

              mainAxisAlignment: MainAxisAlignment.center,

              children: [



                // Logo
                Image.asset(

                  'assets/images/logo/logo.png',

                  height: 180,

                ),



                const SizedBox(height: 40),



                const Text(

                  "Her Health",

                  style: TextStyle(

                    fontSize: 42,

                    fontWeight: FontWeight.bold,

                    color: Color(0xFF6E7B5F),

                    letterSpacing: 1,

                  ),

                ),



                const SizedBox(height: 15),



                const Text(

                  "Your wellness journey starts here",

                  textAlign: TextAlign.center,

                  style: TextStyle(

                    fontSize: 18,

                    color: Color(0xFF6E7B5F),

                  ),

                ),



                const SizedBox(height: 50),




                ElevatedButton(

                  style: ElevatedButton.styleFrom(

                    backgroundColor: const Color(0xFFB04F6C),


                    padding: const EdgeInsets.symmetric(

                      horizontal: 45,

                      vertical: 15,

                    ),



                    shape: RoundedRectangleBorder(

                      borderRadius: BorderRadius.circular(30),

                    ),


                  ),



                  onPressed: () {


                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (context) =>

                            const OnboardingScreen(),

                      ),

                    );


                  },



                  child: const Text(

                    "Get Started",

                    style: TextStyle(

                      fontSize: 18,

                      color: Colors.white,

                    ),

                  ),


                ),


              ],


            ),


          ),


        ],


      ),


    );


  }


}