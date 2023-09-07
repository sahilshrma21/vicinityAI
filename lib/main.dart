import 'package:flutter/material.dart';
import 'package:new_mlkit/DetailScreen.dart';

void main() => runApp(const MaterialApp(
      home: HomeScreen(),
    ));

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<String> itemsList = [
    'Text Scanner',
    'Barcode Scanner',
    'Label Scanner',
    'Face Detection'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ML Kit Demo'),
      ),
      body: ListView.builder(
          itemCount: itemsList.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                title: Text(itemsList[index]),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DetailScreen(),
                      settings: RouteSettings(arguments: itemsList[index]),
                    ),
                  );
                },
              ),
            );
          }),
    );
  }
}
