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
          backgroundColor: Colors.black,

          appBar: AppBar(
            backgroundColor: Colors.black,
              title: Icon(Icons.circle, color: Colors.orange), // el logo de app
                actions: [
              IconButton(icon: Icon(Icons.cast), color: Colors.white, onPressed: () {}), //icono cast
              IconButton(icon: Icon(Icons.search), color: Colors.white, onPressed: () {}), //icono buscar
            ],
          ),

        body: ListView(
            children: [

              Container(
                padding: const EdgeInsets.all(16.0), //16 pixeles base de todos los lados
                color: Colors.black,
                child: Text(
                  'Tendencias en Chile',
                style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                ),
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

                color: const Color.fromARGB(255, 0, 0, 0),

              //este es el row, integra los 3 container en columna
               child: Row(
                  children: [

                    //AQUI CONTENIDO serie 1
                    Expanded(

                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, //tiro hacia la izquierda
                      children: [
                        
                        Container(
                         color: const Color.fromARGB(255, 208, 91, 1),
                         height: 300, // altura del rectángulo naranja
                         width: double.infinity,
                        ),

                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                      child: Text(
                       'Serie 1',
                      style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255), 
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      ),
                      ),
                    ),

                       ],
                     ),
                    ),

                    SizedBox(width: 8.0), //esto es apra crear una epsecia de gap entre los container

                   //AQUI CONTENIDO serie 2
                    Expanded(

                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, //tiro hacia la izquierda
                      children: [
                        
                        Container(
                         color: const Color.fromARGB(255, 208, 91, 1),
                         height: 300, // altura del rectángulo naranja
                         width: double.infinity,
                        ),

                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                      child: Text(
                       'Serie 2',
                      style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255), 
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      ),
                      ),
                    ),

                       ],
                     ),
                    ),

                    SizedBox(width: 8.0),

                   //AQUI CONTENIDO serie 3
                    Expanded(

                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, //tiro hacia la izquierda
                      children: [
                        
                        Container(
                         color: const Color.fromARGB(255, 208, 91, 1),
                         height: 300, // altura del rectángulo naranja
                         width: double.infinity,
                        ),

                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                        child: Text(
                          'Serie 3',
                         style: TextStyle(
                         color: Colors.white, 
                         fontSize: 16,
                         fontWeight: FontWeight.w400,
                         ),
                        ),
                      ),


                       ],
                     ),
                    ),


                  ],
               ),
              ),

               SizedBox(height: 8.0), //esto es apra crear una epsecia de gap entre los container
            
              Container(
                padding: const EdgeInsets.all(16.0), //16 pixeles base de todos los lados
                color: Colors.black,
                child: Text(
                  'Doblajes en español añadidos recientemente',
                style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                ),
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

                color: const Color.fromARGB(255, 0, 0, 0),

              //este es el row, integra los 3 container en columna
               child: Row(
                  children: [

                    //AQUI CONTENIDO serie 1
                    Expanded(

                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, //tiro hacia la izquierda
                      children: [
                        
                        Container(
                         color: const Color.fromARGB(255, 208, 91, 1),
                         height: 300, // altura del rectángulo naranja
                         width: double.infinity,
                        ),

                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                      child: Text(
                       'Serie 4',
                      style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255), 
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      ),
                      ),
                    ),

                       ],
                     ),
                    ),

                    SizedBox(width: 8.0), //esto es apra crear una epsecia de gap entre los container

                   //AQUI CONTENIDO serie 2
                    Expanded(

                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, //tiro hacia la izquierda
                      children: [
                        
                        Container(
                         color: const Color.fromARGB(255, 208, 91, 1),
                         height: 300, // altura del rectángulo naranja
                         width: double.infinity,
                        ),

                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                      child: Text(
                       'Serie 5',
                      style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255), 
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      ),
                      ),
                    ),

                       ],
                     ),
                    ),

                    SizedBox(width: 8.0),

                   //AQUI CONTENIDO serie 3
                    Expanded(

                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, //tiro hacia la izquierda
                      children: [
                        
                        Container(
                         color: const Color.fromARGB(255, 208, 91, 1),
                         height: 300, // altura del rectángulo naranja
                         width: double.infinity,
                        ),

                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                        child: Text(
                          'Serie 6',
                         style: TextStyle(
                         color: Colors.white, 
                         fontSize: 16,
                         fontWeight: FontWeight.w400,
                         ),
                        ),
                      ),


                       ],
                     ),
                    ),


                  ],
               ),
              ),
            

            ],
          
        ),

              bottomNavigationBar: BottomNavigationBar(
                backgroundColor: Colors.black,
                selectedItemColor: Colors.orange,
                unselectedItemColor: Colors.white,
                type: BottomNavigationBarType.fixed, //respetame el color
                   items: [
                     BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
                     BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Mis listas'),
                     BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Explorar'),
                     BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Simulcasts'),
                     BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cuenta'),
                   ],
                  currentIndex: 0, //define el primero de la lsita siendo 0 el primero que es inicio
                  ),

      ),
    );
  }
}