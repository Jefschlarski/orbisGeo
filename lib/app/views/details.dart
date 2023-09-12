import 'dart:io';

import 'package:flutter/material.dart';
import 'package:projeto/app/views/search.dart';
import '../models/photoInfo_model.dart';

class DetailsPage extends StatelessWidget {
  final PhotoInfo photoInfo;

  DetailsPage({required this.photoInfo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes'),
      ),
      body: Stack(
        children: [
          Image.file(
            File(photoInfo.filePath),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
            bottom: 20, // Posiciona o botão 20 pixels acima da borda inferior
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchPage()),
                  );
                },
                child: Text('Buscar'),
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Bússola: ${photoInfo.compassHeading}',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Latitude: ${photoInfo.latitude}, Longitude: ${photoInfo.longitude}',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    'ID: ${photoInfo.id}',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
