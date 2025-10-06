import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../core/app_colors.dart';

class DeviceInfoScreen extends StatefulWidget {
  const DeviceInfoScreen({super.key});

  @override
  State<DeviceInfoScreen> createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  Map<String, dynamic> deviceData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    try {
      Map<String, dynamic> data = {};

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        data = {
          'Platform': 'Android',
          'Model': androidInfo.model,
          'Manufacturer': androidInfo.manufacturer,
          'Brand': androidInfo.brand,
          'Device': androidInfo.device,
          'Android Version': androidInfo.version.release,
          'SDK Version': androidInfo.version.sdkInt.toString(),
          'Board': androidInfo.board,
          'Hardware': androidInfo.hardware,
          'Display': androidInfo.display,
          'Product': androidInfo.product,
          'ID': androidInfo.id,
          'Supported ABIs': androidInfo.supportedAbis.join(', '),
          'Is Physical Device': androidInfo.isPhysicalDevice ? 'Ya' : 'Tidak',
        };
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        data = {
          'Platform': 'iOS',
          'Model': iosInfo.model,
          'Name': iosInfo.name,
          'System Name': iosInfo.systemName,
          'System Version': iosInfo.systemVersion,
          'Localized Model': iosInfo.localizedModel,
          'Identifier': iosInfo.identifierForVendor ?? 'Unknown',
          'Is Physical Device': iosInfo.isPhysicalDevice ? 'Ya' : 'Tidak',
        };
      }

      if (!mounted) return;

      setState(() {
        deviceData = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        deviceData = {'Error': 'Gagal memuat info device: $e'};
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const Text(
                      'Info Device',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryBlue,
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon & Title
                              Center(
                                child: Column(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        gradient: AppColors.cardGradient,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primaryBlue
                                                .withValues(alpha: 0.3),
                                            blurRadius: 15,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.phone_android,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      deviceData['Platform'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      deviceData['Model'] ?? 'Unknown Model',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Device Info List
                              const Text(
                                'Informasi Perangkat',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                              const SizedBox(height: 16),

                              ...deviceData.entries.map((entry) {
                                return _buildInfoCard(entry.key, entry.value.toString());
                              }),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightBlue.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accentBlue.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}