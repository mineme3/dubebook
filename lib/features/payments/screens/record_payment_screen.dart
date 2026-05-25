import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/theme.dart';
import '../../../core/models/payment_record.dart';
import '../providers/payment_provider.dart';

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

  static const _methods = [
    ('cash', 'Cash', Icons.money_rounded),
    ('mobile_money', 'Mobile Money', Icons.phone_android_rounded),
    ('bank_transfer', 'Bank Transfer', Icons.account_balance_rounded),
    ('other', 'Other', Icons.more_horiz_rounded),
  ];

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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('RECORD PAYMENT')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Current balance
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.textSecondary.withOpacity(0.1))),
            child: Column(children: [
              const Text('CURRENT BALANCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: AppTheme.textSecondary)),
              const SizedBox(height: 8),
              Text('${widget.outstandingBalance.toStringAsFixed(2)} ETB',
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue)),
            ]),
          ),
          const SizedBox(height: 28),
          // Amount
          TextFormField(
            controller: _amount, autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(labelText: 'Payment Amount (ETB)', prefixIcon: Icon(Icons.payments_rounded, size: 22)),
            onChanged: (_) => setState(() {}),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              final n = double.tryParse(v);
              if (n == null || n <= 0) return 'Must be > 0';
              if (n > widget.outstandingBalance) return 'Exceeds balance';
              return null;
            },
          ),
          const SizedBox(height: 24),
          // Payment method
          const Text('PAYMENT METHOD', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2, color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          Wrap(spacing: 10, runSpacing: 10, children: _methods.map((m) {
            final selected = _method == m.$1;
            return GestureDetector(
              onTap: () => setState(() => _method = m.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.primaryBlue : AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: selected ? AppTheme.primaryBlue : AppTheme.textSecondary.withOpacity(0.15)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(m.$3, size: 18, color: selected ? Colors.white : AppTheme.textSecondary),
                  const SizedBox(width: 8),
                  Text(m.$2, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: selected ? Colors.white : AppTheme.textPrimary)),
                ]),
              ),
            );
          }).toList()),
          const SizedBox(height: 24),
          // Note
          TextFormField(
            controller: _note, maxLines: 2,
            style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(labelText: 'Note (optional)', prefixIcon: Icon(Icons.note_rounded, size: 22)),
          ),
          const SizedBox(height: 32),
          // Projected balance
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.accentGreen.withOpacity(0.06), borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.accentGreen.withOpacity(0.2))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Before', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textSecondary.withOpacity(0.5))),
                Text('${widget.outstandingBalance.toStringAsFixed(0)} ETB', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
              ]),
              const Icon(Icons.arrow_forward_rounded, color: AppTheme.accentGreen),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('After', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textSecondary.withOpacity(0.5))),
                Text('${_projectedAfter.toStringAsFixed(0)} ETB',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _projectedAfter == 0 ? AppTheme.accentGreen : AppTheme.primaryBlue)),
              ]),
            ]),
          ),
          const SizedBox(height: 40),
          SizedBox(height: 64, child: ElevatedButton(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGreen),
            child: _saving
              ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white)))
              : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.check_circle_rounded, size: 22), SizedBox(width: 12), Text('RECORD PAYMENT'),
                ]),
          )),
        ])),
      ),
    );
  }

  @override
  void dispose() { _amount.dispose(); _note.dispose(); super.dispose(); }
}
