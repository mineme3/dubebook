import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../l10n/app_localizations.dart';
import '../database/database_helper.dart';
import '../models/customer.dart';
import '../models/user.dart';
import '../models/app_transaction.dart';
import '../utils/theme.dart';
import '../utils/ethiopian_calendar.dart';
import '../utils/ethiopian_date_picker.dart';
import '../services/auth_provider.dart';
import '../services/theme_provider.dart';
import '../services/report_service.dart';
import 'customer_detail_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'qr_scanner_screen.dart';
import '../services/notification_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _unpaidCustomers = [];
  List<Map<String, dynamic>> _filteredCustomers = [];
  bool _isLoading = true;
  double _totalUnpaid = 0.0;
  double _totalPaid = 0.0;
  String _searchQuery = "";

  // Customer specific state
  Customer? _currentCustomerRecord;
  List<AppTransaction> _customerTransactions = [];
  double _customerTotalDebt = 0.0;
  double _customerTotalPaid = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;

    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    if (user.role == 'shopkeeper') {
      final data = await DatabaseHelper.instance.getUnpaidCustomersWithDebt(shopkeeperId: user.id);
      
      // Calculate totals
      double totalUnpaid = 0.0;
      for (var item in data) {
        totalUnpaid += (item['total_debt'] as num).toDouble();
      }

      // Fetch all transactions to calculate paid total
      final allTx = await DatabaseHelper.instance.getAllTransactions(shopkeeperId: user.id);
      double totalPaid = 0.0;
      for (var tx in allTx) {
        if (tx.status == 1) {
          totalPaid += tx.total;
        }
      }

      setState(() {
        _unpaidCustomers = data;
        _filteredCustomers = data;
        _totalUnpaid = totalUnpaid;
        _totalPaid = totalPaid;
        _isLoading = false;
      });
    } else {
      // Look up Customer record matching logged-in user email
      final allCustomers = await DatabaseHelper.instance.getCustomers();
      Customer? matchingCustomer;
      for (var c in allCustomers) {
        if (c.email?.toLowerCase().trim() == user.email.toLowerCase().trim()) {
          matchingCustomer = c;
          break;
        }
      }

      if (matchingCustomer != null) {
        final txs = await DatabaseHelper.instance.getTransactionsForCustomer(matchingCustomer.id!);
        double debtTotal = 0.0;
        double paidTotal = 0.0;
        for (var tx in txs) {
          if (tx.transactionType == 'debt' && tx.status == 0) {
            debtTotal += tx.total;
          } else if (tx.status == 1) {
            paidTotal += tx.total;
          }
        }

        setState(() {
          _currentCustomerRecord = matchingCustomer;
          _customerTransactions = txs;
          _customerTotalDebt = debtTotal;
          _customerTotalPaid = paidTotal;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterCustomers(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredCustomers = _unpaidCustomers;
      } else {
        _filteredCustomers = _unpaidCustomers
            .where((c) => (c['name'] as String).toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = auth.currentUser;
    final l = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
      );
    }

    final isShopkeeper = user?.role == 'shopkeeper';

    return Scaffold(
      appBar: AppBar(
        title: Text(isShopkeeper ? l.appName : "My Debt Account"),
        leading: IconButton(
          icon: Icon(themeProvider.isDarkMode ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded),
          onPressed: () => themeProvider.toggleTheme(),
        ),
        actions: [
          if (isShopkeeper) ...[
            IconButton(
              icon: const Icon(Icons.qr_code_scanner_rounded),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QRScannerScreen())),
            ),
            IconButton(
              icon: const Icon(Icons.history_rounded),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
          ),
        ],
      ),
      body: isShopkeeper ? _buildShopkeeperDashboard() : _buildCustomerDashboard(),
      floatingActionButton: isShopkeeper
          ? FloatingActionButton.extended(
              onPressed: _showAddCustomerDialog,
              backgroundColor: AppTheme.primaryBlue,
              label: Text(l.newCustomer, style: const TextStyle(fontWeight: FontWeight.bold)),
              icon: const Icon(Icons.person_add_rounded, color: Colors.white),
            )
          : null,
    );
  }

  // --- SHOPKEEPER DASHBOARD ---
  Widget _buildShopkeeperDashboard() {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User greeting
            Text(
              "Welcome back, ${Provider.of<AuthProvider>(context).currentUser?.fullName ?? ''}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
            ).animate().fade(),
            const SizedBox(height: 16),

            // Overview Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildFintechCard(
                    title: "Total Outstanding",
                    value: "${_totalUnpaid.toStringAsFixed(2)} ETB",
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppTheme.error,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFintechCard(
                    title: "Total Settled",
                    value: "${_totalPaid.toStringAsFixed(2)} ETB",
                    icon: Icons.check_circle_rounded,
                    color: AppTheme.accentGreen,
                  ),
                ),
              ],
            ).animate().fade(delay: 100.ms),

            const SizedBox(height: 24),

            // FlChart Section
            const Text(
              "Financial Analysis",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Container(
              height: 180,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black.withOpacity(0.04)),
              ),
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: _totalUnpaid, color: AppTheme.error, width: 22)]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: _totalPaid, color: AppTheme.accentGreen, width: 22)]),
                  ],
                ),
              ),
            ).animate().fade(delay: 200.ms),

            const SizedBox(height: 24),

            // Search Bar
            TextField(
              onChanged: _filterCustomers,
              decoration: InputDecoration(
                hintText: "Search customer by name...",
                prefixIcon: const Icon(Icons.search_rounded),
                fillColor: isDark ? AppTheme.darkSurface : Colors.black.withOpacity(0.02),
              ),
            ).animate().fade(delay: 300.ms),

            const SizedBox(height: 24),

            // Pending Debts List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l.pendingDebts,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  l.customersCount(_filteredCustomers.length),
                  style: TextStyle(color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _filteredCustomers.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final item = _filteredCustomers[index];
                      final customer = Customer.fromMap(item);
                      final debt = (item['total_debt'] as num).toDouble();
                      final isOverdue = customer.deadline != null && customer.deadline!.isBefore(DateTime.now());

                      return _buildCustomerTile(customer, debt, isOverdue, index);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  // --- CUSTOMER DASHBOARD ---
  Widget _buildCustomerDashboard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_currentCustomerRecord == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64, color: AppTheme.error),
              const SizedBox(height: 16),
              const Text(
                "Profile Not Configured",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Please ask your shopkeeper to register your email (${Provider.of<AuthProvider>(context).currentUser?.email ?? ''}) on their customer ledger list.",
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final totalShare = _customerTotalDebt + _customerTotalPaid;
    final progressPercent = totalShare > 0 ? _customerTotalPaid / totalShare : 0.0;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circular debt visual progress
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.black.withOpacity(0.04)),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 140,
                      width: 140,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: progressPercent,
                            strokeWidth: 12,
                            backgroundColor: AppTheme.error.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation(AppTheme.accentGreen),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${(progressPercent * 100).toStringAsFixed(0)}%",
                                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.accentGreen),
                                ),
                                const Text("Settled Share", style: TextStyle(fontSize: 10, color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatText("Outstanding Debt", "${_customerTotalDebt.toStringAsFixed(2)} ETB", AppTheme.error),
                        _buildStatText("Total Settled", "${_customerTotalPaid.toStringAsFixed(2)} ETB", AppTheme.accentGreen),
                      ],
                    )
                  ],
                ),
              ).animate().scale(duration: 400.ms),
            ),

            const SizedBox(height: 28),

            // Share QR Code card so Shopkeeper can scan
            const Text("My Quick Pay QR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black.withOpacity(0.04)),
                ),
                child: QrImageView(
                  data: _currentCustomerRecord!.email ?? _currentCustomerRecord!.id.toString(),
                  version: QrVersions.auto,
                  size: 150.0,
                  eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppTheme.primaryBlue),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Transaction log ledger
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Transaction Ledger", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton.icon(
                  onPressed: () => ReportService.generateCustomerReport(_currentCustomerRecord!, _customerTransactions),
                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                  label: const Text("Export PDF", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _customerTransactions.isEmpty
                ? const Center(child: Padding(padding: EdgeInsets.all(24.0), child: Text("No transaction history.")))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _customerTransactions.length,
                    itemBuilder: (context, index) {
                      final tx = _customerTransactions[index];
                      final isDebt = tx.transactionType == 'debt';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (isDebt ? AppTheme.error : AppTheme.accentGreen).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isDebt ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                              color: isDebt ? AppTheme.error : AppTheme.accentGreen,
                            ),
                          ),
                          title: Text(tx.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(tx.date.toString().substring(0, 10)),
                          trailing: Text(
                            "${isDebt ? '+' : '-'}${tx.total.toStringAsFixed(2)} ETB",
                            style: TextStyle(fontWeight: FontWeight.w900, color: isDebt ? AppTheme.error : AppTheme.accentGreen),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER BUILDERS ---
  Widget _buildFintechCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatText(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 10, color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildCustomerTile(Customer customer, double debt, bool isOverdue, int index) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isOverdue ? AppTheme.error.withOpacity(0.4) : Colors.black.withOpacity(0.04),
          width: isOverdue ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerDetailScreen(customer: customer)));
          _loadData();
        },
        child: Row(
          children: [
            Hero(
              tag: 'customer-avatar-${customer.id}',
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (isOverdue ? AppTheme.error : AppTheme.primaryBlue).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    customer.name[0].toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isOverdue ? AppTheme.error : AppTheme.primaryBlue),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(isOverdue ? Icons.warning_amber_rounded : Icons.access_time_rounded, size: 12, color: isOverdue ? AppTheme.error : AppTheme.lightTextSecondary),
                      const SizedBox(width: 4),
                      Text(
                        customer.deadline != null
                            ? l.dueDate(EthiopianCalendar.fromGregorian(customer.deadline!).format(locale: Localizations.localeOf(context).languageCode))
                            : l.noDeadlineSet,
                        style: TextStyle(fontSize: 11, color: isOverdue ? AppTheme.error : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary)),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${debt.toStringAsFixed(2)} ETB",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.accentGreen),
                ),
                if (isOverdue)
                  const Text("OVERDUE", style: TextStyle(fontSize: 8, color: AppTheme.error, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    ).animate().fade(duration: 250.ms, delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildEmptyState() {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(Icons.person_search_rounded, size: 64, color: AppTheme.primaryBlue.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              l.noCustomersFound,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCustomerDialog() {
    final l = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final noteController = TextEditingController();
    DateTime? deadline;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text(l.registerCustomer, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: l.fullName, prefixIcon: const Icon(Icons.person_outline)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email Address", prefixIcon: Icon(Icons.email_outlined)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "Phone Number", prefixIcon: Icon(Icons.phone_outlined)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(labelText: "Custom Note", prefixIcon: Icon(Icons.notes_rounded)),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final d = await showEthiopianDatePicker(context: ctx, initialDate: DateTime.now());
                    if (d != null) setState(() => deadline = d);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 18, color: deadline != null ? AppTheme.primaryBlue : Colors.grey),
                        const SizedBox(width: 12),
                        Text(
                          deadline == null ? l.setPaymentDeadline : EthiopianCalendar.fromGregorian(deadline!).format(locale: Localizations.localeOf(ctx).languageCode),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) return;
                final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
                
                final c = Customer(
                  name: nameController.text,
                  email: emailController.text.trim().isEmpty ? null : emailController.text.trim().toLowerCase(),
                  phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                  note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                  deadline: deadline,
                  createdAt: DateTime.now(),
                  shopkeeperId: user?.id,
                );

                final id = await DatabaseHelper.instance.insertCustomer(c);
                if (deadline != null) {
                  try {
                    await NotificationService().scheduleDeadlineNotification(id, c.name, deadline!);
                  } catch (_) {}
                }
                if (context.mounted) {
                  Navigator.pop(ctx);
                  _loadData();
                }
              },
              child: Text(l.register),
            ),
          ],
        ),
      ),
    );
  }
}
