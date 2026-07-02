import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/theme.dart';
import '../../../core/models/payment_record.dart';
import '../providers/payment_provider.dart';
import '../../../shared/widgets/components/saas_components.dart';
import '../../../l10n/app_localizations.dart';

class RecordPaymentScreen extends ConsumerStatefulWidget {
  final String customerId;
  final double outstandingBalance;
  const RecordPaymentScreen({super.key, required this.customerId, required this.outstandingBalance});
  @override
  ConsumerState<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends ConsumerState<RecordPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  String _method = 'cash';
  bool _saving = false;

  double get _projectedAfter {
    final paid = double.tryParse(_amount.text) ?? 0;
    return (widget.outstandingBalance - paid).clamp(0, double.infinity);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(paymentActionsProvider).recordPayment(
        widget.customerId,
        CreatePaymentDto(
          amountPaid: double.parse(_amount.text),
          paymentMethod: _method,
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        ),
      );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DubeTokens>()!;
    final l10n = AppLocalizations.of(context)!;

    final methods = [
      ('cash', l10n.cash, Icons.money_outlined),
      ('mobile_money', l10n.mobileMoney, Icons.phone_android_outlined),
      ('bank_transfer', l10n.bankTransfer, Icons.account_balance_outlined),
      ('other', l10n.other, Icons.more_horiz_outlined),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.recordPayment.toUpperCase())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SaaSStatCard(
                label: l10n.outstandingBalance, 
                value: l10n.etbAmount(widget.outstandingBalance.toStringAsFixed(0)),
                icon: Icons.account_balance_wallet_outlined,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _amount,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: theme.textTheme.displayLarge?.copyWith(fontSize: 32),
                textAlign: TextAlign.center,
                decoration: InputDecoration(labelText: l10n.paymentAmountEtb, prefixIcon: const Icon(Icons.payments_outlined)),
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v == null || v.isEmpty) return l10n.required;
                  final n = double.tryParse(v);
                  if (n == null || n <= 0) return l10n.mustBeGreaterThanZero;
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Text(l10n.paymentMethod, style: theme.textTheme.bodySmall?.copyWith(letterSpacing: 1.5, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: methods.map((m) {
                  final selected = _method == m.$1;
                  return GestureDetector(
                    onTap: () => setState(() => _method = m.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.primary : tokens.surfaceLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: selected ? AppTheme.primary : tokens.surfaceBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(m.$3, size: 18, color: selected ? AppTheme.background : tokens.onSurfaceMuted),
                          const SizedBox(width: 8),
                          Text(m.$2, style: TextStyle(color: selected ? AppTheme.background : tokens.onSurfaceMuted, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _note,
                maxLines: 2,
                decoration: InputDecoration(labelText: l10n.noteOptional, prefixIcon: const Icon(Icons.note_outlined)),
              ),
              const SizedBox(height: 48),
              SaaSButton(label: l10n.confirmPayment, isLoading: _saving, icon: Icons.check_circle_outline, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() { _amount.dispose(); _note.dispose(); super.dispose(); }
}
