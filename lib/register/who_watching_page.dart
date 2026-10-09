import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bestcaststudios/authendication/plan_expired_creen.dart';
import 'package:bestcaststudios/register/add_userpage.dart';
import 'package:bestcaststudios/register/who_watching_model.dart';
import '../app_config/app_preferences.dart';
import '../app_config/app_utils.dart';
import '../app_config/appconfig.dart';
import '../authendication/device_signout_alert_screen.dart';
import '../common_files/api_services.dart';
import '../common_files/app_default_colors.dart';
import '../common_files/common_widgets.dart';
import '../common_files/shimmer/shimmer_skeletons.dart';

class WhosWatchingPage extends StatefulWidget {
  final String activityType;

  const WhosWatchingPage({super.key, required this.activityType});

  @override
  State<WhosWatchingPage> createState() => _WhosWatchingPageState();
}

class _WhosWatchingPageState extends State<WhosWatchingPage> {
  List<WhoWatchingModel> whoWatchingModel = [];
  bool editMode = false;
  final AppUtils appUtils = AppUtils();
  bool isLoading = false;

  String _email = "";
  String _token = "";
  String _currentProfileID = "";
  String _selectedProfileID = "";

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // If explicitly opened for "Manage", allow starting in edit mode,
    // otherwise default to normal profile selection mode.
    editMode = widget.activityType == "Manage";

    getInitalValue();
  }

  Future<void> getInitalValue() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      _email = pref.getString(AppPreferences.email) ?? '';
      _token = pref.getString(AppPreferences.token) ?? '';
      _currentProfileID = pref.getString(AppPreferences.profileID) ?? '';
      _selectedProfileID = _currentProfileID;
    });

    if (await CommonWidget().isInternetConnectivity()) {
      getUserProfiles(_token);
    } else {
      if (mounted) {
        CommonWidget().showSnackBar(
          context,
          ContentType.warning,
          "Check your internet connection.",
          "",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    WhoWatchingModel? selectedProfile;
    for (var p in whoWatchingModel) {
      if (p.profileID == _selectedProfileID && p.enableAddUser != true) {
        selectedProfile = p;
        break;
      }
    }

    return Scaffold(
      backgroundColor: AppDefaultColors.appColor,
      appBar: AppBar(
        backgroundColor: AppDefaultColors.appColor,
        elevation: 0,
        leading: widget.activityType != "New"
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          editMode ? "Manage Profiles" : "Who's Watching?",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                editMode = !editMode;
              });
            },
            icon: Icon(
              editMode ? Icons.check_rounded : Icons.edit_outlined,
              color: editMode ? AppDefaultColors.primaryRed : Colors.white70,
              size: 18,
            ),
            label: Text(
              editMode ? "Done" : "Edit",
              style: TextStyle(
                color: editMode ? AppDefaultColors.primaryRed : Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading && whoWatchingModel.isEmpty
          ? const WhoWatchingSkeleton()
          : SafeArea(
              child: Column(
                children: [
                  // Subtitle hint
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: Text(
                      editMode
                          ? "Tap any profile to edit name, icon, or settings"
                          : "Choose a profile to switch account",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                  ),

                  // Profiles Grid
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: whoWatchingModel.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 24,
                          childAspectRatio: 0.85,
                        ),
                        itemBuilder: (context, index) {
                          final item = whoWatchingModel[index];
                          final isSelected = !editMode &&
                              item.enableAddUser != true &&
                              item.profileID == _selectedProfileID;
                          final isCurrent = item.profileID == _currentProfileID;

                          return _buildProfileItem(
                            item: item,
                            isSelected: isSelected,
                            isCurrent: isCurrent,
                            onTap: () {
                              if (item.enableAddUser == true) {
                                _addNewProfile();
                              } else if (editMode) {
                                _editProfile(item);
                              } else {
                                setState(() {
                                  _selectedProfileID = item.profileID ?? '';
                                });
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  // BOTTOM SELECT & SWITCH BUTTON (Visible in selection mode)
                  if (!editMode) ...[
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14141A),
                        border: Border(
                          top: BorderSide(color: Colors.white.withOpacity(0.06)),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: selectedProfile != null
                                  ? () => getUserDetails(_token, selectedProfile!)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppDefaultColors.primaryRed,
                                disabledBackgroundColor: Colors.white.withOpacity(0.12),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    selectedProfile != null
                                        ? (_selectedProfileID == _currentProfileID
                                            ? "Continue as ${selectedProfile.profileName}"
                                            : "Switch to ${selectedProfile.profileName}")
                                        : "Select a Profile",
                                    style: TextStyle(
                                      color: selectedProfile != null ? Colors.white : Colors.white38,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  // -------------------------------------------------------------
  // PROFILE ITEM WIDGET
  // -------------------------------------------------------------
  Widget _buildProfileItem({
    required WhoWatchingModel item,
    required bool isSelected,
    required bool isCurrent,
    required VoidCallback onTap,
  }) {
    if (item.enableAddUser == true) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF15151C),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Add Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppDefaultColors.primaryRed.withOpacity(0.1) : const Color(0xFF15151C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppDefaultColors.primaryRed
                : (isCurrent ? Colors.white24 : Colors.white.withOpacity(0.06)),
            width: isSelected ? 2.2 : 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar Stack (with selected badge or edit badge)
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppDefaultColors.primaryRed : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: (item.profilePicture != null && item.profilePicture!.startsWith("http"))
                        ? FadeInImage(
                            placeholder: const AssetImage('images/default_profile.jpg'),
                            image: NetworkImage(item.profilePicture!),
                            fit: BoxFit.cover,
                            imageErrorBuilder: (_, __, ___) => _avatarInitial(item.profileName ?? "U"),
                          )
                        : _avatarInitial(item.profileName ?? "U"),
                  ),
                ),

                // Selected Checkmark Badge
                if (isSelected)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppDefaultColors.primaryRed,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),

                // Edit Pencil Badge
                if (editMode)
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.black,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Profile Name
            Text(
              item.profileName ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),

            // Current indicator tag
            if (isCurrent) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "ACTIVE",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _avatarInitial(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : "U";
    return Container(
      color: const Color(0xFF23232F),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // PROFILE SWITCHING LOGIC
  // -------------------------------------------------------------
  Future<void> _selectAndSwitchProfile(WhoWatchingModel userProfileData) async {
    if (userProfileData.profileID == null || userProfileData.profileID!.isEmpty) {
      return;
    }

    final pref = await SharedPreferences.getInstance();
    await pref.setString(AppPreferences.profileID, userProfileData.profileID ?? "");
    await pref.setString(AppPreferences.profileName, userProfileData.profileName ?? "");
    await pref.setString(AppPreferences.profilePictureID, userProfileData.profilePictureID ?? "");
    await pref.setString(AppPreferences.profilePictureTitle, userProfileData.profilePictureTitle ?? "");
    await pref.setString(AppPreferences.profilePicture, userProfileData.profilePicture ?? "");
    await pref.setString(AppPreferences.isChild, (userProfileData.isChild ?? 0).toString());

    Fluttertoast.showToast(msg: "Switched to ${userProfileData.profileName}");

    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        'mainscreen',
        (route) => false,
      );
    }
  }

  Future<void> _addNewProfile() async {
    final newModel = WhoWatchingModel(
      profileID: "",
      profileName: "",
      profilePictureID: "",
      profilePictureTitle: "",
      profilePicture: "",
      enableAddUser: true,
    );
    final value = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddUserPage(pageType: 'New', userData: newModel)),
    );
    if (value != null) {
      getUserProfiles(_token);
    }
  }

  Future<void> _editProfile(WhoWatchingModel model) async {
    final value = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddUserPage(pageType: 'Edit', userData: model)),
    );
    if (value != null) {
      getUserProfiles(_token);
    }
  }

  // -------------------------------------------------------------
  // DATA FETCHING
  // -------------------------------------------------------------
  void getUserProfiles(String token) async {
    // Only show full loading spinner if we don't have items yet to prevent UI flashing
    if (whoWatchingModel.isEmpty) {
      setState(() {
        isLoading = true;
      });
    }

    ApiServices().getRequestData(AppConfig.userProfileList, token).then((response) async {
      if (response.statusCode == 200) {
        try {
          var responseData = json.decode(response.body);
          if (responseData["data"] != null && responseData["data"] is List) {
            final List<WhoWatchingModel> updatedList = [];
            for (var profileUser in responseData["data"]) {
              String profilePicUrl = "";
              if (profileUser["profileicon"] != null && profileUser["profileicon"]["thumbnail"] != null) {
                profilePicUrl = "${AppConfig.BaseUrl}/${profileUser["profileicon"]["thumbnail"]}";
              }

              updatedList.add(WhoWatchingModel(
                profileID: profileUser["id"]?.toString() ?? "",
                profileName: profileUser["name"]?.toString() ?? "",
                profilePictureID: profileUser["profileicon"]?["id"]?.toString() ?? "",
                profilePictureTitle: profileUser["profileicon"]?["title"]?.toString() ?? "",
                profilePicture: profilePicUrl,
                lastLogin: profileUser["last_login"]?.toString() ?? "",
                language: profileUser["language"] is int ? profileUser["language"] : int.tryParse(profileUser["language"]?.toString() ?? "0") ?? 0,
                isChild: profileUser["is_child"] is int ? profileUser["is_child"] : int.tryParse(profileUser["is_child"]?.toString() ?? "0") ?? 0,
                isHavePin: profileUser["is_have_pin"] is int ? profileUser["is_have_pin"] : int.tryParse(profileUser["is_have_pin"]?.toString() ?? "0") ?? 0,
                editable: false,
                enableAddUser: false,
              ));
            }

            final pref = await SharedPreferences.getInstance();
            _currentProfileID = pref.getString(AppPreferences.profileID) ?? "";

            // Check if active profile was deleted or is invalid
            final validProfiles = updatedList.where((p) => p.enableAddUser != true).toList();
            if (validProfiles.isNotEmpty) {
              final activeExists = validProfiles.any((p) => p.profileID == _currentProfileID);
              if (!activeExists) {
                // Auto-sync active profile to the first valid profile
                final firstValid = validProfiles.first;
                _currentProfileID = firstValid.profileID ?? "";
                _selectedProfileID = _currentProfileID;
                await pref.setString(AppPreferences.profileID, firstValid.profileID ?? "");
                await pref.setString(AppPreferences.profileName, firstValid.profileName ?? "");
                await pref.setString(AppPreferences.profilePictureID, firstValid.profilePictureID ?? "");
                await pref.setString(AppPreferences.profilePictureTitle, firstValid.profilePictureTitle ?? "");
                await pref.setString(AppPreferences.profilePicture, firstValid.profilePicture ?? "");
                await pref.setString(AppPreferences.isChild, (firstValid.isChild ?? 0).toString());
              } else {
                if (!validProfiles.any((p) => p.profileID == _selectedProfileID)) {
                  _selectedProfileID = _currentProfileID;
                }
              }
            } else {
              _selectedProfileID = "";
              _currentProfileID = "";
            }

            if (updatedList.length < 5) {
              updatedList.add(WhoWatchingModel(
                profileID: "",
                profileName: "Add Profile",
                profilePictureID: "",
                profilePictureTitle: "",
                profilePicture: "images/icon_add.png",
                lastLogin: "",
                language: 0,
                isChild: 0,
                isHavePin: 0,
                editable: false,
                enableAddUser: true,
              ));
            }

            if (mounted) {
              setState(() {
                whoWatchingModel = updatedList;
                isLoading = false;
              });
            }
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          CommonWidget().showSnackBar(
            context,
            ContentType.failure,
            "Error",
            "Could not fetch profiles",
          );
        }
      }
    }).catchError((_) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  void getUserDetails(String token, WhoWatchingModel model) async {
    setState(() {
      isLoading = true;
    });

    try {
      if (token.isNotEmpty) {
        final response = await ApiServices()
            .postRequestTokenWithoutBody(AppConfig.getUserDetails, token);

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          if (jsonResponse['status'] == "success") {
            final String? planStatus =
                jsonResponse['results']?['user']?['plan_status']?.toString();
            final String? planDeviceStatus =
                jsonResponse['results']?['user']?['plan_device_status']?.toString();

            if (planStatus == "0") {
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PlanExpiredScreen()),
                );
              }
              return;
            } else if (planDeviceStatus == "0") {
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeviceSignOutAlertScreen(email: _email),
                  ),
                );
              }
              return;
            }
          }
        }
      }
      await _selectAndSwitchProfile(model);
    } catch (e) {
      debugPrint('getUserDetailsException: $e');
      // Optimistic fallback: switch profile locally even if network fails
      await _selectAndSwitchProfile(model);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
