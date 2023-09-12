import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscando no Banco de Dados'),
      ),
      body: Center(
        child:
            CircularProgressIndicator(), // Um indicador de carregamento (loading)
      ),
    );
  }
}
