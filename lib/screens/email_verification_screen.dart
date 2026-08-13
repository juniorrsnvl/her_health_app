import 'package:flutter/material.dart';


class EmailVerificationScreen extends StatefulWidget {

  final String email;

  const EmailVerificationScreen({
    super.key,
    required this.email,
  });


  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();

}



class _EmailVerificationScreenState 
    extends State<EmailVerificationScreen> {


  final List<TextEditingController> codeControllers =
      List.generate(
        6,
        (index) => TextEditingController(),
      );



  Widget codeBox(int index) {


    return SizedBox(

      width: 45,

      height: 55,


      child: TextField(


        controller: codeControllers[index],


        textAlign: TextAlign.center,


        keyboardType: TextInputType.number,


        maxLength: 1,


        decoration: InputDecoration(


          counterText: "",


          filled: true,


          fillColor: Colors.white,


          border: OutlineInputBorder(

            borderRadius: BorderRadius.circular(15),

            borderSide: BorderSide.none,

          ),


        ),


      ),


    );


  }



  @override
  Widget build(BuildContext context) {


    return Scaffold(


      body: Stack(


        fit: StackFit.expand,


        children: [


          Image.asset(

            'assets/images/backgrounds/background.jpeg',

            fit: BoxFit.cover,

          ),




          Container(

            color: Colors.white.withOpacity(0.25),

          ),





          Center(


            child: SingleChildScrollView(


              padding: const EdgeInsets.all(25),


              child: Column(


                children: [



                  Image.asset(

                    'assets/images/logo/logo.png',

                    height: 130,

                  ),




                  const SizedBox(height: 25),





                  const Text(

                    "Verify Your Email 💌",

                    style: TextStyle(

                      fontSize: 30,

                      fontWeight: FontWeight.bold,

                      color: Color(0xFF959B7D),

                    ),

                  ),




                  const SizedBox(height: 20),




                  const Text(

                    "We've sent a verification code to:",

                    textAlign: TextAlign.center,

                    style: TextStyle(

                      fontSize: 17,

                      color: Colors.black87,

                    ),

                  ),





                  const SizedBox(height: 8),




                  Text(

                    widget.email,

                    style: const TextStyle(

                      fontSize: 18,

                      fontWeight: FontWeight.bold,

                      color: Color(0xFFE89CB0),

                    ),

                  ),




                  const SizedBox(height: 35),





                  Row(


                    mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,


                    children: [


                      codeBox(0),

                      codeBox(1),

                      codeBox(2),

                      codeBox(3),

                      codeBox(4),

                      codeBox(5),


                    ],


                  ),





                  const SizedBox(height: 40),






                  SizedBox(


                    width: 280,


                    height: 55,



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


                        // Backend verification will be added here



                        ScaffoldMessenger.of(context)
                            .showSnackBar(

                          const SnackBar(

                            content:
                            Text(
                              "Email verified successfully 🌸"
                            ),

                          ),

                        );


                      },



                      child: const Text(

                        "Verify Email",

                        style: TextStyle(

                          color: Colors.white,

                          fontSize: 18,

                          fontWeight: FontWeight.bold,

                        ),

                      ),


                    ),


                  ),





                  const SizedBox(height: 20),





                  TextButton(


                    onPressed: (){


                      // Backend resend code


                    },


                    child: const Text(

                      "Resend Code 🔄",

                      style: TextStyle(

                        color: Color(0xFF959B7D),

                        fontSize: 16,

                        fontWeight: FontWeight.bold,

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