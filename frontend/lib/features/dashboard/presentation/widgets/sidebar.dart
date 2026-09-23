import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_service.dart';

class DashboardSidebar extends StatelessWidget {
  final String activeRoute;
  final Function(String)? onSelectRoute;

  const DashboardSidebar({
    Key? key,
    this.activeRoute = 'Dashboard',
    this.onSelectRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = ApiService().currentUser;
    final userName = user?.fullName.isNotEmpty == true ? user!.fullName : 'Bunmi Tanny';

    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'M',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Myafrimall',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Nav Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildNavItem(
                  title: 'Dashboard',
                  icon: Icons.grid_view_rounded,
                  isActive: activeRoute == 'Dashboard',
                ),
                const SizedBox(height: 6),
                _buildNavItem(
                  title: 'Shipments',
                  icon: Icons.local_shipping_outlined,
                  isActive: activeRoute == 'Shipments',
                ),
                const SizedBox(height: 6),
                _buildNavItem(
                  title: 'Our Services',
                  icon: Icons.language_rounded,
                  isActive: activeRoute == 'Our Services',
                ),
                const SizedBox(height: 6),
                _buildNavItem(
                  title: 'Notifications',
                  icon: Icons.notifications_none_rounded,
                  isActive: activeRoute == 'Notifications',
                ),
                const SizedBox(height: 6),
                _buildNavItem(
                  title: 'Wallet',
                  icon: Icons.credit_card_rounded,
                  isActive: activeRoute == 'Wallet',
                ),
                const SizedBox(height: 6),
                _buildNavItem(
                  title: 'My Addresses',
                  icon: Icons.gps_fixed_rounded,
                  isActive: activeRoute == 'My Addresses',
                ),
                const SizedBox(height: 6),
                _buildNavItem(
                  title: 'Invite & Earn',
                  icon: Icons.monetization_on_outlined,
                  isActive: activeRoute == 'Invite & Earn',
                ),
                const SizedBox(height: 6),
                _buildNavItem(
                  title: 'Help Center',
                  icon: Icons.headset_mic_outlined,
                  isActive: activeRoute == 'Help Center',
                ),
              ],
            ),
          ),

          // User row & Logout
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.borderLight, width: 1),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFFD6C7B2),
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Colors.brown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user?.email ?? 'user@example.com',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    ApiService().logout();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.logout_rounded,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
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
      ),
    );
  }

  Widget _buildNavItem({
    required String title,
    required IconData icon,
    required bool isActive,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? AppColors.sidebarActive : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        onTap: () => onSelectRoute?.call(title),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        leading: Icon(
          icon,
          size: 20,
          color: isActive ? Colors.white : AppColors.textSecondary,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
