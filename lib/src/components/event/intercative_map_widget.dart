import 'package:flutter/material.dart';

class InteractiveMapWidget extends StatefulWidget {
  const InteractiveMapWidget({Key? key}) : super(key: key);

  @override
  _InteractiveMapWidgetState createState() => _InteractiveMapWidgetState();
}

class _InteractiveMapWidgetState extends State<InteractiveMapWidget> {
  late TransformationController _transformationController;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();

    // Set the transformation controller to show the original image size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _transformationController.value = Matrix4.identity(); // Original size
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        backgroundColor: Colors.black,
        title: const Text(
          'Arcadia Battle Arena',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w700, // Corresponds to font-weight: 700
          ),
        ),
        toolbarHeight: 60.0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Map Viewer - Start at original image size
            Expanded(
              child: InteractiveViewer(
                transformationController: _transformationController,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.asset(
                  'assets/arcadia_map.jpeg', // Replace with your map image asset
                  fit: BoxFit.contain, // No scaling, preserves original size
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
