import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON encoding/decoding
import 'package:mobile_scanner/mobile_scanner.dart'; // For QR code scanning (ensure ^5.0.0 in pubspec.yaml)
// import 'package:provider/provider.dart'; // For state management
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'screens/add_product_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/product_list_screen.dart';
import 'models/product.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);
  Hive.registerAdapter(ProductAdapter());
  await Hive.openBox<Product>('products');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Room Product Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Define a custom color scheme for a modern look
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.teal, // A different primary color
          accentColor: Colors.deepOrangeAccent, // Accent color for buttons, etc.
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal, // AppBar background
          foregroundColor: Colors.white, // AppBar text/icon color
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal, // Button background
            foregroundColor: Colors.white, // Button text color
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        // You can define text themes, input decoration themes, etc. here
        textTheme: TextTheme(
          headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
          bodyLarge: TextStyle(fontSize: 16),
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Room Tracker')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add some spacing between buttons
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => AddProductScreen())),
                child: Text('Add Product'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => ScanScreen())),
                child: Text('Scan & Update Room'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => ProductListScreen())),
                child: Text('View Products'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}