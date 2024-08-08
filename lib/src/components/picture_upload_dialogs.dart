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
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
      await _saveUserProfile();
    }
  }

  Future<void> _imgFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
      await _saveUserProfile();
    }
  }

  void _showImagePickerMenu() {
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
      _showSnackbar('Failed to upload image.');
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
          null, downloadURL, null, null, null, null, token, false);

      if (response['success']) {
        Provider.of<UserProfileProvider>(context, listen: false)
            .updateProfileUrl(downloadURL);
      } else {
        _handleErrors(response['errors']);
      }
    } catch (e) {
      print('Error saving user profile: $e');
      _showSnackbar('Error saving user profile.');
    } finally {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  void _handleErrors(List<ErrorDetail> errors) {
    String errorMessage = errors.isNotEmpty
        ? errors.map((e) => e.message).join(', ')
        : 'An unknown error occurred';
    _showSnackbar(errorMessage);
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final dialogWidth = isTablet
        ? MediaQuery.of(context).size.width * 0.5
        : MediaQuery.of(context).size.width * 0.95;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(10),
      child: Container(
        width: dialogWidth,
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
                    _buildGuidelines(),
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
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : _buildUploadButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuidelines() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGuidelineItem('• The photo must clearly show your face.'),
        _buildGuidelineItem('• No cartoon avatars or unrelated images.'),
        _buildGuidelineItem('• Ensure the image is not blurry.'),
      ],
    );
  }

  Widget _buildGuidelineItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildUploadButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        backgroundColor: Colors.black,
      ),
      onPressed: _showImagePickerMenu,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 250, maxWidth: 250),
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
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
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
