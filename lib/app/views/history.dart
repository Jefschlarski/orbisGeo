import 'dart:io';
import 'package:flutter/material.dart';
import '../models/photoInfo_model.dart';
import 'details.dart';

class PhotoHistoryPage extends StatelessWidget {
  final List<PhotoInfo> photos;
  final Function(int) onRemove; // Adicionado o callback de remoção

  PhotoHistoryPage({required this.photos, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registros'),
      ),
      body: ListView.builder(
        itemCount: photos.length,
        itemBuilder: (context, index) {
          PhotoInfo photoInfo = photos[index];
          return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsPage(photoInfo: photoInfo),
                  ),
                );
              },
              child: Dismissible(
                key: Key(
                    photoInfo.id.toString()), // Chave única para o Dismissible
                onDismissed: (direction) {
                  onRemove(photoInfo.id); // Chama a função de remoção
                },
                background: Container(
                  color: Colors.red,
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                child: ListTile(
                  leading: Image.file(File(photoInfo.filePath)),
                  title: Text('Bússola: ${photoInfo.compassHeading}'),
                  subtitle: Text(
                    'ID: ${photoInfo.id}, Latitude: ${photoInfo.latitude}, Longitude: ${photoInfo.longitude}',
                  ),
                ),
              ));
        },
      ),
    );
  }
}
