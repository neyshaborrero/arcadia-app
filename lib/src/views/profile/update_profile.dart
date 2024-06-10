import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/providers/change_notifier.dart';
import 'package:arcadia_mobile/src/structure/error_detail.dart';
import 'package:arcadia_mobile/src/structure/user_profile.dart';
import 'package:arcadia_mobile/src/views/start/home_view.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../routes/slide_up_route.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:arcadia_mobile/services/arcadia_cloud.dart';

class UserProfileUpdateScreen extends StatefulWidget {
  const UserProfileUpdateScreen({super.key});

  @override
  _UserProfileUpdateScreenState createState() =>
      _UserProfileUpdateScreenState();
}

class _UserProfileUpdateScreenState extends State<UserProfileUpdateScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _gamertagController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  String? _selectedGender;
  String? _selectedUserType;

  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile; // Used to hold the image file

  late final ArcadiaCloud _arcadiaCloud;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final firebaseService =
        Provider.of<FirebaseService>(context, listen: false);
    _arcadiaCloud = ArcadiaCloud(firebaseService);
  }

  // Method to show the bottom sheet menu
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
                    }),
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
        });
  }

  // Method to handle image selection from the camera
  Future<void> _imgFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    setState(() {
      _imageFile = image;
    });
  }

  // Method to handle image selection from the gallery
  Future<void> _imgFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    setState(() {
      _imageFile = image;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime(1975, 4, 6);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dateOfBirthController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // Method to upload the image to Firebase Storage and get the download URL
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
    if (_formKey.currentState?.validate() == true && _imageFile != null) {
      setState(() {
        _isLoading = true;
      });

      final String? downloadURL = await _uploadImageToFirebase();
      if (downloadURL == null) return;

      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      try {
        String? token = await user.getIdToken();
        final response = await _arcadiaCloud.updateUserToDB(
            _gamertagController.text,
            downloadURL,
            _dateOfBirthController.text,
            _fullNameController.text,
            _selectedGender!,
            _selectedUserType!,
            token);
        if (response['success']) {
          UserProfile? profile = token != null
              ? await _arcadiaCloud.fetchUserProfile(token)
              : null;

          if (profile != null) {
            Provider.of<UserProfileProvider>(context, listen: false)
                .setUserProfile(profile);
          }
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
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
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all fields and select an image.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Adjust to match your color
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Create Account',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight:
                FontWeight.w700, // This corresponds to font-weight: 700 in CSS
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Stack(
                  alignment:
                      Alignment.center, // Aligns the '+' icon over the avatar

                  children: [
                    Container(
                      padding: const EdgeInsets.all(
                          2), // This value is the width of the border
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white, // Border color
                          width: 4.0, // Border width
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 60, // Adjust the radius to your preference
                        backgroundColor: const Color(
                            0xFF2C2B2B), // Background color for the avatar
                        child: FractionallySizedBox(
                          widthFactor: _imageFile != null
                              ? 1.0
                              : 0.6, // scales down the image to 80% of the CircleAvatar's size
                          heightFactor: _imageFile != null
                              ? 1.0
                              : 0.6, // scales down the image to 80% of the CircleAvatar's size
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: _imageFile != null
                                    ? FileImage(File(_imageFile!.path))
                                        as ImageProvider // Use picked image
                                    : const AssetImage(
                                        'assets/player_default_prof_icon.png'), // Fallback to default asset image
                                fit: BoxFit
                                    .cover, // Fills the space, you could use BoxFit.contain to maintain aspect ratio
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0, // Adjust the position as per your design
                      right: 0, // Adjust the position as per your design
                      child: GestureDetector(
                        onTap: () => _showImagePickerMenu(context),
                        child: Container(
                          width: 46.0,
                          height: 46.0,
                          decoration: const BoxDecoration(
                            color: Color(
                                0xFFD20E0D), // Background color of the '+' icon circle
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      contentPadding: EdgeInsets.fromLTRB(16, 18, 16, 18),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(
                              10), // CSS border-radius: 10px 0px 0px 0px;
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        borderSide: BorderSide
                            .none, // CSS opacity: 0; implies no border
                      ),
                      fillColor: Color(0xFF2C2B2B), // Use appropriate color
                    ),
                    keyboardType: TextInputType.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    )),
                const SizedBox(height: 20),
                TextFormField(
                    controller: _gamertagController,
                    decoration: const InputDecoration(
                      labelText: 'Gamertag *',
                      contentPadding: EdgeInsets.fromLTRB(16, 18, 16, 18),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(
                              10), // CSS border-radius: 10px 0px 0px 0px;
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        borderSide: BorderSide
                            .none, // CSS opacity: 0; implies no border
                      ),
                      fillColor: Color(0xFF2C2B2B), // Use appropriate color
                    ),
                    keyboardType: TextInputType.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    )),
                const SizedBox(height: 20),
                TextFormField(
                    controller: _dateOfBirthController,
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth *',
                      contentPadding: EdgeInsets.fromLTRB(16, 18, 16, 18),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(
                              10), // CSS border-radius: 10px 0px 0px 0px;
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        borderSide: BorderSide
                            .none, // CSS opacity: 0; implies no border
                      ),
                      fillColor: Color(0xFF2C2B2B), // Use appropriate color
                      suffixIcon:
                          Icon(Icons.calendar_today, color: Colors.white),
                    ),
                    keyboardType: TextInputType.datetime,
                    onTap: () => _selectDate(context),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    )),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Gender *',
                    contentPadding: EdgeInsets.fromLTRB(16, 18, 16, 18),
                    fillColor: Color(0xFF2C2B2B),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                            10), // CSS border-radius: 10px 0px 0px 0px;
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      borderSide:
                          BorderSide.none, // CSS opacity: 0; implies no border
                    ),
                  ),
                  value: _selectedGender,
                  items:
                      <String>['Male', 'Female', 'Other', 'Prefer Not to Say']
                          .map((String value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ))
                          .toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedGender = newValue;
                    });
                  },
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'User Type *',
                    contentPadding: EdgeInsets.fromLTRB(16, 18, 16, 18),
                    fillColor: Color(0xFF2C2B2B),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                            10), // CSS border-radius: 10px 0px 0px 0px;
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      borderSide:
                          BorderSide.none, // CSS opacity: 0; implies no border
                    ),
                  ),
                  value: _selectedUserType,
                  items: <String>['Player', 'Cosplayer', 'Operator']
                      .map((String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedUserType = newValue;
                    });
                  },
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 50),
                const Text(
                  'Please verify your information carefully. Once submitted, your details cannot be edited later.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _saveUserProfile,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 48, vertical: 16),
                          child: Text(
                            'Create Account',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
              ],
            )),
      ),
    );
  }

  // Function to navigate with the slide transition
  void _navigateWithSlideUpTransition(BuildContext context, Widget page) {
    Navigator.of(context).push(SlideFromBottomPageRoute(page: page));
  }
}
