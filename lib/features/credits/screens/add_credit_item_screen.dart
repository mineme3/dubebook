import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/theme.dart';
import '../../../utils/ethiopian_date_picker.dart';
import '../../../utils/ethiopian_calendar.dart';
import '../../../core/models/credit_item.dart';
import '../providers/credit_item_provider.dart';

class AddCreditItemScreen extends ConsumerStatefulWidget {
  final String customerId;
  const AddCreditItemScreen({super.key, required this.customerId});
  @override
  ConsumerState<AddCreditItemScreen> createState() => _AddCreditItemScreenState();
}

class _AddCreditItemScreenState extends ConsumerState<AddCreditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemName = TextEditingController();
  final _qty = TextEditingController(text: '1');
  final _price = TextEditingController();
  String _unitType = 'kg';
  DateTime? _deadline;
  double _total = 0;
  bool _saving = false;

  static const _unitTypes = ['kg', 'liter', 'piece', 'pack', 'box', 'other'];

  @override
  void initState() {
    super.initState();
    _qty.addListener(_calc);
    _price.addListener(_calc);
  }

  void _calc() {
    final q = double.tryParse(_qty.text) ?? 0;
    final p = double.tryParse(_price.text) ?? 0;
    setState(() => _total = q * p);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _deadline == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(creditItemActionsProvider).addItem(
        widget.customerId,
        CreateCreditItemDto(
          itemName: _itemName.text.trim(),
          unitType: _unitType,
          quantity: double.parse(_qty.text),
          unitPrice: double.parse(_price.text),
          deadline: _deadline!,
        ),
      );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('NEW CREDIT ITEM')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // Item name
            TextFormField(
              controller: _itemName, autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(labelText: 'Item Name', prefixIcon: Icon(Icons.shopping_bag_rounded, size: 22)),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            // Unit type dropdown
            DropdownButtonFormField<String>(
              value: _unitType,
              decoration: const InputDecoration(labelText: 'Unit Type', prefixIcon: Icon(Icons.straighten_rounded, size: 22)),
              items: _unitTypes.map((u) => DropdownMenuItem(value: u, child: Text(u.toUpperCase()))).toList(),
              onChanged: (v) => setState(() => _unitType = v ?? 'kg'),
            ),
            const SizedBox(height: 20),
            // Quantity + Unit Price
            Row(children: [
              Expanded(child: TextFormField(
                controller: _qty, keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                decoration: const InputDecoration(labelText: 'Qty', prefixIcon: Icon(Icons.numbers_rounded, size: 22)),
                validator: (v) { if (v == null || v.isEmpty) return 'Required'; final n = double.tryParse(v); if (n == null || n <= 0) return 'Invalid'; return null; },
              )),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: TextFormField(
                controller: _price, keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                decoration: const InputDecoration(labelText: 'Unit Price (ETB)', prefixIcon: Icon(Icons.payments_rounded, size: 22)),
                validator: (v) { if (v == null || v.isEmpty) return 'Required'; final n = double.tryParse(v); if (n == null || n <= 0) return 'Invalid'; return null; },
              )),
            ]),
            const SizedBox(height: 20),
            // Deadline picker
            InkWell(
              onTap: () async {
                final d = await showEthiopianDatePicker(context: context, initialDate: DateTime.now());
                if (d != null) setState(() => _deadline = d);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface, borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _deadline == null ? AppTheme.textSecondary.withOpacity(0.1) : AppTheme.primaryBlue.withOpacity(0.3)),
                ),
                child: Row(children: [
                  Icon(Icons.calendar_today_rounded, size: 18, color: _deadline != null ? AppTheme.primaryBlue : AppTheme.textSecondary.withOpacity(0.3)),
                  const SizedBox(width: 12),
                  Text(
                    _deadline == null ? 'Set Payment Deadline *' : EthiopianCalendar.fromGregorian(_deadline!).format(locale: locale),
                    style: TextStyle(color: _deadline == null ? AppTheme.textSecondary.withOpacity(0.5) : AppTheme.textPrimary, fontWeight: FontWeight.bold),
                  ),
                ]),
              ),
            ),
            if (_deadline == null)
              Padding(padding: const EdgeInsets.only(top: 6, left: 12),
                child: Text('Deadline is required', style: TextStyle(color: AppTheme.error.withOpacity(0.7), fontSize: 12))),
            const SizedBox(height: 40),
            // Total
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2), width: 1.5),
                boxShadow: [BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))]),
              child: Column(children: [
                const Text('TOTAL AMOUNT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: AppTheme.textSecondary)),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                  const Text('ETB ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.accentGreen)),
                  Text(_total.toStringAsFixed(2), style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: AppTheme.accentGreen)),
                ]),
              ]),
            ),
            const SizedBox(height: 40),
            // Save button
            SizedBox(height: 64, child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white)))
                : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.save_rounded, size: 22), SizedBox(width: 12), Text('SAVE CREDIT ITEM'),
                  ]),
            )),
          ]),
        ),
      ),
    );
  }

  @override
  void dispose() { _itemName.dispose(); _qty.dispose(); _price.dispose(); super.dispose(); }
}
