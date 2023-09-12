import 'package:flutter/material.dart';
import '../styles/styles.dart';

class HomePage extends StatelessWidget {
  final VoidCallback onOpenCamera;
  final VoidCallback onViewHistory;

  HomePage({required this.onOpenCamera, required this.onViewHistory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Bem-vindo ao Orbis Geo',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: onOpenCamera,
              style: CustomStyles.defaultButtonStyle,
              child: Text('Abrir Câmera'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: onViewHistory,
              style: CustomStyles.defaultButtonStyle,
              child: Text('Registros'),
            ),
          ],
        ),
      ),
    );
  }
}
