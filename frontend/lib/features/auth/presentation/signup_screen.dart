import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/dto/request_dtos.dart';
import '../../../core/network/api_service.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import 'widgets/auth_banner.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String _selectedCountryCode = '+234';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ApiService().register(
        RegisterRequestDto(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: '$_selectedCountryCode${_phoneController.text.trim()}',
          password: _passwordController.text,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! Welcome to Myafrimall.'),
          backgroundColor: AppColors.primary,
        ),
      );
      context.go('/dashboard');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Row(
            children: [
          // Left: Form Area
          Expanded(
            flex: isDesktop ? 6 : 10,
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 80 : 28,
                  vertical: 40,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppStrings.createAccountTitle,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              AppStrings.createAccountSubtitle,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary.withValues(alpha: 0.9),
                                height: 1.4,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.go('/login'),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textLink,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 36),

                        // Names row
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth > 400) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      label: 'First name',
                                      hintText: 'John',
                                      controller: _firstNameController,
                                     validator: Validators.firstName,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: CustomTextField(
                                      label: 'Last name',
                                      hintText: 'Doe',
                                      controller: _lastNameController,
                                      validator: Validators.lastName,
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  CustomTextField(
                                    label: 'First name',
                                    hintText: 'John',
                                    controller: _firstNameController,
                                    validator: Validators.firstName,
                                  ),
                                  const SizedBox(height: 20),
                                  CustomTextField(
                                    label: 'Last name',
                                    hintText: 'Doe',
                                    controller: _lastNameController,
                                    validator: Validators.lastName,
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 20),

                        // Email
                        CustomTextField(
                          label: 'Email',
                          hintText: 'user@example.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 20),

                        // Phone Number
                        CustomTextField(
                          label: 'Phone Number',
                          hintText: '8012345678',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          isPhone: true,
                          selectedCountryCode: _selectedCountryCode,
                          validator: Validators.phone,
                        ),
                        const SizedBox(height: 20),

                        // Password
                        CustomTextField(
                          label: 'Password',
                          hintText: 'Enter Password',
                          controller: _passwordController,
                          isPassword: true,
                          validator: Validators.password,
                        ),
                        const SizedBox(height: 28),

                        // Button
                        CustomButton(
                          text: 'Create account',
                          onPressed: _handleRegister,
                          isLoading: _isLoading,
                          width: isDesktop ? 150 : double.infinity,
                          backgroundColor: AppColors.primary,
                        ),
                        const SizedBox(height: 24),

                        // Terms text
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary.withValues(alpha: 0.8),
                              height: 1.5,
                            ),
                            children: const [
                              TextSpan(text: 'By clicking on create account you agree to our '),
                              TextSpan(
                                text: 'privacy policy',
                                style: TextStyle(
                                  color: AppColors.textLink,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(text: ' and '),
                              TextSpan(
                                text: 'terms of use',
                                style: TextStyle(
                                  color: AppColors.textLink,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Right: Banner Side (Desktop/Tablet)
          if (isDesktop)
            const Expanded(
              flex: 5,
              child: AuthBanner(
                title: AppStrings.bannerDeliveryTitle,
                subtitle: AppStrings.bannerDeliveryDesc,
              ),
            ),
        ],
      ),

          // Activity overlay — appears on top while creating account
          if (_isLoading)
            AnimatedOpacity(
              opacity: _isLoading ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                color: Colors.black.withValues(alpha: 0.45),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36, vertical: 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 42,
                          height: 42,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF1C3F6E),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Creating account…',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Please wait',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
