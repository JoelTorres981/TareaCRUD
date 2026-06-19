import 'package:flutter/material.dart';
import 'db/mongo_database.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Conectar a MongoDB antes de lanzar la aplicación
  try {
    await MongoDatabase.connect();
    debugPrint("Conectado con éxito a MongoDB Atlas");
  } catch (e) {
    debugPrint("Error crítico al conectar a MongoDB: $e");
  }

  runApp(const CheapSharkApp());
}

class CheapSharkApp extends StatelessWidget {
  const CheapSharkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediaExplorer App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: Colors.cyanAccent,
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
        cardTheme: CardThemeData(
          color: const Color(0xFF1E293B), // Slate 800
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}
