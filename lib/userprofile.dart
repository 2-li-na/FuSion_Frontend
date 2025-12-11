import 'package:flutter/material.dart';
import 'package:fusion_new/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';
import 'monthly_activity.dart';
import 'seven_day_activity.dart';
import 'yearly_activity.dart';

class UserProfilePage extends StatefulWidget {
  final String username;
  final String email;
  final String backendBaseUrl;
  final String? profileImageUrl;

  const UserProfilePage({
    Key? key,
    required this.username,
    required this.email,
    required this.backendBaseUrl,
    this.profileImageUrl,
  }) : super(key: key);

  @override
  UserProfilePageState createState() => UserProfilePageState();
}

class UserProfilePageState extends State<UserProfilePage> {
  int _totalSteps = 0;
  int _currentPoints = 0;
  List<Map<String, dynamic>> _redeemedRewards = [];
  bool _loading = true;
  String? _currentProfileImageUrl;

  @override
  void initState() {
    super.initState();
    _currentProfileImageUrl = widget.profileImageUrl;
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    await Future.wait([
      _fetchTotalSteps(),
      _fetchCurrentPoints(),
      _fetchRedeemedRewards(),
    ]);
    setState(() => _loading = false);
  }

  Future<void> _fetchTotalSteps() async {
    try {
      final response = await http.get(
        Uri.parse('${widget.backendBaseUrl}/steps/total/${widget.username}'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _totalSteps = data['totalSteps'] ?? 0);
      }
    } catch (e) {
      print('Error fetching total steps: $e');
    }
  }

  Future<void> _fetchCurrentPoints() async {
    try {
      final response = await http.get(
        Uri.parse('${widget.backendBaseUrl}/points/total/${widget.username}'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _currentPoints = data['totalPoints'] ?? 0);
      }
    } catch (e) {
      print('Error fetching points: $e');
    }
  }

  Future<void> _fetchRedeemedRewards() async {
    try {
      final response = await http.get(
        Uri.parse(
            '${widget.backendBaseUrl}/rewards/history/${widget.username}'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _redeemedRewards = data
              .map((item) => {
                    'name': item['itemTitle'] as String,
                    'date': item['redeemedAt'] as String,
                  })
              .toList();
        });
      }
    } catch (e) {
      print('Error fetching redeemed rewards: $e');
    }
  }

  Future<void> _pickAndUploadImage() async {
    final localizations = AppLocalizations.of(context)!;
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.green),
      ),
    );

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${widget.backendBaseUrl}/users/upload-profile-picture'),
      );
      request.fields['username'] = widget.username;
      request.files.add(
          await http.MultipartFile.fromPath('profilePicture', pickedFile.path));

      var response = await request.send();

      if (!mounted) return;
      Navigator.pop(context);

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = jsonDecode(responseData);
        String baseUrl = widget.backendBaseUrl.replaceAll('/api', '');

        setState(() {
          _currentProfileImageUrl = '$baseUrl${data['profilePicture']}';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.profilePictureUpdated),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.uploadFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.changePassword),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: localizations.oldPassword,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: localizations.newPassword,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: localizations.confirmPassword,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(localizations.passwordsDoNotMatch)),
                );
                return;
              }

              try {
                final response = await http.post(
                  Uri.parse('${widget.backendBaseUrl}/users/change-password'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'username': widget.username,
                    'oldPassword': oldPasswordController.text,
                    'newPassword': newPasswordController.text,
                  }),
                );

                if (!mounted) return;
                Navigator.pop(context);

                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(localizations.passwordChangedSuccessfully),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  final data = jsonDecode(response.body);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(data['message'] ?? localizations.errorChangingPassword),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Fehler: $e')),
                );
              }
            },
            child: Text(localizations.change, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.deleteAccount),
        content: Text(localizations.deleteAccountConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                final response = await http.delete(
                  Uri.parse(
                      '${widget.backendBaseUrl}/users/delete/${widget.username}'),
                );

                if (!mounted) return;

                if (response.statusCode == 200) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) =>
                          LoginPage(backendBaseUrl: widget.backendBaseUrl),
                    ),
                    (route) => false,
                  );
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(localizations.errorDeletingAccount),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Fehler: $e')),
                );
              }
            },
            child: Text(localizations.delete, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.profile),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 200, 230, 201),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : SingleChildScrollView(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                children: [
                  // Section 1: Profile Picture, Username, Email
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green, width: 2),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: screenWidth * 0.12,
                          backgroundColor: Colors.green[700],
                          backgroundImage: _currentProfileImageUrl != null &&
                                  _currentProfileImageUrl!.isNotEmpty
                              ? NetworkImage(_currentProfileImageUrl!)
                              : null,
                          child: _currentProfileImageUrl == null ||
                                  _currentProfileImageUrl!.isEmpty
                              ? Text(
                                  widget.username.isNotEmpty
                                      ? widget.username[0].toUpperCase()
                                      : 'U',
                                  style: TextStyle(
                                      fontSize: screenWidth * 0.12,
                                      color: Colors.white),
                                )
                              : null,
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.username,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.06,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.005),
                              Text(
                                widget.email,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              TextButton.icon(
                                onPressed: _pickAndUploadImage,
                                icon: const Icon(Icons.edit,
                                    size: 16, color: Colors.green),
                                label: Text(
                                  localizations.changeAvatar,
                                  style: const TextStyle(color: Colors.green),
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Section 2: Total Steps and Points
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green, width: 1.5),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _totalSteps.toString(),
                                style: TextStyle(
                                  fontSize: screenWidth * 0.08,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[800],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                localizations.totalSteps,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green, width: 1.5),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _currentPoints.toString(),
                                style: TextStyle(
                                  fontSize: screenWidth * 0.08,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[800],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                localizations.points,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Section 3: Redeemed Rewards Table
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green, width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Text(
                          localizations.redeemedRewards,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: screenHeight * 0.25,
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.green[700]!, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _redeemedRewards.isEmpty
                              ? Center(
                                  child: Text(
                                    localizations.noRedeemedRewards,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _redeemedRewards.length,
                                  itemBuilder: (context, index) {
                                    final reward = _redeemedRewards[index];
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.green[300]!,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              reward['name'],
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                          ),
                                          Text(
                                            _formatDate(reward['date']),
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Section 4: Activity View Buttons
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green, width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Text(
                          localizations.yourActivities,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        //year view button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => YearlyActivityPage(
                                  username: widget.username,
                                  backendBaseUrl: widget.backendBaseUrl,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize:
                                Size(double.infinity, screenHeight * 0.06),
                          ),
                          child: Text(
                            localizations.forOneYear,
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 8),
                        //7 day view button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SevenDayActivityPage(
                                  username: widget.username,
                                  backendBaseUrl: widget.backendBaseUrl,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize:
                                Size(double.infinity, screenHeight * 0.06),
                          ),
                          child: Text(
                            localizations.lastSevenDays,
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 8),
                        //month view button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MonthlyActivityPage(
                                  username: widget.username,
                                  backendBaseUrl: widget.backendBaseUrl,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize:
                                Size(double.infinity, screenHeight * 0.06),
                          ),
                          child: Text(
                            localizations.forEntireMonth,
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Section 5: Password Change and Account Deletion
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _showChangePasswordDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize:
                                Size(double.infinity, screenHeight * 0.06),
                          ),
                          child: Text(
                            localizations.changePasswordButton,
                            style: const TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _showDeleteAccountDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[700],
                            minimumSize:
                                Size(double.infinity, screenHeight * 0.06),
                          ),
                          child: Text(
                            localizations.deleteAccountButton,
                            style: const TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
