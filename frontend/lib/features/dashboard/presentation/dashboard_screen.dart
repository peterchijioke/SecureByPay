import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_service.dart';
import '../../../core/utils/responsive.dart';
import '../../shipments/models/shipment_model.dart';
import '../../shipments/presentation/widgets/shipment_item_card.dart';
import '../models/dashboard_model.dart';
import 'widgets/growth_chart.dart';
import 'widgets/overview_card.dart';
import 'widgets/promo_banner.dart';
import 'widgets/sidebar.dart';
import '../../../shared/widgets/app_icons.dart';
import '../../../shared/widgets/skeleton_loader.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ApiService _api = ApiService();

  String _activeRoute = 'Invite & Earn';
  String _selectedGrowthPeriod = 'year';
  String _selectedMonthFilter = 'This Month';

  OverviewMetrics? _overview;
  List<GrowthPoint> _growthPoints = [];
  List<ShipmentModel> _shipments = [];
  bool _isLoading = true;

  static const Map<String, Map<String, String>> pageMeta = {
    'Dashboard': {
      'title': 'Dashboard',
      'subtitle': "Welcome back! Here's what's happening with your shipments."
    },
    'Shipments': {
      'title': 'Shipments',
      'subtitle': 'Track and manage all your active and past shipments.'
    },
    'Our Services': {
      'title': 'Our Services',
      'subtitle': 'Explore all available shipping and logistics services.'
    },
    'Notifications': {
      'title': 'Notifications',
      'subtitle': 'Stay updated with alerts and important messages.'
    },
    'Wallet': {
      'title': 'Wallet',
      'subtitle': 'Manage your wallet balance and transaction history.'
    },
    'My Addresses': {
      'title': 'My Addresses',
      'subtitle': 'Keep track of your addresses, location updates, Edit, Delete, Update and see all your saved addresses'
    },
    'Invite & Earn': {
      'title': 'Invite & Earn',
      'subtitle': 'Keep track of your addresses, location updates, Edit, Delete, Update and see all your saved addresses'
    },
    'Help Center': {
      'title': 'Help Center',
      'subtitle': 'Find answers, guides and support for all your questions.'
    },
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _api.getOverview(),
        _api.getGrowth(_selectedGrowthPeriod),
        _api.getShipments(),
      ]);
      if (mounted) {
        setState(() {
          _overview = results[0] as OverviewMetrics;
          _growthPoints = results[1] as List<GrowthPoint>;
          _shipments = results[2] as List<ShipmentModel>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load dashboard data: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _handlePeriodChange(String period) async {
    setState(() => _selectedGrowthPeriod = period);
    try {
      final pts = await _api.getGrowth(period);
      if (mounted) setState(() => _growthPoints = pts);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load growth points: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _handlePayShipment(ShipmentModel shipment) async {
    try {
      final updated = await _api.payShipment(shipment.id);
      setState(() {
        final i = _shipments.indexWhere((s) => s.id == shipment.id);
        if (i != -1) _shipments[i] = updated;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Payment processed for ${shipment.trackingId}!'),
        backgroundColor: AppColors.primary,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed: $e'),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  void _showFundWalletDialog() {
    final ctrl = TextEditingController(text: '50000');
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fund Wallet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Enter the amount you would like to deposit to your wallet:',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: ctrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                  decoration: const InputDecoration(
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 14, right: 8, top: 12),
                      child: Text(
                        '₦',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final amount = double.tryParse(ctrl.text) ?? 0;
                      if (amount > 0) {
                        Navigator.pop(ctx);
                        final newBal = await _api.fundWallet(amount);
                        setState(() {
                          _overview = OverviewMetrics(
                            balance: newBal,
                            currency: _overview?.currency ?? 'NGN',
                            totalShipmentsCount: _overview?.totalShipmentsCount ?? 34,
                            totalShipmentsGrowth: _overview?.totalShipmentsGrowth ?? 90,
                            totalShipmentsVsLastMonth:
                                _overview?.totalShipmentsVsLastMonth ?? 4,
                            totalExportsCount: _overview?.totalExportsCount ?? 34,
                            totalExportsGrowth: _overview?.totalExportsGrowth ?? 90,
                            totalExportsVsLastMonth:
                                _overview?.totalExportsVsLastMonth ?? 4,
                            totalImportsCount: _overview?.totalImportsCount ?? 34,
                            totalImportsGrowth: _overview?.totalImportsGrowth ?? 90,
                            totalImportsVsLastMonth:
                                _overview?.totalImportsVsLastMonth ?? 4,
                          );
                        });
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('₦${amount.toInt()} added to your wallet!'),
                          backgroundColor: AppColors.primary,
                        ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: const Text(
                      'Fund Now',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showViewMoreDialog(ShipmentModel s) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Shipment Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  children: [
                    const TextSpan(text: 'Tracking ID: '),
                    TextSpan(
                      text: s.trackingId,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFEAECF0), height: 1),
              const SizedBox(height: 12),
              _drow('Sender', s.sender),
              _drow('Receiver', s.receiver),
              _drow('From', '🇳🇬 ${s.pickupLocation}'),
              _drow('To', '🇳🇬 ${s.deliveryLocation}'),
              _drow('Amount', '₦${s.amount.toInt()}'),
              _drow('Status', s.status),
              _drow('Payment', s.paymentStatus),
              _drow('Processing', '${s.processingTimeHours} hours'),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
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

  Widget _drow(String l, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l,
                style: const TextStyle(
                    color: Color(0xFF64748B), fontSize: 13)),
            Text(v,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1E293B))),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final meta = pageMeta[_activeRoute] ??
        {
          'title': _activeRoute,
          'subtitle': AppStrings.dashboardSubtitle,
        };

    final isDashboardOrInvite =
        _activeRoute == 'Dashboard' || _activeRoute == 'Invite & Earn';
    final isShipmentsOnly = _activeRoute == 'Shipments';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF4F5F8), // --background
      drawer: isDesktop
          ? null
          : Drawer(
              child: DashboardSidebar(
                activeRoute: _activeRoute,
                onSelectRoute: (r) {
                  setState(() => _activeRoute = r);
                  Navigator.pop(context);
                },
              ),
            ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop)
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: DashboardSidebar(
                activeRoute: _activeRoute,
                onSelectRoute: (r) => setState(() => _activeRoute = r),
              ),
            ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!isDesktop)
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color: Colors.white,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu_rounded,
                              color: Color(0xFF1E293B)),
                          onPressed: () =>
                              _scaffoldKey.currentState?.openDrawer(),
                        ),
                      ],
                    ),
                  ),

                if (isDesktop)
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 80),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFEAECF0), width: 1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          meta['title']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 3),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 340),
                          child: Text(
                            meta['subtitle']!,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isDesktop ? 24 : 16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: double.infinity),
                      child: isDashboardOrInvite
                          ? _buildFullDashboardContent(isDesktop, meta)
                          : isShipmentsOnly
                              ? _buildShipmentsOnlyContent()
                              : _buildEmptyStateContent(meta),
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

  Widget _buildFullDashboardContent(bool isDesktop, Map<String, String> meta) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isDesktop) ...[
          Text(meta['title']!,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B))),
          const SizedBox(height: 3),
          Text(meta['subtitle']!,
              style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF64748B))),
          const SizedBox(height: 16),
        ],

        const PromoBanner(),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Overview',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                )),
            _FilterDropdown(
              value: _selectedMonthFilter,
              onChanged: (v) => setState(() => _selectedMonthFilter = v),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _isLoading
            ? SkeletonOverviewGrid(isDesktop: isDesktop)
            : _buildOverviewGrid(),
        const SizedBox(height: 32),

        const _SectionHeader(
          title: 'Recent shipment',
          trailing: 'See All',
        ),
        const SizedBox(height: 16),

        _isLoading
            ? const SkeletonGrowthChart()
            : GrowthChart(
                points: _growthPoints,
                selectedPeriod: _selectedGrowthPeriod,
                onPeriodChanged: _handlePeriodChange,
              ),
        const SizedBox(height: 16),

        if (_isLoading)
          const SkeletonShipmentList(count: 4)
        else
          ..._shipments.map(
            (s) => ShipmentItemCard(
              shipment: s,
              onPay: () => _handlePayShipment(s),
              onViewMore: () => _showViewMoreDialog(s),
            ),
          ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildShipmentsOnlyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'All Shipments',
          trailing: '',
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const SkeletonShipmentList(count: 4)
        else
          ..._shipments.map(
            (s) => ShipmentItemCard(
              shipment: s,
              onPay: () => _handlePayShipment(s),
              onViewMore: () => _showViewMoreDialog(s),
            ),
          ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildEmptyStateContent(Map<String, String> meta) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: const Color(0xFF64748B).withValues(alpha: 0.35),
          ),
          const SizedBox(height: 20),
          Text(
            meta['title']!,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text(
              meta['subtitle']!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewGrid() {
    return LayoutBuilder(builder: (ctx, cs) {
      if (cs.maxWidth >= 700) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 22,
              child: BalanceCard(
                balance: _overview?.balance ?? 3000000.28,
                onFundWallet: _showFundWalletDialog,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 10,
              child: StatMetricCard(
                title: 'Total Shipment',
                count: _overview?.totalShipmentsCount ?? 34,
                growth: _overview?.totalShipmentsGrowth ?? 90,
                vsLastMonth: _overview?.totalShipmentsVsLastMonth ?? 4,
                customIcon: AppIcons.shipments(color: const Color(0xFFD97706), size: 20),
                iconColor: const Color(0xFFD97706),
                iconBgColor: const Color(0xFFFEF3C7),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 10,
              child: StatMetricCard(
                title: 'Total Exports',
                count: _overview?.totalExportsCount ?? 34,
                growth: _overview?.totalExportsGrowth ?? 90,
                vsLastMonth: _overview?.totalExportsVsLastMonth ?? 4,
                customIcon: AppIcons.exportsArrow(color: const Color(0xFF059669), size: 20),
                iconColor: const Color(0xFF059669),
                iconBgColor: const Color(0xFFD1FAE5),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 10,
              child: StatMetricCard(
                title: 'Total Import',
                count: _overview?.totalImportsCount ?? 34,
                growth: _overview?.totalImportsGrowth ?? 90,
                vsLastMonth: _overview?.totalImportsVsLastMonth ?? 4,
                customIcon: AppIcons.importsArrow(color: const Color(0xFF0891B2), size: 20),
                iconColor: const Color(0xFF0891B2),
                iconBgColor: const Color(0xFFCFFAFE),
              ),
            ),
          ],
        );
      } else {
        return Column(
          children: [
            BalanceCard(
              balance: _overview?.balance ?? 3000000.28,
              onFundWallet: _showFundWalletDialog,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatMetricCard(
                    title: 'Total Shipment',
                    count: _overview?.totalShipmentsCount ?? 34,
                    growth: _overview?.totalShipmentsGrowth ?? 90,
                    vsLastMonth: _overview?.totalShipmentsVsLastMonth ?? 4,
                    customIcon: AppIcons.shipments(color: const Color(0xFFD97706), size: 20),
                    iconColor: const Color(0xFFD97706),
                    iconBgColor: const Color(0xFFFEF3C7),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatMetricCard(
                    title: 'Total Exports',
                    count: _overview?.totalExportsCount ?? 34,
                    growth: _overview?.totalExportsGrowth ?? 90,
                    vsLastMonth: _overview?.totalExportsVsLastMonth ?? 4,
                    customIcon: AppIcons.exportsArrow(color: const Color(0xFF059669), size: 20),
                    iconColor: const Color(0xFF059669),
                    iconBgColor: const Color(0xFFD1FAE5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            StatMetricCard(
              title: 'Total Import',
              count: _overview?.totalImportsCount ?? 34,
              growth: _overview?.totalImportsGrowth ?? 90,
              vsLastMonth: _overview?.totalImportsVsLastMonth ?? 4,
              customIcon: AppIcons.importsArrow(color: const Color(0xFF0891B2), size: 20),
              iconColor: const Color(0xFF0891B2),
              iconBgColor: const Color(0xFFCFFAFE),
            ),
          ],
        );
      }
    });
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String trailing;

  const _SectionHeader({required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            )),
        if (trailing.isNotEmpty)
          Text(trailing,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              )),
      ],
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _FilterDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _show(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        ),
        child: Row(
          children: [
            Text(value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                )),
            const SizedBox(width: 5),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 16, color: Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }

  void _show(BuildContext context) {
    const opts = ['This Month', 'Last Month', 'Last 3 Months', 'This Year'];
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Period'),
        children: opts
            .map((o) => SimpleDialogOption(
                  onPressed: () {
                    onChanged(o);
                    Navigator.pop(ctx);
                  },
                  child: Text(o),
                ))
            .toList(),
      ),
    );
  }
}
