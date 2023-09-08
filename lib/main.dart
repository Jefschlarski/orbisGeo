import 'dart:async';
import 'dart:io';
import 'styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(builder: (context) => HomeScreen());
        },
      ),
    );
  }
}

class PhotoInfo {
  final int id;
  final String filePath;
  final double compassHeading;
  final double latitude;
  final double longitude;

  PhotoInfo({
    required this.id,
    required this.filePath,
    required this.compassHeading,
    required this.latitude,
    required this.longitude,
  });
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<CameraDescription> _cameras;
  bool _hasPermissions = false;
  CompassEvent? _lastRead;
  DateTime? _lastReadAt;
  Position? _lastLocation;
  CameraController? _controller;

  StreamSubscription<CompassEvent>? _compassSubscription;
  StreamSubscription<Position>? _positionSubscription;

  bool _isCameraOpen = false;

  //array das fotos

  List<PhotoInfo> _photoHistory = [];
  int _nextId = 1;

  void _removePhoto(int id) {
    setState(() {
      _photoHistory.removeWhere((photo) => photo.id == id);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchPermissionStatus();

    availableCameras().then((cameras) {
      _cameras = cameras;
    });

    _compassSubscription = FlutterCompass.events!.listen((event) {
      setState(() {
        _lastRead = event;
        _lastReadAt = DateTime.now();
      });
    });

    _positionSubscription = Geolocator.getPositionStream().listen((position) {
      setState(() {
        _lastLocation = position;
      });
    });
  }

// Abrir camera

  void _openCamera() {
    if (_cameras.isNotEmpty) {
      _controller = CameraController(_cameras[0], ResolutionPreset.max);
      _controller!.initialize().then((_) {
        if (mounted) {
          setState(() {
            _isCameraOpen = true;
          });
        }
      });
    }
  }

// Capturar foto

  void _capturePhoto() async {
    if (_controller != null &&
        _controller!.value.isInitialized &&
        _lastRead != null &&
        _lastLocation != null) {
      try {
        final XFile file = await _controller!.takePicture();

        double compassHeading = _lastRead!.heading?.toDouble() ?? 0.0;

        PhotoInfo photoInfo = PhotoInfo(
          id: _nextId, // Atribui o próximo ID
          filePath: file.path,
          compassHeading: compassHeading,
          latitude: _lastLocation!.latitude,
          longitude: _lastLocation!.longitude,
        );
        _nextId++; // Incrementa o próximo ID

        setState(() {
          _photoHistory.add(photoInfo);
        });

        print('Foto tirada: ${file.path}');
        print('Compass: $compassHeading');
        print(
            'Lat: ${_lastLocation!.latitude}, Lng: ${_lastLocation!.longitude}');

        // exibe a confirmação da captura

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Captura realizada com sucesso',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
            onVisible: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
          ),
        );
      } catch (e) {
        print('Erro na captura: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro na captura foto: $e',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

// Monta o topico nos registros

  void _viewPhotoHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoHistoryPage(
          photos: _photoHistory,
          onRemove: _removePhoto, // Passa a função de remoção
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _compassSubscription?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }

// Header

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'ORBIS GEO',
          style: CustomStyles.defaultHeaderStyle,
        ),
        leading: _isCameraOpen
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  _controller?.dispose();
                  setState(() {
                    _controller = null;
                    _isCameraOpen = false;
                  });
                },
              )
            : null,
      ),
      body: Builder(builder: (context) {
        if (_hasPermissions) {
          return _isCameraOpen
              ? _buildCameraScreen()
              : HomePage(
                  onOpenCamera: _openCamera,
                  onViewHistory: _viewPhotoHistory,
                );
        } else {
          return _buildPermissionSheet();
        }
      }),
    );
  }

// Camera

  Widget _buildCameraScreen() {
    return Stack(
      children: <Widget>[
        if (_controller != null && _controller!.value.isInitialized)
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: CameraPreview(_controller!),
          ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            if (_lastRead != null && _lastLocation != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Bússola: ${_lastRead!.heading}',
                      style: CustomStyles.defaultTextStyle,
                    ),
                    Text('Latitude: ${_lastLocation!.latitude}',
                        style: CustomStyles.defaultTextStyle),
                    Text('Longitude: ${_lastLocation!.longitude}',
                        style: CustomStyles.defaultTextStyle),
                  ],
                ),
              ),
            Container(
                // Container para os botões
                alignment: Alignment.center,
                padding: EdgeInsets.only(
                    bottom: 50.0), // Ajuste a quantidade conforme necessário
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ElevatedButton(
                      child: Text('Capturar'),
                      style: CustomStyles.defaultButtonStyle,
                      onPressed: _capturePhoto,
                    ),
                    ElevatedButton(
                      child: Text('Registros'),
                      style: CustomStyles.defaultButtonStyle,
                      onPressed: _viewPhotoHistory,
                    ),
                  ],
                )),
          ],
        ),
      ],
    );
  }

// Exibe detalhes de permissões ao abrir o app pela primeira vez

  Widget _buildPermissionSheet() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Requer permissões locais'),
          ElevatedButton(
            child: Text('Permissões'),
            style: CustomStyles.defaultButtonStyle,
            onPressed: () {
              Permission.locationWhenInUse.request().then((ignored) {
                _fetchPermissionStatus();
              });
            },
          ),
          SizedBox(height: 16),
          ElevatedButton(
            child: Text('Configurações'),
            style: CustomStyles.defaultButtonStyle,
            onPressed: () {
              openAppSettings().then((opened) {
                //
              });
            },
          )
        ],
      ),
    );
  }

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() => _hasPermissions = status == PermissionStatus.granted);
      }
    });
  }
}

// Home Page

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

// Pagina dos Registros

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
// Exibe os detalhes de cada registro

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
