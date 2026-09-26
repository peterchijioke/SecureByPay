import 'package:flutter/material.dart';

/// Matches CSS: .balance-card
/// grid column 2.2fr – rendered as Expanded(flex:22)
class BalanceCard extends StatelessWidget {
  final double balance;
  final VoidCallback onFundWallet;

  const BalanceCard({
    Key? key,
    required this.balance,
    required this.onFundWallet,
  }) : super(key: key);

  String _fmt(double v) {
    return v
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        // .balance-card gradient: #5A65AB → #6570BD
        gradient: const LinearGradient(
          colors: [Color(0xFF5A65AB), Color(0xFF6570BD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5A65AB).withOpacity(0.22),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // .balance-label
          const Text(
            'Your Balance',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xB3FFFFFF), // rgba(255,255,255,0.72)
            ),
          ),
          // .balance-value
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '₦${_fmt(balance)}',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
          // .fund-wallet-btn
          GestureDetector(
            onTap: onFundWallet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Fund Wallet',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5A65AB),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Matches CSS: .stat-card
/// stat icon is a CIRCLE (border-radius: 50%) — 40×40
class StatMetricCard extends StatelessWidget {
  final String title;
  final int count;
  final double growth;
  final int vsLastMonth;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const StatMetricCard({
    Key? key,
    required this.title,
    required this.count,
    required this.growth,
    required this.vsLastMonth,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAECF0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // .stat-card-header
          Row(
            children: [
              // .stat-icon – CIRCLE (border-radius: 50%)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconBgColor,
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // .stat-value-row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(width: 6),
              // .stat-growth-tag
              Row(
                children: [
                  const Icon(Icons.arrow_upward_rounded,
                      size: 11, color: Color(0xFF0A7D00)),
                  Text(
                    '${growth.toInt()}%',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0A7D00),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),

          // .stat-footer
          Text(
            'Vs last month: $vsLastMonth',
            style: const TextStyle(
              fontSize: 10.5,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
