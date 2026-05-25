import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../l10n/app_localizations.dart';
import '../models/customer.dart';
import '../models/app_transaction.dart';
import '../database/database_helper.dart';
import '../utils/theme.dart';
import 'add_transaction_screen.dart';
import '../services/notification_service.dart';
import '../utils/ethiopian_calendar.dart';
import '../services/report_service.dart';

class CustomerDetailScreen extends StatefulWidget {
  final Customer customer;

  const CustomerDetailScreen({super.key, required this.customer});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> with SingleTickerProviderStateMixin {
  List<AppTransaction> _transactions = [];
  bool _isLoading = true;
  double _totalDebt = 0.0;
  late AnimationController _headerController;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    // Load both unpaid and paid transactions to display complete ledger
    final txs = await DatabaseHelper.instance.getTransactionsForCustomer(widget.customer.id!); 
    double total = 0;
    for (var tx in txs) {
      if (tx.status == 0 && tx.transactionType == 'debt') {
        total += tx.total;
      } else if (tx.status == 0 && tx.transactionType == 'payment') {
        total -= tx.total; // Subtract outstanding partial payments
      }
    }
    setState(() {
      _transactions = txs;
      _totalDebt = total;
      _isLoading = false;
    });
    _headerController.forward();
  }

  void _showQrCode() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("QR for ${widget.customer.name}", style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Let the customer scan this code to link or view their account details.", style: TextStyle(fontSize: 12), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Center(
              child: QrImageView(
                data: widget.customer.email ?? widget.customer.id.toString(),
                version: QrVersions.auto,
                size: 200.0,
                eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppTheme.primaryBlue),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close")),
        ],
      ),
    );
  }

  void _recordPartialPayment() {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Record Settlement / Payment", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter the custom amount paid by the customer to partially settle their outstanding debt."),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Amount (ETB)",
                prefixIcon: Icon(Icons.monetization_on_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final val = double.tryParse(amountController.text);
              if (val != null && val > 0) {
                final tx = AppTransaction(
                  customerId: widget.customer.id!,
                  itemName: "Partial Payment Settlement",
                  quantity: 1,
                  price: val,
                  total: val,
                  status: 0, // deductable until settled fully
                  date: DateTime.now(),
                  transactionType: 'payment',
                );
                await DatabaseHelper.instance.insertTransaction(tx);
                if (mounted) Navigator.pop(ctx);
                _loadTransactions();
              }
            },
            child: const Text("Record Payment"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer.name.toUpperCase()),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2_rounded),
            onPressed: _showQrCode,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            onPressed: () => ReportService.generateCustomerReport(widget.customer, _transactions),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, color: AppTheme.error),
            onPressed: _deleteCustomer,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildAnimatedHeader(),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_rounded, color: AppTheme.primaryBlue, size: 16),
                const SizedBox(width: 8),
                Text(
                  l.creditHistory,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppTheme.textSecondary),
                ),
                const Spacer(),
                Text(
                  l.itemsCount(_transactions.length),
                  style: TextStyle(fontSize: 10, color: AppTheme.textSecondary.withOpacity(0.5), fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
              : _buildTransactionList(),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _headerController,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.black.withOpacity(0.04)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          children: [
            Text(
              l.outstandingBalance,
              style: TextStyle(color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
            ),
            const SizedBox(height: 12),
            Text(
              '${_totalDebt.toStringAsFixed(2)} ETB',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: _totalDebt > 0 ? AppTheme.error : AppTheme.accentGreen),
            ),
            if (widget.customer.deadline != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.error.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.event_busy_rounded, size: 16, color: AppTheme.error),
                    const SizedBox(width: 8),
                    Text(
                      'DUE: ${EthiopianCalendar.fromGregorian(widget.customer.deadline!).format(locale: Localizations.localeOf(context).languageCode)}',
                      style: const TextStyle(color: AppTheme.error, fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_transactions.isEmpty) {
      return Center(
        child: Text(l.noUnpaidItems, style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.2), fontWeight: FontWeight.bold, letterSpacing: 2)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final tx = _transactions[index];
        final isDebt = tx.transactionType == 'debt';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black.withOpacity(0.04)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tx.itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      isDebt 
                          ? l.quantityTimesPrice(tx.quantity, tx.price.toStringAsFixed(2))
                          : "Payment / Settlement Deduction",
                      style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Text(
                "${isDebt ? '+' : '-'}${tx.total.toStringAsFixed(2)} ETB",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isDebt ? AppTheme.error : AppTheme.accentGreen),
              ),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, size: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _editTransaction(tx);
                      break;
                    case 'delete':
                      _deleteTransaction(tx);
                      break;
                    case 'pay':
                      _markTransactionAsPaid(tx);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit_rounded, size: 18, color: AppTheme.primaryBlue),
                        const SizedBox(width: 10),
                        Text(l.edit, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  if (tx.status == 0)
                    PopupMenuItem(
                      value: 'pay',
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 18, color: AppTheme.accentGreen),
                          const SizedBox(width: 10),
                          Text(l.payItem, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_rounded, size: 18, color: AppTheme.error),
                        const SizedBox(width: 10),
                        Text(l.deleteTx, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => AddTransactionScreen(customerId: widget.customer.id!)));
                    _loadTransactions();
                  },
                  icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                  label: Text(l.addCredit),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _totalDebt > 0 ? _markAllAsPaid : null,
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  label: Text(l.settleAll),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.accentGreen, width: 1.5),
                foregroundColor: AppTheme.accentGreen,
              ),
              onPressed: _recordPartialPayment,
              icon: const Icon(Icons.payments_rounded, size: 18),
              label: const Text("Record Partial Payment", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _editTransaction(AppTransaction tx) async {
    await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(
          customerId: widget.customer.id!,
          existingTransaction: tx,
        ),
      ),
    );
    _loadTransactions();
  }

  Future<void> _deleteTransaction(AppTransaction tx) async {
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context, 
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l.deleteTransaction, style: const TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold)), 
        content: Text(l.deleteTransactionConfirm), 
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error), 
            onPressed: () => Navigator.pop(ctx, true), 
            child: Text(l.delete)
          )
        ]
      )
    );
    if (ok == true) {
      await DatabaseHelper.instance.deleteTransaction(tx.id!);
      _loadTransactions();
    }
  }

  Future<void> _markTransactionAsPaid(AppTransaction tx) async {
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context, 
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l.markAsPaid, style: const TextStyle(fontWeight: FontWeight.bold)), 
        content: Text(l.markAsPaidConfirm), 
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)), 
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.confirm))
        ]
      )
    );
    if (ok == true) {
      await DatabaseHelper.instance.markTransactionAsPaid(tx.id!);
      _loadTransactions();
    }
  }

  Future<void> _markAllAsPaid() async {
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context, 
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l.settleDebt, style: const TextStyle(fontWeight: FontWeight.bold)), 
        content: Text(l.markAllAsPaidConfirm), 
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)), 
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.confirm))
        ]
      )
    );
    if (ok == true) {
      await DatabaseHelper.instance.markAllCustomerTransactionsAsPaid(widget.customer.id!);
      await NotificationService().cancelNotification(widget.customer.id!);
      _loadTransactions();
    }
  }

  Future<void> _deleteCustomer() async {
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context, 
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l.deleteCustomer, style: const TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold)), 
        content: Text(l.deleteCustomerConfirm), 
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error), 
            onPressed: () => Navigator.pop(ctx, true), 
            child: Text(l.delete)
          )
        ]
      )
    );
    if (ok == true) {
      await DatabaseHelper.instance.deleteCustomer(widget.customer.id!);
      await NotificationService().cancelNotification(widget.customer.id!);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.customer.name.toUpperCase()),
      actions: [
        IconButton(icon: const Icon(Icons.qr_code_2_rounded), onPressed: _showQrCode),
        IconButton(icon: const Icon(Icons.picture_as_pdf_rounded), onPressed: () => ReportService.generateCustomerReport(widget.customer, _transactions)),
        IconButton(icon: const Icon(Icons.delete_sweep_rounded, color: AppTheme.error), onPressed: _deleteCustomer),
      ],
    ),
    body: Column(
      children: [
        _buildAnimatedHeader(),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.receipt_long_rounded, color: AppTheme.primaryBlue, size: 16),
              const SizedBox(width: 8),
              Text(
                l.creditHistory,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppTheme.textSecondary),
              ),
              const Spacer(),
              Text(
                l.itemsCount(_transactions.length),
                style: TextStyle(fontSize: 10, color: AppTheme.textSecondary.withOpacity(0.5), fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
            : _buildTransactionList(),
        ),
        _buildActionButtons(),
      ],
    ),
  );

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }
}
