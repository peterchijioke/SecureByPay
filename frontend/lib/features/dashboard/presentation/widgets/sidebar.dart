import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_service.dart';
import '../../../../shared/widgets/app_icons.dart';

class _NavItem {
  final String title;
  final String svgAsset; // empty = use Material icon
  const _NavItem(this.title, this.svgAsset);
}

const _items = [
  _NavItem('Dashboard', 'assets/icons/dashboard.svg'),
  _NavItem('Shipments', 'assets/icons/ship.svg'),
  _NavItem('Our Services', 'assets/icons/globe.svg'),
  _NavItem('Notifications', 'assets/icons/bell.svg'),
  _NavItem('Wallet', 'assets/icons/credit-card.svg'),
  _NavItem('My Addresses', 'assets/icons/locate-fixed.svg'),
  _NavItem('Invite & Earn', 'assets/icons/badge-dollar-sign.svg'),
  _NavItem('Help Center', 'assets/icons/hand-helping.svg'),
];

class DashboardSidebar extends StatelessWidget {
  final String activeRoute;
  final Function(String)? onSelectRoute;
  // kept for compat
  final bool showHeader;

  const DashboardSidebar({
    Key? key,
    this.activeRoute = 'Dashboard',
    this.onSelectRoute,
    this.showHeader = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = ApiService().currentUser;
    final firstName = user?.firstName ?? 'Firstname';
    final lastName = user?.lastName ?? 'Lastname';
    final email = user?.email ?? 'user@example.com';
    final initials = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'F';

    return Container(
      width: 230,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFEAECF0), width: 1)),
      ),
      child: Column(
        children: [
          // ── Sidebar Header (empty spacing matching Figma design) ───────
          const SizedBox(height: 80),

          // ── Nav (flex:1, scrollable) ──────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(10, 16, 10, 8),
              children: _items.map((item) {
                final isActive = activeRoute == item.title;
                return _NavTile(
                  item: item,
                  isActive: isActive,
                  onTap: () => onSelectRoute?.call(item.title),
                );
              }).toList(),
            ),
          ),

          // ── Footer: user + logout ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFEAECF0), width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Avatar with gradient (matches .user-avatar CSS)
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFC4956B), Color(0xFFA0724A)],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$firstName\n$lastName',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            email,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF94A3B8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Logout button
                InkWell(
                  onTap: () {
                    ApiService().logout();
                    context.go('/login');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.logout_rounded,
                            size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        const Text('Logout',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            )),
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
}

class _NavTile extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTile(
      {required this.item, required this.isActive, required this.onTap});

  Widget _iconFor(String title, Color color) {
    switch (title) {
      case 'Dashboard':
        return AppIcons.dashboard(color: color);
      case 'Shipments':
        return AppIcons.shipments(color: color);
      case 'Our Services':
        return AppIcons.services(color: color);
      case 'Notifications':
        return AppIcons.notifications(color: color);
      case 'Wallet':
        return AppIcons.wallet(color: color);
      case 'My Addresses':
        return AppIcons.addresses(color: color);
      case 'Invite & Earn':
        return AppIcons.inviteEarn(color: color);
      case 'Help Center':
        return AppIcons.helpCenter(color: color);
      default:
        return AppIcons.dashboard(color: color);
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = isActive ? Colors.white : const Color(0xFF64748B);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color:
                  isActive ? const Color(0xFF1E243A) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _iconFor(item.title, iconColor),
                const SizedBox(width: 10),
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
