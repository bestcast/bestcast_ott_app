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

    // final String url = "${AppConfig.quizRewardClaim}${widget.userID}";

    try {
      final response = await ApiServices().putRequestToken(
        AppConfig.quizRewardClaim,
        requestBody,
        widget.token,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(jsonResponse['message'] ?? "Reward claim updated successfully!")),
            );
            widget.onSuccess();
            Navigator.of(context).pop(); // Close the dialog/screen
          }
        } else {
          _showError(jsonResponse['message'] ?? "Failed to update reward claim.");
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
      backgroundColor: Colors.black.withOpacity(0.8), // Overlay background
      appBar: AppBar(
        title: const Text("Claim Reward"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Enter Your Details",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField("Full Name", _fullNameController),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildTextField("Door No", _doorNoController)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTextField("Street Name", _streetNameController)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildTextField("City", _cityController)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTextField("Pin Code", _pinCodeController, isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildTextField("State", _stateController)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTextField("Country", _countryController)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildTextField("Mobile No", _mobileNoController, isNumber: true),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitClaim,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Submit Claim", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$label is required";
        }
        return null;
      },
    );
  }
}
