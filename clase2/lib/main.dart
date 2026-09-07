import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(

        body: ListView(
            children: [

              Container(
                height: 200,
                width: double.infinity,
                color: const Color.fromARGB(255, 10, 10, 10),
                child: const Center(
                  child: Text(
                    'Container 1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),

            SizedBox(height: 8.0),

              Container(
                height: 400,
                width: double.infinity,

                // espacio exterior horizontal
                margin: const EdgeInsets.symmetric(
                horizontal: 16.0
                ),  // aqui puse margin en el container 2

                color: const Color.fromARGB(255, 255, 255, 255),


               child: Row(
                  children: [

                    //AQUI CONTENIDO IZQUIERDO
                    Expanded(
                      child: Container(
                        color: Colors.red,

                        child: const Center(
                        child: Text(
                          'Izquierda',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 8.0), //esto es apra crear una epsecia de gap entre los container

                   //AQUI CONTENIDO DERECHA
                    Expanded(
                      child: Container(
                        color: Colors.blue,

                        child: const Center(
                          child: Text(
                            'Derecha',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                    ),

                  ],
               ),
              ),
            

            

            ],
          
        ),


      ),
    );
  }
}