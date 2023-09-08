import 'package:flutter/material.dart';

class CustomStyles {
  static const TextStyle defaultTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 18.0, // Altere o tamanho da fonte aqui
    shadows: [
      Shadow(
        blurRadius: 2.0,
        color: Colors.black,
        offset: Offset(1.0, 1.0), // Deslocamento da sombra
      ),
    ],
  );
  static const TextStyle defaultHeaderStyle = TextStyle(
    fontSize: 24.0, // Tamanho da fonte
    fontWeight: FontWeight.bold, // Peso da fonte
    color: Colors.white, // Cor do texto
  );

  static ButtonStyle defaultButtonStyle = ElevatedButton.styleFrom(
    primary: Colors.blue, // Cor de fundo do botão
    onPrimary: Colors.white, // Cor do texto
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20), // Borda arredondada
    ),
    elevation: 4, // Sombra
    textStyle: TextStyle(
      fontWeight: FontWeight.bold, // Fonte em negrito
      fontSize: 16, // Tamanho da fonte
    ),
    padding:
        EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Preenchimento
    minimumSize: Size(150, 48), // Tamanho mínimo do botão
  );
}
