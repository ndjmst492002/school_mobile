import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../data/services/auth_api.dart';
import 'login_controller.dart';
import '../../../main.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<ThemeService>();
    return Obx(() {
      final isDark = theme.isDarkMode;
      return Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF18181B)
            : Colors.white,
        body: Stack(
          textDirection: TextDirection.ltr,
          children: [
            _AnimatedBackground(isDark: isDark),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Card(
                    elevation: 8,
                    color: isDark ? const Color(0xFF27272A) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
                          Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.darkPrimary : AppTheme.primary,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Icon(
                                Icons.school_outlined,
                                size: 48,
                                color: isDark ? AppTheme.darkPrimaryForeground : Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Mouktassab'.tr,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to your account'.tr,
                            style: TextStyle(
                              color: isDark
                                  ? AppTheme.darkMutedForeground
                                  : AppTheme.mutedForeground,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          Obx(() {
                            if (controller.error.value != null) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red[700],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        controller.error.value!,
                                        style: TextStyle(
                                          color: Colors.red[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }),
                          Obx(
                            () => Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => controller.switchTab('email'),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: controller.selectedTab.value == 'email'
                                                ? (isDark ? AppTheme.darkPrimary : AppTheme.primary)
                                : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'Email'.tr,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: controller.selectedTab.value == 'email'
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: controller.selectedTab.value == 'email'
                                          ? (isDark ? AppTheme.darkPrimary : AppTheme.primary)
                                          : (isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => controller.switchTab('phone'),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: controller.selectedTab.value == 'phone'
                                            ? (isDark ? AppTheme.darkPrimary : AppTheme.primary)
                                            : Colors.transparent,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Phone'.tr,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: controller.selectedTab.value == 'phone'
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                      color: controller.selectedTab.value == 'phone'
                                          ? (isDark ? AppTheme.darkPrimary : AppTheme.primary)
                                          : (isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Obx(
                            () => AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                              child: controller.selectedTab.value == 'email'
                                  ? _EmailForm(key: const ValueKey('email'), isDark: isDark)
                                  : _PhoneForm(key: const ValueKey('phone'), isDark: isDark),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: isDark
                                      ? AppTheme.darkBorder
                                      : AppTheme.border,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'or'.tr,
                                  style: TextStyle(
                                    color: isDark
                                        ? AppTheme.darkMutedForeground
                                        : AppTheme.mutedForeground,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: isDark
                                      ? AppTheme.darkBorder
                                      : AppTheme.border,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Google Sign In button
                          SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : controller.signInWithGoogle,
                              child: Text('Sign in with Google'.tr),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => Get.toNamed(AppRoutes.signup),
                            child: Text(
                              'Don\'t have an account? Sign Up'.tr,
                              style: TextStyle(
                                color: isDark ? AppTheme.darkPrimary : AppTheme.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: Row(
                children: [
                  _buildIconButton(
                    icon: Obx(() {
                      final theme = Get.find<ThemeService>();
                      return Text(
                        theme.locale.languageCode == 'en' ? '\u0639' : 'EN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      );
                    }),
                    onPressed: () {
                      final theme = Get.find<ThemeService>();
                      theme.toggleLanguage();
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildIconButton(
                    icon: Obx(() {
                      final theme = Get.find<ThemeService>();
                      return Icon(
                        theme.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        color: isDark ? Colors.white : Colors.black87,
                      );
                    }),
                    onPressed: () {
                      final theme = Get.find<ThemeService>();
                      theme.toggleTheme();
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildIconButton(
                    icon: Icon(
                      Icons.contact_mail,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    onPressed: () => _showContactDialog(context, isDark),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showContactDialog(BuildContext context, bool isDark) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final messageController = TextEditingController();
    final isSubmitting = false.obs;

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? const Color(0xFF27272A) : Colors.white,
        title: Text(
          'Contact Us'.tr,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Your Name'.tr,
                  labelStyle: TextStyle(
                    color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF18181B)
                      : AppTheme.muted,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Your Email'.tr,
                  labelStyle: TextStyle(
                    color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF18181B)
                      : AppTheme.muted,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: messageController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Message'.tr,
                  labelStyle: TextStyle(
                    color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF18181B)
                      : AppTheme.muted,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel'.tr)),
          Obx(
            () => ElevatedButton(
              onPressed: isSubmitting.value
                  ? null
                  : () async {
                      if (nameController.text.isEmpty ||
                          emailController.text.isEmpty ||
                          messageController.text.isEmpty) {
                        Get.snackbar('Error'.tr, 'Please fill in all fields'.tr);
                        return;
                      }
                      isSubmitting.value = true;
                      try {
                        final authApi = AuthApi();
                        await authApi.contactUs(
                          name: nameController.text,
                          email: emailController.text,
                          message: messageController.text,
                        );
                        Get.back();
                        Get.snackbar('Success'.tr, 'Your message has been sent'.tr);
                      } catch (e) {
                        Get.snackbar('Error'.tr, 'Failed to send message'.tr);
                      } finally {
                        isSubmitting.value = false;
                      }
                    },
              child: isSubmitting.value
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('Send'.tr),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    final theme = Get.find<ThemeService>();
    return Obx(
      () => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.isDarkMode ? Colors.transparent : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.isDarkMode ? Colors.white38 : Colors.black26,
                width: 1,
              ),
            ),
            child: icon,
          ),
        ),
      ),
    );
  }
}

class _AnimatedBackground extends StatefulWidget {
  final bool isDark;
  const _AnimatedBackground({required this.isDark});

  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 7),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _MatrixPainter(
            animation: _controller.value,
            isDark: widget.isDark,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _MatrixPainter extends CustomPainter {
  final double animation;
  final bool isDark;

  _MatrixPainter({required this.animation, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < 3; i++) {
      final x = size.width * (0.25 + i * 0.25);
      final dropPosition = (animation + i * 0.3) % 1.0;

      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          isDark
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.15),
          isDark
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.15),
        ],
      );

      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromLTWH(
            x - 0.5,
            size.height * (dropPosition - 0.15),
            1,
            size.height * 0.2,
          ),
        );

      canvas.drawLine(
        Offset(x, size.height * (dropPosition - 0.15)),
        Offset(x, size.height * dropPosition),
        paint..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MatrixPainter oldDelegate) =>
      oldDelegate.animation != animation || oldDelegate.isDark != isDark;
}

class _EmailForm extends StatelessWidget {
  final bool isDark;
  const _EmailForm({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();
    return Column(
      children: [
        TextField(
          controller: controller.emailController,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            labelText: 'Email'.tr,
            hintText: 'Enter your email'.tr,
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        Obx(
          () => TextField(
            controller: controller.passwordController,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              labelText: 'Password'.tr,
              hintText: 'Enter your password'.tr,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.showPassword.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground,
                ),
                onPressed: controller.toggleShowPassword,
              ),
            ),
            obscureText: !controller.showPassword.value,
          ),
        ),
        const SizedBox(height: 32),
        Obx(
          () => SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: controller.isLoading.value ? null : controller.login,
              style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppTheme.darkPrimary : AppTheme.primary,
                foregroundColor: isDark ? AppTheme.darkPrimaryForeground : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: controller.isLoading.value
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('Logging in...'.tr),
                      ],
                    )
                  : Text(
                      'Login'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PhoneForm extends StatelessWidget {
  final bool isDark;
  const _PhoneForm({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();
    return Column(
      children: [
        Obx(() {
          if (!controller.otpSent.value) {
            return Column(
              children: [
                TextField(
                  controller: controller.phoneController,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Phone Number'.tr,
                    hintText: 'Enter your phone number'.tr,
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 32),
                Obx(
                  () => SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.sendOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppTheme.darkPrimary : AppTheme.primary,
                        foregroundColor: isDark ? AppTheme.darkPrimaryForeground : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text('Sending...'.tr),
                              ],
                            )
                          : Text(
                              'Send Code'.tr,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                TextField(
                  controller: controller.otpController,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Verification Code'.tr,
                    hintText: 'Enter verification code'.tr,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 32),
                Obx(
                  () => SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.verifyOTPAndLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppTheme.darkPrimary : AppTheme.primary,
                        foregroundColor: isDark ? AppTheme.darkPrimaryForeground : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text('Verifying...'.tr),
                              ],
                            )
                          : Text(
                              'Verify & Login'.tr,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    controller.otpSent.value = false;
                    controller.otpController.clear();
                  },
                  child: Text('Change Phone Number'.tr),
                ),
              ],
            );
          }
        }),
      ],
    );
  }

  void _showContactUsDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final messageController = TextEditingController();
    final isLoading = false.obs;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contact Us'.tr),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Message'.tr,
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'.tr),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: isLoading.value
                  ? null
                  : () async {
                      if (nameController.text.isEmpty ||
                          emailController.text.isEmpty ||
                          messageController.text.isEmpty) {
                        Get.snackbar('Error'.tr, 'Please fill all fields'.tr);
                        return;
                      }
                      isLoading.value = true;
                      try {
                        final loginController = Get.find<LoginController>();
                        await loginController.contactUs(
                          name: nameController.text,
                          email: emailController.text,
                          message: messageController.text,
                        );
                        Navigator.pop(context);
                        Get.snackbar(
                          'Success'.tr,
                          'Message sent successfully!'.tr,
                        );
                      } catch (e) {
                        Get.snackbar('Error'.tr, 'Failed to send message'.tr);
                      } finally {
                        isLoading.value = false;
                      }
                    },
              child: isLoading.value
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('Send'.tr),
            ),
          ),
        ],
      ),
    );
  }
}
