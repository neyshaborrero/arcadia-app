import 'dart:io';
import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:arcadia_mobile/src/structure/error_detail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class UploadPictureDialog extends StatefulWidget {
  const UploadPictureDialog({super.key});

  @override
  _UploadPictureDialogState createState() => _UploadPictureDialogState();
}

class _UploadPictureDialogState extends State<UploadPictureDialog> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  bool _isLoading = false;

  late final ArcadiaCloud _arcadiaCloud;
  late final FirebaseService _firebaseService;

  @override
  void initState() {
    super.initState();
    _firebaseService = Provider.of<FirebaseService>(context, listen: false);
    _arcadiaCloud = ArcadiaCloud(_firebaseService);
  }

  Future<void> _imgFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    setState(() {
      _imageFile = image;
    });
    _saveUserProfile();
  }

  Future<void> _imgFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    setState(() {
      _imageFile = image;
    });
    _saveUserProfile();
  }

  void _showImagePickerMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take Photo'),
                onTap: () {
                  _imgFromCamera();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose Photo'),
                onTap: () {
                  _imgFromGallery();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _uploadImageToFirebase() async {
    if (_imageFile == null) return null;

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final fileName = '${user.uid}_profile.jpg';
      final storageRef =
          FirebaseStorage.instance.ref().child('profile_pictures/$fileName');
      final uploadTask = storageRef.putFile(File(_imageFile!.path));
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _saveUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    final String? downloadURL = await _uploadImageToFirebase();
    if (downloadURL == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      String? token = await user.getIdToken();
      final response = await _arcadiaCloud.updateUserToDB(
          null, downloadURL, null, null, null, null, token);
      if (response['success']) {
        Provider.of<UserProfileProvider>(context, listen: false)
            .updateProfileUrl(downloadURL);
      } else {
        List<ErrorDetail> errors = response['errors'];
        String errorMessage = errors.isNotEmpty
            ? errors.map((e) => e.message).join(', ')
            : 'An unknown error occurred';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      print('Error saving user profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(10),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFD20E0D),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Profile Picture Upload',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 20),
                    Image.asset(
                      'assets/upload_instructions.png',
                      width: 233,
                      height: 158,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Guidelines',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• The photo must clearly show your face.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '• No cartoon avatars or unrelated images.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '• Ensure the image is not blurry.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Profile photos cannot be changed once checked-in to the event. Failure to follow these rules may result in account ban or termination.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const SizedBox(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: Colors.black,
                      ),
                      onPressed: _isLoading
                          ? null
                          : () => _showImagePickerMenu(context),
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(minWidth: 250, maxWidth: 250),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0xFFD20E0D),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Center(
                              child: Text(
                                "Upload Photo",
                                textAlign: TextAlign.center,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool?> showUploadPictureDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return const UploadPictureDialog();
    },
  );
}
