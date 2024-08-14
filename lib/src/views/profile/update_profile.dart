import 'dart:async';

import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/components/picture_upload_dialogs.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:arcadia_mobile/src/structure/error_detail.dart';
import 'package:arcadia_mobile/src/structure/mission_details.dart';
import 'package:arcadia_mobile/src/structure/user_profile.dart';
import 'package:arcadia_mobile/src/views/start/home_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final TextEditingController _cityController = TextEditingController();
  final FocusNode _gamertagFocusNode = FocusNode();

  String? _selectedGender;
  String? _selectedUserType;
  String? _gamertagValidationMessage;

  late final ArcadiaCloud _arcadiaCloud;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final Debouncer _debouncer = Debouncer(milliseconds: 500);
  final List<String> _cities = [
    "Adjuntas",
    "Aguada",
    "Aguadilla",
    "Aguas Buenas",
    "Aibonito",
    "Añasco",
    "Arecibo",
    "Arroyo",
    "Barceloneta",
    "Barranquitas",
    "Bayamón",
    "Cabo Rojo",
    "Caguas",
    "Camuy",
    "Canóvanas",
    "Carolina",
    "Cataño",
    "Cayey",
    "Ceiba",
    "Ciales",
    "Cidra",
    "Coamo",
    "Comerío",
    "Corozal",
    "Culebra",
    "Dorado",
    "Fajardo",
    "Florida",
    "Guánica",
    "Guayama",
    "Guayanilla",
    "Guaynabo",
    "Gurabo",
    "Hatillo",
    "Hormigueros",
    "Humacao",
    "Isabela",
    "Jayuya",
    "Juana Díaz",
    "Juncos",
    "Lajas",
    "Lares",
    "Las Marías",
    "Las Piedras",
    "Loíza",
    "Luquillo",
    "Manatí",
    "Maricao",
    "Maunabo",
    "Mayagüez",
    "Moca",
    "Morovis",
    "Naguabo",
    "Naranjito",
    "Orocovis",
    "Patillas",
    "Peñuelas",
    "Ponce",
    "Quebradillas",
    "Rincón",
    "Río Grande",
    "Sabana Grande",
    "Salinas",
    "San Germán",
    "San Juan",
    "San Lorenzo",
    "San Sebastián",
    "Santa Isabel",
    "Toa Alta",
    "Toa Baja",
    "Trujillo Alto",
    "Utuado",
    "Vega Alta",
    "Vega Baja",
    "Vieques",
    "Villalba",
    "Yabucoa",
    "Yauco"
  ];

  List<String> _filteredCities = [];

  @override
  void initState() {
    super.initState();
    _arcadiaCloud =
        ArcadiaCloud(Provider.of<FirebaseService>(context, listen: false));
    _gamertagFocusNode.addListener(_checkGamertagFocus);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _gamertagController.dispose();
    _dateOfBirthController.dispose();
    _cityController.dispose();
    _gamertagFocusNode.dispose();
    super.dispose();
  }

  void _checkGamertagFocus() {
    if (!_gamertagFocusNode.hasFocus) {
      _debouncer.run(() => _checkGamertag());
    }
  }

  Future<void> _checkGamertag() async {
    final String gamertag = _gamertagController.text.trim();
    if (gamertag.isEmpty) {
      _updateGamertagValidationMessage("Gamertag is required.");
      return;
    }

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _updateGamertagValidationMessage("User is not logged in.");
        return;
      }

      final token = await user.getIdToken();
      if (token == null) {
        _updateGamertagValidationMessage(
            "Unable to retrieve authentication token.");
        return;
      }

      final response = await _arcadiaCloud.isGamertagAvailable(gamertag, token);

      if (response['success'] == true) {
        _updateGamertagValidationMessage(null);
      } else {
        _updateGamertagValidationMessage(
            response['errors'] != null && response['errors'].isNotEmpty
                ? response['errors'][0]['message']
                : 'Unknown error occurred.');
      }
    } catch (e) {
      _updateGamertagValidationMessage(
          "Error checking gamertag. Please try again.");
    }
  }

  void _updateGamertagValidationMessage(String? message) {
    if (mounted) {
      setState(() {
        _gamertagValidationMessage = message;
      });
    }
  }

  void _showImagePickerMenu() {
    showUploadPictureDialog(context);
  }

  Future<void> _selectDate() async {
    final DateTime initialDate = DateTime(1975, 4, 6);
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

  Future<void> _saveUserProfile() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackbar('Please fill all fields.');
      return;
    }

    final UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context, listen: false);
    if (userProfileProvider.profileUrl == null ||
        userProfileProvider.profileUrl!.isEmpty) {
      _showSnackbar('Profile image is required.');
      return;
    }

    if (_gamertagValidationMessage != null) {
      _showSnackbar(_gamertagValidationMessage!);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final token = await user.getIdToken();
      if (token == null) {
        _showSnackbar('Unable to retrieve authentication token.');
        return;
      }

      final response = await _arcadiaCloud.updateUserToDB(
        _gamertagController.text.trim(),
        null,
        _dateOfBirthController.text.trim(),
        _fullNameController.text.trim(),
        _selectedGender!,
        _selectedUserType!,
        token,
        _cityController.text,
        null,
        true,
      );

      if (response['success']) {
        _handleSuccess(token);
      } else {
        _handleErrors(response['errors']);
      }
    } catch (e) {
      print('Error saving user profile: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSuccess(String token) async {
    UserProfile? profile = await _arcadiaCloud.fetchUserProfile(token);
    if (profile != null) {
      Provider.of<UserProfileProvider>(context, listen: false)
          .setUserProfile(profile);
    }

    List<MissionDetails>? missions = await _fetchMissions(token);
    if (missions != null && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen(missions: missions)),
      );
    }
  }

  void _handleErrors(List<ErrorDetail> errors) {
    final errorMessage = errors.isNotEmpty
        ? errors.map((e) => e.message).join(', ')
        : 'An unknown error occurred';
    _showSnackbar(errorMessage);
  }

  Future<List<MissionDetails>?> _fetchMissions(String token) async {
    try {
      // Get the user's local datetime
      final userLocalDatetime = DateTime.now().toIso8601String();

      // Get the user's timezone name (using intl)
      final userTimezone = DateFormat('z').format(DateTime.now());
      return await _arcadiaCloud.fetchArcadiaMissions(
          token, userLocalDatetime, userTimezone);
    } catch (e) {
      print('Error fetching missions: $e');
      return null;
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _filterCities(String query) {
    final suggestions = _cities.where((city) {
      return city.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredCities = suggestions;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final double avatarRadius = isTablet ? 90 : 60;
    final double iconContainerSize = isTablet ? 66.0 : 46.0;
    final double iconSize = isTablet ? 40.0 : 24.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Create Account',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double widthFactor = constraints.maxWidth > 600 ? 0.7 : 1.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0).add(
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: FractionallySizedBox(
                widthFactor: widthFactor,
                child: Form(
                  key: _formKey,
                  child: Consumer<UserProfileProvider>(
                    builder: (context, userProfileProvider, _) {
                      final profileUrl = userProfileProvider.profileUrl;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          _buildProfileImage(context, profileUrl, avatarRadius,
                              iconContainerSize, iconSize),
                          const SizedBox(height: 20),
                          _buildTextFormField(
                            controller: _fullNameController,
                            label: 'Full Name *',
                            keyboardType: TextInputType.name,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Required'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          _buildTextFormField(
                            controller: _gamertagController,
                            focusNode: _gamertagFocusNode,
                            label: 'Gamertag *',
                            keyboardType: TextInputType.name,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Required'
                                : null,
                          ),
                          if (_gamertagValidationMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                _gamertagValidationMessage!,
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 14),
                              ),
                            ),
                          const SizedBox(height: 20),
                          _buildTextFormField(
                            controller: _dateOfBirthController,
                            label: 'Date of Birth *',
                            keyboardType: TextInputType.datetime,
                            onTap: _selectDate,
                            suffixIcon: const Icon(Icons.calendar_today,
                                color: Colors.white),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Required'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          _buildDropdownFormField(
                            value: _selectedGender,
                            label: 'Gender *',
                            items: [
                              'Male',
                              'Female',
                              'Other',
                              'Prefer Not to Say'
                            ],
                            onChanged: (value) =>
                                setState(() => _selectedGender = value),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Required'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          _buildDropdownFormField(
                            value: _selectedUserType,
                            label: 'User Type *',
                            items: ['Player', 'Cosplayer', 'Placeholder'],
                            onChanged: (value) =>
                                setState(() => _selectedUserType = value),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Required'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          _buildCitySearchField(),
                          const SizedBox(height: 20),
                          const Text(
                            'Please verify your information carefully. Once submitted, your details cannot be edited later.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(height: 24),
                          _isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white))
                              : ElevatedButton(
                                  onPressed: _saveUserProfile,
                                  style: ElevatedButton.styleFrom(
                                      minimumSize: const Size.fromHeight(50)),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 48, vertical: 16),
                                    child: Text('Create Account',
                                        style: TextStyle(fontSize: 18)),
                                  ),
                                ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileImage(BuildContext context, String? profileUrl,
      double avatarRadius, double iconContainerSize, double iconSize) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4.0),
          ),
          child: CircleAvatar(
            radius: avatarRadius,
            backgroundColor: const Color(0xFF2C2B2B),
            child: FractionallySizedBox(
              widthFactor:
                  profileUrl != null && profileUrl.isNotEmpty ? 1.0 : 0.6,
              heightFactor:
                  profileUrl != null && profileUrl.isNotEmpty ? 1.0 : 0.6,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: profileUrl != null && profileUrl.isNotEmpty
                        ? CachedNetworkImageProvider(profileUrl)
                        : const AssetImage(
                                'assets/player_default_prof_icon.png')
                            as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _showImagePickerMenu,
            child: Container(
              width: iconContainerSize,
              height: iconContainerSize,
              decoration: const BoxDecoration(
                color: Color(0xFFD20E0D),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: Colors.white, size: iconSize),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    FocusNode? focusNode,
    VoidCallback? onTap,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        filled: true,
        fillColor: const Color(0xFF2C2B2B),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffixIcon,
      ),
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      onTap: onTap,
      validator: validator,
    );
  }

  Widget _buildDropdownFormField({
    required String? value,
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        filled: true,
        fillColor: const Color(0xFF2C2B2B),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide.none,
        ),
      ),
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      validator: validator,
    );
  }

  Widget _buildCitySearchField() {
    return Column(
      children: [
        TextFormField(
          controller: _cityController,
          decoration: const InputDecoration(
            labelText: 'City',
            contentPadding: EdgeInsets.fromLTRB(16, 18, 16, 18),
            filled: true,
            fillColor: Color(0xFF2C2B2B),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          onChanged: _filterCities,
          validator: (value) =>
              value == null || value.isEmpty ? 'Required' : null,
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: _filteredCities.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                _filteredCities[index],
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                setState(() {
                  _cityController.text = _filteredCities[index];
                  _filteredCities = [];
                });
              },
            );
          },
        ),
      ],
    );
  }
}

class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
