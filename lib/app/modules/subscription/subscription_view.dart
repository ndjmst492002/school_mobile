import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import 'subscription_controller.dart';
import '../../../main.dart';

class SubscriptionView extends GetView<SubscriptionController> {
  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<ThemeService>();
    
    return Obx(() {
      final isDark = theme.isDarkMode;
      
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    color: isDark ? AppTheme.darkCard : AppTheme.card,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 48,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Subscription Required'.tr,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.darkForeground : AppTheme.foreground,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You need an active subscription to access your dashboard'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.border),
                              borderRadius: BorderRadius.circular(12),
                              color: isDark ? AppTheme.darkCard : AppTheme.card,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  controller.planName,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppTheme.darkForeground : AppTheme.foreground,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  controller.planPrice,
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Get unlimited access to all features'.tr,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: Obx(() => ElevatedButton(
                                    onPressed: controller.isLoading.value
                                        ? null
                                        : () => controller.subscribe(),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      backgroundColor: AppTheme.primary,
                                      foregroundColor: AppTheme.primaryForeground,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: controller.isLoading.value
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : Text(
                                            'Subscribe Now'.tr,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  )),
                                ),
                                if (controller.error.value != null) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    controller.error.value!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => controller.logout(),
                    child: Text(
                      'Logout'.tr,
                      style: TextStyle(
                        color: isDark ? Colors.red[400] : Colors.red[500],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
