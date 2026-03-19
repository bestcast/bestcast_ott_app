import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bestcaststudios/app_config/appconfig.dart';
import 'package:bestcaststudios/common_files/api_services.dart';

class QuizRewardClaim extends StatefulWidget {
  final String userID;
  final String token;
  final VoidCallback onSuccess;

  const QuizRewardClaim({
    Key? key,
    required this.userID,
    required this.token,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<QuizRewardClaim> createState() => _QuizRewardClaimState();
}

class _QuizRewardClaimState extends State<QuizRewardClaim> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _doorNoController = TextEditingController();
  final TextEditingController _streetNameController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _mobileNoController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _doorNoController.dispose();
    _streetNameController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _pinCodeController.dispose();
    _mobileNoController.dispose();
    super.dispose();
  }

  Future<void> _submitClaim() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final Map<String, dynamic> requestBody = {
      "full_name": _fullNameController.text.trim(),
      "door_no": _doorNoController.text.trim(),
      "street_name": _streetNameController.text.trim(),
      "country": _countryController.text.trim(),
      "state": _stateController.text.trim(),
      "city": _cityController.text.trim(),
      "pin_code": _pinCodeController.text.trim(),
      "mobile_no": _mobileNoController.text.trim(),
    };

    try {
      // 1. First attempt to Create (POST)
      var response = await ApiServices().postRequestToken(
        AppConfig.rewardClaimCreate,
        requestBody,
        widget.token,
      );

      var jsonResponse = jsonDecode(response.body);

      // 2. If backend indicates already submitted, fallback to Update (PUT) using userID
      if (jsonResponse['success'] == false && jsonResponse['message'] != null && jsonResponse['message'].toString().toLowerCase().contains("already submitted")) {
        print("Reward Claim Create Response 111: ${AppConfig.rewardClaimUpdate}${widget.userID}");
        print("Azmat: ${widget.userID}");
        response = await ApiServices().putRequestToken(
          "${AppConfig.rewardClaimUpdate}${widget.userID}",
          requestBody,
          widget.token,
        );
        print("Reward Claim Update Response: ${response.body}");
        jsonResponse = jsonDecode(response.body);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (jsonResponse['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(jsonResponse['message'] ?? "Reward claim processed successfully!")),
            );
            widget.onSuccess();
            Navigator.of(context).pop(); // Close the dialog/screen
          }
        } else {
          _showError(jsonResponse['message'] ?? "Failed to process reward claim.");
        }
      } else {
        _showError("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      _showError("An error occurred: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Let dialog background show
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF031634),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blueAccent, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withValues(alpha: 0.5),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Claim Reward",
                        style: TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Enter your shipping details carefully",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField("Full Name", _fullNameController),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildTextField("Door No", _doorNoController)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField("Street Name", _streetNameController)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildTextField("City", _cityController)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          "Pin Code",
                          _pinCodeController,
                          isNumber: true,
                          maxLength: 6,
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Required";
                            if (value.length != 6) return "Must be 6 digits";
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildTextField("State", _stateController)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField("Country", _countryController)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    "Mobile No",
                    _mobileNoController,
                    isNumber: true,
                    maxLength: 10,
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Mobile No is required";
                      if (value.length != 10) return "Must be exactly 10 digits";
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitClaim,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent.withValues(alpha: 0.2),
                        disabledBackgroundColor: Colors.grey.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Colors.blueAccent, width: 2),
                        ),
                        elevation: 10,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.blueAccent, strokeWidth: 2),
                            )
                          : const Text(
                              "Submit Claim",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLength: maxLength,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF020C1F),
        counterText: "", // Hide character counter
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueAccent.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
      validator: validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return "$label is required";
            }
            return null;
          },
    );
  }
}
