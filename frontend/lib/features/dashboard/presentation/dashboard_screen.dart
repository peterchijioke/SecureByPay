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

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ApiService _api = ApiService();

  String _activeRoute = 'Dashboard';
  String _selectedGrowthPeriod = 'year';
  String _selectedMonthFilter = 'This Month';

  OverviewMetrics? _overview;
  List<GrowthPoint> _growthPoints = [];
  List<ShipmentModel> _shipments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final overviewFuture = _api.getOverview();
      final growthFuture = _api.getGrowth(_selectedGrowthPeriod);
      final shipmentsFuture = _api.getShipments();

      final results = await Future.wait([
        overviewFuture,
        growthFuture,
        shipmentsFuture,
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePeriodChange(String period) async {
    setState(() {
      _selectedGrowthPeriod = period;
    });
    final points = await _api.getGrowth(period);
    if (mounted) {
      setState(() {
        _growthPoints = points;
      });
    }
  }

  Future<void> _handlePayShipment(ShipmentModel shipment) async {
    try {
      final updated = await _api.payShipment(shipment.id);
      setState(() {
        final index = _shipments.indexWhere((s) => s.id == shipment.id);
        if (index != -1) {
          _shipments[index] = updated;
        }
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment processed for tracking ID ${shipment.trackingId}!'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to process payment: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showFundWalletDialog() {
    final amountController = TextEditingController(text: '50000');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Fund Wallet',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter amount in Naira (₦):',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: '₦ ',
                hintText: '50000',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                Navigator.pop(ctx);
                final newBal = await _api.fundWallet(amount);
                setState(() {
                  _overview = OverviewMetrics(
                    balance: newBal,
                    currency: _overview?.currency ?? 'NGN',
                    totalShipmentsCount: _overview?.totalShipmentsCount ?? 34,
                    totalShipmentsGrowth: _overview?.totalShipmentsGrowth ?? 90,
                    totalShipmentsVsLastMonth: _overview?.totalShipmentsVsLastMonth ?? 4,
                    totalExportsCount: _overview?.totalExportsCount ?? 34,
                    totalExportsGrowth: _overview?.totalExportsGrowth ?? 90,
                    totalExportsVsLastMonth: _overview?.totalExportsVsLastMonth ?? 4,
                    totalImportsCount: _overview?.totalImportsCount ?? 34,
                    totalImportsGrowth: _overview?.totalImportsGrowth ?? 90,
                    totalImportsVsLastMonth: _overview?.totalImportsVsLastMonth ?? 4,
                  );
                });
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Wallet funded successfully!'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Fund', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showViewMoreDialog(ShipmentModel shipment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Shipment ${shipment.trackingId}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Sender', shipment.sender),
            _buildDetailRow('Receiver', shipment.receiver),
            _buildDetailRow('From', '🇳🇬 ${shipment.pickupLocation}'),
            _buildDetailRow('To', '🇳🇬 ${shipment.deliveryLocation}'),
            _buildDetailRow('Amount', '₦${shipment.amount.toInt()}'),
            _buildDetailRow('Status', shipment.status),
            _buildDetailRow('Payment', shipment.paymentStatus),
            _buildDetailRow('Processing Time', '${shipment.processingTimeHours} hours'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
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
          // Sidebar on Desktop
          if (isDesktop)
            DashboardSidebar(
              activeRoute: _activeRoute,
              onSelectRoute: (r) {
                setState(() => _activeRoute = r);
              },
            ),

          // Main Scrollable Content Area
          Expanded(
            child: Column(
              children: [
                // Top AppBar on Mobile/Tablet
                if (!isDesktop)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: Colors.white,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
                          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                        ),
                        const SizedBox(width: 8),
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

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 40 : 20,
                      vertical: 32,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header title & subtitle
                          const Text(
                            AppStrings.dashboardTitle,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            AppStrings.dashboardSubtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Promo Banner
                          const PromoBanner(),
                          const SizedBox(height: 36),

                          // Overview Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Overview',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.border, width: 1),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      _selectedMonthFilter,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // 4 Metric Cards (Responsive Grid)
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final width = constraints.maxWidth;
                              if (width >= 900) {
                                // 4 columns
                                return Row(
                                  children: [
                                    Expanded(
                                      child: BalanceCard(
                                        balance: _overview?.balance ?? 3000000.28,
                                        onFundWallet: _showFundWalletDialog,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: StatMetricCard(
                                        title: 'Total Shipment',
                                        count: _overview?.totalShipmentsCount ?? 34,
                                        growth: _overview?.totalShipmentsGrowth ?? 90,
                                        vsLastMonth: _overview?.totalShipmentsVsLastMonth ?? 4,
                                        icon: Icons.local_shipping_outlined,
                                        iconColor: AppColors.statShipmentIcon,
                                        iconBgColor: AppColors.statShipmentIconBg,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: StatMetricCard(
                                        title: 'Total Exports',
                                        count: _overview?.totalExportsCount ?? 34,
                                        growth: _overview?.totalExportsGrowth ?? 90,
                                        vsLastMonth: _overview?.totalExportsVsLastMonth ?? 4,
                                        icon: Icons.arrow_upward_rounded,
                                        iconColor: AppColors.statExportIcon,
                                        iconBgColor: AppColors.statExportIconBg,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: StatMetricCard(
                                        title: 'Total Import',
                                        count: _overview?.totalImportsCount ?? 34,
                                        growth: _overview?.totalImportsGrowth ?? 90,
                                        vsLastMonth: _overview?.totalImportsVsLastMonth ?? 4,
                                        icon: Icons.arrow_downward_rounded,
                                        iconColor: AppColors.statImportIcon,
                                        iconBgColor: AppColors.statImportIconBg,
                                      ),
                                    ),
                                  ],
                                );
                              } else if (width >= 560) {
                                // 2x2 grid
                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: BalanceCard(
                                            balance: _overview?.balance ?? 3000000.28,
                                            onFundWallet: _showFundWalletDialog,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: StatMetricCard(
                                            title: 'Total Shipment',
                                            count: _overview?.totalShipmentsCount ?? 34,
                                            growth: _overview?.totalShipmentsGrowth ?? 90,
                                            vsLastMonth: _overview?.totalShipmentsVsLastMonth ?? 4,
                                            icon: Icons.local_shipping_outlined,
                                            iconColor: AppColors.statShipmentIcon,
                                            iconBgColor: AppColors.statShipmentIconBg,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: StatMetricCard(
                                            title: 'Total Exports',
                                            count: _overview?.totalExportsCount ?? 34,
                                            growth: _overview?.totalExportsGrowth ?? 90,
                                            vsLastMonth: _overview?.totalExportsVsLastMonth ?? 4,
                                            icon: Icons.arrow_upward_rounded,
                                            iconColor: AppColors.statExportIcon,
                                            iconBgColor: AppColors.statExportIconBg,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: StatMetricCard(
                                            title: 'Total Import',
                                            count: _overview?.totalImportsCount ?? 34,
                                            growth: _overview?.totalImportsGrowth ?? 90,
                                            vsLastMonth: _overview?.totalImportsVsLastMonth ?? 4,
                                            icon: Icons.arrow_downward_rounded,
                                            iconColor: AppColors.statImportIcon,
                                            iconBgColor: AppColors.statImportIconBg,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              } else {
                                // 1 column
                                return Column(
                                  children: [
                                    BalanceCard(
                                      balance: _overview?.balance ?? 3000000.28,
                                      onFundWallet: _showFundWalletDialog,
                                    ),
                                    const SizedBox(height: 14),
                                    StatMetricCard(
                                      title: 'Total Shipment',
                                      count: _overview?.totalShipmentsCount ?? 34,
                                      growth: _overview?.totalShipmentsGrowth ?? 90,
                                      vsLastMonth: _overview?.totalShipmentsVsLastMonth ?? 4,
                                      icon: Icons.local_shipping_outlined,
                                      iconColor: AppColors.statShipmentIcon,
                                      iconBgColor: AppColors.statShipmentIconBg,
                                    ),
                                    const SizedBox(height: 14),
                                    StatMetricCard(
                                      title: 'Total Exports',
                                      count: _overview?.totalExportsCount ?? 34,
                                      growth: _overview?.totalExportsGrowth ?? 90,
                                      vsLastMonth: _overview?.totalExportsVsLastMonth ?? 4,
                                      icon: Icons.arrow_upward_rounded,
                                      iconColor: AppColors.statExportIcon,
                                      iconBgColor: AppColors.statExportIconBg,
                                    ),
                                    const SizedBox(height: 14),
                                    StatMetricCard(
                                      title: 'Total Import',
                                      count: _overview?.totalImportsCount ?? 34,
                                      growth: _overview?.totalImportsGrowth ?? 90,
                                      vsLastMonth: _overview?.totalImportsVsLastMonth ?? 4,
                                      icon: Icons.arrow_downward_rounded,
                                      iconColor: AppColors.statImportIcon,
                                      iconBgColor: AppColors.statImportIconBg,
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 36),

                          // Recent Shipment Section Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Recent shipment',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'See All',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Growth Chart
                          GrowthChart(
                            points: _growthPoints,
                            selectedPeriod: _selectedGrowthPeriod,
                            onPeriodChanged: _handlePeriodChange,
                          ),
                          const SizedBox(height: 24),

                          // Shipment Items List
                          if (_isLoading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: CircularProgressIndicator(),
                              ),
                            )
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
                      ),
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
