import 'package:flutter/material.dart';
import 'email_verification_screen.dart';



class RegisterScreen extends StatefulWidget {

  const RegisterScreen({super.key});


  @override
  State<RegisterScreen> createState() => _RegisterScreenState();

}



class _RegisterScreenState extends State<RegisterScreen> {


  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();


  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  final TextEditingController emergencyNameController = TextEditingController();
  final TextEditingController emergencyPhoneController = TextEditingController();


  final TextEditingController bloodController = TextEditingController();
  final TextEditingController allergyController = TextEditingController();
  final TextEditingController conditionController = TextEditingController();
  final TextEditingController medicationController = TextEditingController();



  Widget inputField(
      String label,
      IconData icon,
      TextEditingController controller,
      {
        bool password = false
      }
      ) {


    return Padding(

      padding: const EdgeInsets.symmetric(vertical: 8),

      child: TextField(

        controller: controller,

        obscureText: password,


        decoration: InputDecoration(

          labelText: label,


          prefixIcon: Icon(

            icon,

            color: const Color(0xFF959B7D),

          ),



          filled: true,


          fillColor: Colors.white,



          border: OutlineInputBorder(

            borderRadius: BorderRadius.circular(20),

            borderSide: BorderSide.none,

          ),


        ),


      ),


    );


  }





  Widget sectionTitle(String text) {


    return Padding(

      padding: const EdgeInsets.only(
        top: 25,
        bottom: 10,
      ),


      child: Text(


        text,


        style: const TextStyle(

          fontSize: 22,

          fontWeight: FontWeight.bold,

          color: Color(0xFF959B7D),

        ),


      ),


    );


  }






  @override
  Widget build(BuildContext context) {


    return Scaffold(


      body: Stack(


        children: [



          Image.asset(

            'assets/images/backgrounds/background.jpeg',

            fit: BoxFit.cover,

            height: double.infinity,

            width: double.infinity,


          ),





          Container(

            color: Colors.white.withOpacity(0.25),

          ),






          SafeArea(


            child: SingleChildScrollView(


              padding: const EdgeInsets.all(25),


              child: Column(


                children: [





                  Image.asset(

                    'assets/images/logo/logo.png',

                    height: 100,

                  ),





                  const SizedBox(height: 15),






                  const Text(

                    "Create Your Her Health Account 🌸",

                    textAlign: TextAlign.center,


                    style: TextStyle(

                      fontSize: 26,

                      fontWeight: FontWeight.bold,

                      color: Color(0xFF959B7D),

                    ),


                  ),







                  sectionTitle("👤 Personal Information"),




                  inputField(
                    "Full Name",
                    Icons.person,
                    nameController,
                  ),




                  inputField(
                    "Date of Birth",
                    Icons.calendar_today,
                    dobController,
                  ),




                  inputField(
                    "Email Address",
                    Icons.email,
                    emailController,
                  ),




                  inputField(
                    "Phone Number",
                    Icons.phone,
                    phoneController,
                  ),




                  inputField(
                    "Password",
                    Icons.lock,
                    passwordController,
                    password: true,
                  ),





                  inputField(
                    "Confirm Password",
                    Icons.lock_outline,
                    confirmPasswordController,
                    password: true,
                  ),







                  sectionTitle("🏠 Contact Information"),




                  inputField(
                    "Street Address",
                    Icons.home,
                    addressController,
                  ),





                  inputField(
                    "City",
                    Icons.location_city,
                    cityController,
                  ),





                  inputField(
                    "Emergency Contact Name",
                    Icons.contact_phone,
                    emergencyNameController,
                  ),





                  inputField(
                    "Emergency Contact Number",
                    Icons.phone_in_talk,
                    emergencyPhoneController,
                  ),







                  sectionTitle("❤️ Health Information"),




                  inputField(
                    "Blood Type 🩸",
                    Icons.bloodtype,
                    bloodController,
                  ),




                  inputField(
                    "Allergies ⚠️",
                    Icons.warning,
                    allergyController,
                  ),




                  inputField(
                    "Medical Conditions",
                    Icons.medical_information,
                    conditionController,
                  ),




                  inputField(
                    "Current Medication 💊",
                    Icons.medication,
                    medicationController,
                  ),








                  const SizedBox(height:30),







                  SizedBox(

                    width: double.infinity,

                    height:55,



                    child: ElevatedButton(


                      style: ElevatedButton.styleFrom(


                        backgroundColor:
                        const Color(0xFFE89CB0),



                        shape: RoundedRectangleBorder(

                          borderRadius:
                          BorderRadius.circular(30),

                        ),


                      ),






                      onPressed: (){


                        Navigator.push(


                          context,


                          MaterialPageRoute(


                            builder: (context)=> 
                            EmailVerificationScreen(

                              email: emailController.text.isEmpty

                              ? "name@gmail.com"

                              : emailController.text,


                            ),


                          ),


                        );



                      },







                      child: const Text(


                        "Create Account 🌸",


                        style: TextStyle(

                          color: Colors.white,

                          fontSize:18,

                          fontWeight: FontWeight.bold,

                        ),


                      ),


                    ),


                  ),




                ],


              ),


            ),


          )



        ],


      ),


    );


  }


}