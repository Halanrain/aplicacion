import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          //color fondo
          backgroundColor: const Color(0xFF005293),
          //icono navegación
          leading: IconButton(
            icon: const Icon(Icons.menu),
            color: Colors.white,
            onPressed: () {},
          ),
          //texto barra superios
          title: const Text(
            'Clase uno',
            style: TextStyle(
              color: Colors.white,
            ),
          ),

          //actions permite agregar elementos al aldo derecho de la barra
          actions: [
            //el PopupMenu crea menu desplegado, dentro metemos las opciones
            //el move vert muestra el icono de los 3 puntos
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,        // ícono de tres puntos verticales
                color: Colors.white,
              ),

              //itembuilder contruyes las opciones que tendra el menu
              itemBuilder: (BuildContext context) => [

              //PRIMERA opcion del menu
              const PopupMenuItem<String>(
                value: 'perfil',
                child: Text('Perfil'),
              ),

              //SEGUNDA opcion item del menu
              const PopupMenuItem<String>(
                value: 'configuracion',
                child: Text('Configuración'),
              ),

              //TERCERA opcion item del menu
              const PopupMenuItem<String>(
                value: 'peru',
                child: Text('Peru'),
              ),

    ],
  ),
],
        ),

        body: Column(

            children: [
              
              Container(
                height: 570.0, //altura de 148 pixeles
                width: double.infinity, //ocupa el ancho disponible
                color: Colors.grey, //fondo de color gris
                child: const Text('Tamaño card'),
              ),

              const SizedBox(height: 12.0), // Espacio de 12 píxeles entre los containers
                Container(
                height: 148.0,               // Altura de 148 píxeles
                width: double.infinity,      // Ocupa todo el ancho disponible
                color: Colors.blue,          // Color de fondo azul
                child: const Text('Tamaño item lista'), // Texto dentro del segundo Container
              ), 
            ],
          


        ),
      ),
    );
  }
}
