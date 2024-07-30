import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:lesson72/models/tour.dart';
import 'package:lesson72/services/location_service.dart';

class EditAddTour extends StatefulWidget {
  final Tour? tour;
  EditAddTour({super.key, this.tour});

  @override
  State<EditAddTour> createState() => _EditAddTourState();
}

class _EditAddTourState extends State<EditAddTour> {
  final _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  String? _imagePath;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();

    if (widget.tour != null) {
      _titleController = TextEditingController(text: widget.tour!.title);
      _imagePath = widget.tour!.imageUrl;
    } else {
      _titleController = TextEditingController();
      _imagePath = null;
    }
  }

  Future<void> getImageFromCamera() async {
    final XFile? imageCamera = await _picker.pickImage(source: ImageSource.camera);
    if (imageCamera != null) {
      setState(() {
        _imagePath = imageCamera.path;
      });
    }
  }

  Future<String> uploadImage(File image) async {
    setState(() {
      _isUploading = true;
    });

    final storageRef = FirebaseStorage.instance.ref().child('tours/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = storageRef.putFile(image);

    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();

    setState(() {
      _isUploading = false;
    });

    return downloadUrl;
  }

  void _saveTour() async {
    if (_formKey.currentState!.validate()) {
      String imageUrl = '';

      if (_imagePath != null) {
        imageUrl = await uploadImage(File(_imagePath!));
      }
      await LocationService.getCurrentLocation();
      final location = LocationService.locationData;

      final newTour = Tour(
        id: widget.tour?.id ?? UniqueKey().toString(),
        title: _titleController.text,
        location: location.toString(),
        imageUrl: imageUrl,
      );

      Navigator.pop(context, newTour);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tour == null ? 'Add Tour' : 'Edit Tour'),
        actions: [
          _isUploading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveTour,
                ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              _imagePath != null
                  ? Image.file(
                      File(_imagePath!),
                      height: 200,
                    )
                  : const Text('No image selected'),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera),
                label: const Text('Pick Image from Camera'),
                onPressed: getImageFromCamera,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
