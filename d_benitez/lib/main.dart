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
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),

          

        body: ListView(
            children: [

              Container(
                margin: const EdgeInsets.symmetric(
                horizontal: 16.0
                ), 
                height: 50,
                width: double.infinity,
                color: const Color.fromARGB(255, 202, 201, 201),
                child: const Center(
                  child: Text(
                    'navegador',
                    style: TextStyle(
                      color: Color.fromARGB(255, 8, 8, 8),
                      fontSize: 24,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.0),

              //este conteiner almacena el row para las los buscadores
              Container(
                
                width: double.infinity,

                // espacio exterior horizontal
                margin: const EdgeInsets.symmetric(
                horizontal: 16.0
                ),  // aqui puse margin en el container 2

                color: const Color.fromARGB(255, 255, 255, 255),

              //este es el row, integra los 3 container en columna
               child: Row(
                
                  children: [
                    
                    //buscador 1
                    Expanded(

                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, //tiro hacia la izquierda
                      children: [
                        
                        Container(
                height: 50,
                width: double.infinity,
                color: const Color.fromARGB(255, 189, 189, 190),
                child: const Center(
                  child: Text(
                    'Buscador 1',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

                       ],
                     ),
                    ),

                    SizedBox(width: 8.0), //esto es para crear una espacio de gap entre los container

                   //buscador 2
                    Expanded(

                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, //tiro hacia la izquierda
                      children: [
                        
                        Container(
                height: 50,
                width: double.infinity,
                color: const Color.fromARGB(255, 189, 189, 190),
                child: const Center(
                  child: Text(
                    'Buscador 2',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

                       ],
                     ),
                    ),

                    SizedBox(width: 8.0),

                    //buscador 3
                    Expanded(

                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, //tiro hacia la izquierda
                      children: [
                        
                        Container(
                height: 50,
                width: double.infinity,
                color: const Color.fromARGB(255, 189, 189, 190),
                child: const Center(
                  child: Text(
                    'Buscador 3',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

                       ],
                     ),
                    ),

                    SizedBox(width: 8.0),

                //buscador 4
                   Expanded(

                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, //tiro hacia la izquierda
                      children: [
                        
                        Container(
                height: 50,
                width: double.infinity,
                color: const Color.fromARGB(255, 189, 189, 190),
                child: const Center(
                  child: Text(
                    'Buscador 4',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

                       ],
                     ),
                    ),

                SizedBox(width: 8.0),

               //buscador 5
                Expanded(

                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, //tiro hacia la izquierda
                      children: [
                        
                        Container(
                height: 50,
                width: double.infinity,
                color: const Color.fromARGB(255, 189, 189, 190),
                child: const Center(
                  child: Text(
                    'Buscador 5',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 16,
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


            SizedBox(height: 8.0),

              //este conteiner almacena el row
              Container(
                width: double.infinity,

                // espacio exterior horizontal
                margin: const EdgeInsets.symmetric(
                horizontal: 16.0
                ),  // aqui puse margin en el container 2

                color: const Color.fromARGB(255, 255, 255, 255),

              
               child: Row(
                  children: [

                    //RELL 1
                    Expanded(

                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, //tiro hacia la izquierda
                      children: [
                        
                        Container(
                         color: const Color.fromARGB(255, 209, 209, 209),
                         height: 350, // altura del rectángulo naranja
                         width: double.infinity,
                        ),

                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                      child: Text(
                       'Titulo del reel 1',
                      style: TextStyle(
                      color: const Color.fromARGB(255, 3, 3, 3), 
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      ),
                      ),
                    ),

                       ],
                     ),
                    ),

                    SizedBox(width: 8.0), //esto es apra crear una epsecia de gap entre los container

                   //RELL 2
                    Expanded(

                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, //tiro hacia la izquierda
                      children: [
                        
                        Container(
                         color: const Color.fromARGB(255, 209, 209, 209),
                         height: 350, // altura del rectángulo naranja
                         width: double.infinity,
                        ),

                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                      child: Text(
                       'Titulo del reel 2',
                      style: TextStyle(
                      color: const Color.fromARGB(255, 4, 4, 4), 
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      ),
                      ),
                    ),

                       ],
                     ),
                    ),

                    SizedBox(width: 8.0),

                   


                  ],
               ),
              ),

               SizedBox(height: 8.0), //esto es apra crear una epsecia de gap entre los container
            

             

            //este conteiner almacena el row
              Container(
                width: double.infinity,

                // espacio exterior horizontal
                margin: const EdgeInsets.symmetric(
                horizontal: 16.0
                ),  // aqui puse margin en el container 2

                color: const Color.fromARGB(255, 255, 255, 255),

              //este es el row, integra los 3 container en columna
               child: Row(
                  children: [

                    //RELL 3
                    Expanded(

                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, //tiro hacia la izquierda
                      children: [
                        
                        Container(
                         color: const Color.fromARGB(255, 209, 209, 209),
                         height: 350, // altura del rectángulo naranja
                         width: double.infinity,
                        ),

                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                      child: Text(
                       'Titulo del reel 3',
                      style: TextStyle(
                      color: const Color.fromARGB(255, 0, 0, 0), 
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      ),
                      ),
                    ),

                       ],
                     ),
                    ),

                    SizedBox(width: 8.0), //esto es apra crear una epsecia de gap entre los container

                   //RELL 4
                    Expanded(

                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, //tiro hacia la izquierda
                      children: [
                        
                        Container(
                         color: const Color.fromARGB(255, 209, 209, 209),
                         height: 350, // altura del rectángulo naranja
                         width: double.infinity,
                        ),

                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                      child: Text(
                       'Titulo del reel 4',
                      style: TextStyle(
                      color: const Color.fromARGB(255, 0, 0, 0), 
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      ),
                      ),
                    ),

                       ],
                     ),
                    ),

                    SizedBox(width: 8.0),

                  
                  ],
               ),
              ),


              //utimo row   que me ayudara al scrolling
              Container(
                width: double.infinity,

                // espacio exterior horizontal
                margin: const EdgeInsets.symmetric(
                horizontal: 16.0
                ),  // aqui puse margin en el container 2

                color: const Color.fromARGB(255, 255, 255, 255),

              //este es el row, integra los 3 container en columna
               child: Row(
                  children: [

                    //RELL 3
                    Expanded(

                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, //tiro hacia la izquierda
                      children: [
                        
                        Container(
                         color: const Color.fromARGB(255, 209, 209, 209),
                         height: 350, // altura del rectángulo naranja
                         width: double.infinity,
                        ),

                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                      child: Text(
                       'Titulo del reel 3',
                      style: TextStyle(
                      color: const Color.fromARGB(255, 0, 0, 0), 
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      ),
                      ),
                    ),

                       ],
                     ),
                    ),

                    SizedBox(width: 8.0), //esto es apra crear una epsecia de gap entre los container

                   //RELL 4
                    Expanded(

                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, //tiro hacia la izquierda
                      children: [
                        
                        Container(
                         color: const Color.fromARGB(255, 209, 209, 209),
                         height: 350, // altura del rectángulo naranja
                         width: double.infinity,
                        ),

                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                      child: Text(
                       'Titulo del reel 4',
                      style: TextStyle(
                      color: const Color.fromARGB(255, 0, 0, 0), 
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      ),
                      ),
                    ),

                       ],
                     ),
                    ),

                    SizedBox(width: 8.0),

                  
                  ],
               ),
              ),
            

            ],
          
        ),

              

      ),
    );
  }
}