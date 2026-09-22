import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';

class EditProfileScreen extends StatefulWidget {
  final String? id;
  const EditProfileScreen({super.key, this.id});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController(text: 'John Doe');
  final _emailController = TextEditingController(text: 'john@example.com');
  final _phoneController = TextEditingController(text: '+1234567890');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.editProfile.tr()),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50.r,
                    backgroundImage: const NetworkImage(
                      'https://cdn-icons-png.flaticon.com/512/219/219983.png',
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 16.r,
                      backgroundColor: tokens.primary,
                      child: Icon(
                        Icons.camera_alt,
                        size: 16.sp,
                        color: tokens.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            24.verticalSpace,
            _buildField(
              context,
              AppStrings.name.tr(),
              _nameController,
              Icons.person,
            ),
            16.verticalSpace,
            _buildField(
              context,
              AppStrings.email.tr(),
              _emailController,
              Icons.email,
            ),
            16.verticalSpace,
            _buildField(
              context,
              AppStrings.phone.tr(),
              _phoneController,
              Icons.phone,
            ),
            32.verticalSpace,
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.primary,
                  foregroundColor: tokens.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppStrings.profileSavedSuccess.tr()),
                    ),
                  );
                },
                child: Text(
                  AppStrings.save.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    BuildContext context,
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    final tokens = TaalaTokens.of(context);

    return TextField(
      controller: controller,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: tokens.textPrimary,
          ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: tokens.textSecondary),
        prefixIcon: Icon(icon, color: tokens.primary),
        filled: true,
        fillColor: tokens.surfaceMuted,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: tokens.borderSubtle),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: tokens.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: tokens.primary, width: 2),
        ),
      ),
    );
  }
}
