
import 'package:denhoc/components/my_switch_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/brightness2.dart';
import '../components/chart_study.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('My light',style: GoogleFonts.roboto(textStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 32, color: Colors.white)),),

          ],
        ),

        backgroundColor: Colors.blue[400],
        actions: [
          IconButton(onPressed: () {

          }, icon: Icon(Icons.notifications))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14,vertical: 10),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0, top: 10),
                child: Container(
                  height: 310,
                  child: PageView(
                   children: [
                     Container(
                       height: 310,
                       width: double.infinity,
                       decoration: BoxDecoration(
                         color: Colors.white,
                         borderRadius: BorderRadius.circular(14),
                         // boxShadow:
                       ),
                       child: BarChartSample1(),
                     ),
                     Container(height: 200, color: Colors.deepPurpleAccent,),
                   ]

                  ),
                ),
              ),
              SizedBox(height: 15,),

              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  width: double.infinity,
                  // padding: EdgeInsets.all(14),
                  height: 65,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.sunny),

                      MySlider(),
                    ],
                  ),

                  
                ),
              ),

              SizedBox(height: 30,),
              

              // Độ sáng của đèn
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),

                child: Container(
                  padding: EdgeInsets.all(14),
                  height: 85,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.sunny,color: Colors.white,size: 30,)),
                          SizedBox(width: 10,),
                          Text('Độ sáng thích ứng',style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 22), fontWeight: FontWeight.bold, color: Colors.black87),),
                        ],
                      ),
                      MySwitchButton(),
                      // Expanded(child: MySlider()),
                    ],
                  ),
                ),
              ),

              // On/Off light

              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  padding: EdgeInsets.all(14),
                  height: 80,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.lightbulb,color: Colors.white,size: 30,)),
                          SizedBox(width: 10,),
                          Text('Light',style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 24), fontWeight: FontWeight.bold, color: Colors.black),),
                        ],
                      ),
                      MySwitchButton(),
                    ],
                  ),
                ),
              ),



              // On/Off light
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),

                child: Container(
                  padding: EdgeInsets.all(14),
                  height: 85,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.purpleAccent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.restart_alt,color: Colors.white,size: 30,)),
                          SizedBox(width: 10,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Promodo',style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 22), fontWeight: FontWeight.bold, color: Colors.black87),),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('Học: ',style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 16,color: Colors.black87)),),
                                  SizedBox(width: 10,),
                                  Text('Nghỉ: ',style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 16,color: Colors.black87)),),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                      MySwitchButton(),
                    ],
                  ),
                ),
              ),

              // On/Off light
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),

                child: Container(
                  padding: EdgeInsets.all(14),
                  height: 85,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          print('Đặt giờ');
                        },
                        child: Row(
                          children: [
                            Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red[400],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.notifications,color: Colors.white,size: 30,)),
                            SizedBox(width: 10,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Nhắc nhở',style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 24), fontWeight: FontWeight.bold, color: Colors.black87),),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('Time: ',style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 16,color: Colors.black87)),),
                                  ],
                                )
                              ],
                            ),
                          ],
                        )
                      ),
                      MySwitchButton(),
                    ],
                  ),
                ),
              ),

              // Padding(
              //   padding: const EdgeInsets.only(bottom: 8.0),
              //
              //   child: Brigthness(),
              // ),


            ],
          ),
        ),
      ),
    );
  }
}
