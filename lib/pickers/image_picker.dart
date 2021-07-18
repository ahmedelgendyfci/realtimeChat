import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerW extends StatefulWidget {
  final Function imagePickFn;
  ImagePickerW(this.imagePickFn);
  @override
  _ImagePickerWState createState() => _ImagePickerWState();
}

enum pickTypes { gallery, camera }

class _ImagePickerWState extends State<ImagePickerW> {
  bool hasImage = false;
  late File _pickedImage;
  final picker = ImagePicker();
  late pickTypes picked;

  Future<void> getImage() async {
    var pickedFile;
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick Image From:'),
          actions: <Widget>[
            TextButton(
              child: const Icon(Icons.camera_alt),
              onPressed: () async {
                pickedFile = await picker.getImage(
                  source: ImageSource.camera,
                  imageQuality: 50,
                  maxWidth: 150,
                );

                if (pickedFile == null) {
                  return;
                }
                setState(() {
                  hasImage = true;
                  _pickedImage = File(pickedFile.path);
                });
                widget.imagePickFn(_pickedImage);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Icon(Icons.image),
              onPressed: () async {
                pickedFile = await picker.getImage(
                  source: ImageSource.gallery,
                  imageQuality: 50,
                  maxWidth: 150,
                );

                if (pickedFile == null) {
                  return;
                }
                setState(() {
                  hasImage = true;
                  _pickedImage = File(pickedFile.path);
                });
                widget.imagePickFn(_pickedImage);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    if (pickedFile == null) {
      return;
    }
    setState(() {
      hasImage = true;
      _pickedImage = File(pickedFile.path);
    });
    widget.imagePickFn(_pickedImage);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          backgroundImage: hasImage ? FileImage(_pickedImage) : null,
        ),
        FlatButton(
          onPressed: getImage,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera,
                color: Colors.grey,
                size: 20,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                'Pick Image',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        )
      ],
    );
  }
}
