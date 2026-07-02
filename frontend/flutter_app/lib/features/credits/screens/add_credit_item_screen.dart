import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../utils/theme.dart';
import '../../../utils/ethiopian_date_picker.dart';
import '../../../utils/ethiopian_calendar.dart';
import '../../../core/models/credit_item.dart';
import '../../../core/models/credit_session.dart';
import '../providers/credit_item_provider.dart';
import '../../../shared/widgets/components/saas_components.dart';
import '../../../l10n/app_localizations.dart';

class AddCreditItemScreen extends ConsumerStatefulWidget {
  final String customerId;
  const AddCreditItemScreen({super.key, required this.customerId});
  @override
  ConsumerState<AddCreditItemScreen> createState() => _AddCreditItemScreenState();
}

class _AddCreditItemScreenState extends ConsumerState<AddCreditItemScreen> {
  final List<CreateCreditItemDto> _items = [];
  
  final _itemName = TextEditingController();
  final _qty = TextEditingController(text: '1');
  final _price = TextEditingController();
  String _unitType = 'kg';
  bool _isKg = true;
  
  DateTime? _deadline;
  Map<String, int>? _ethiopianDeadline;
  bool _saving = false;

  void _addItemToBasket() {
    if (_itemName.text.isEmpty || _price.text.isEmpty) return;
    final q = double.tryParse(_qty.text) ?? 1;
    final p = double.tryParse(_price.text) ?? 0;
    setState(() {
      _items.add(CreateCreditItemDto(
        itemName: _itemName.text.trim(), 
        unitType: _isKg ? 'kg' : 'piece', 
        quantity: q, 
        unitPrice: p,
      ));
      _itemName.clear();
      _qty.text = '1';
      _price.clear();
    });
  }

  double get _itemTotal {
    final q = double.tryParse(_qty.text) ?? 0;
    final p = double.tryParse(_price.text) ?? 0;
    return q * p;
  }

  double get _total => _items.fold(0, (sum, item) => sum + (item.quantity * item.unitPrice));

  Future<void> _saveSession() async {
    if (_items.isEmpty) return;
    setState(() => _saving = true);
    try {
      await ref.read(creditItemActionsProvider).addSession(widget.customerId, CreateCreditSessionDto(items: _items, deadline: _deadline?.toUtc(), ethiopianDeadline: _ethiopianDeadline));
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.newCreditSession.toUpperCase())),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildItemInputCard(theme, l10n),
                  const SizedBox(height: 32),
                  if (_items.isNotEmpty) ...[
                    _buildSectionHeader(l10n.basketItems),
                    const SizedBox(height: 16),
                    _buildBasketList(theme, l10n),
                    const SizedBox(height: 32),
                    _buildSectionHeader(l10n.deadlineOptional),
                    const SizedBox(height: 12),
                    _buildDeadlineSelector(theme, l10n),
                  ],
                ],
              ),
            ),
          ),
          _buildSummaryAndSave(l10n),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(letterSpacing: 1.5, fontWeight: FontWeight.bold));
  }

  Widget _buildItemInputCard(ThemeData theme, AppLocalizations l10n) {
    return SaaSCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _itemName,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l10n.itemName, prefixIcon: const Icon(Icons.shopping_bag_outlined)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: Center(child: Text(l10n.byKg)),
                  selected: _isKg,
                  onSelected: (val) {
                    if (val) {
                      setState(() {
                        _isKg = true;
                        _unitType = 'kg';
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChoiceChip(
                  label: Center(child: Text(l10n.byQuantity)),
                  selected: !_isKg,
                  onSelected: (val) {
                    if (val) {
                      setState(() {
                        _isKg = false;
                        _unitType = 'piece';
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _qty,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: _isKg ? l10n.weightKg : l10n.quantity,
                    prefixIcon: Icon(_isKg ? Icons.scale_outlined : Icons.numbers_outlined),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _price,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: _isKg ? l10n.pricePerKgEtb : l10n.pricePerItemEtb,
                    prefixIcon: const Icon(Icons.payments_outlined),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          if (_itemTotal > 0) ...[
            const SizedBox(height: 16),
            Center(
              child: Text(
                l10n.itemTotalAmount(_itemTotal.toStringAsFixed(0)),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          SaaSButton(label: l10n.addToBasket, variant: SaaSButtonVariant.secondary, icon: Icons.add, onPressed: _addItemToBasket),
        ],
      ),
    );
  }

  Widget _buildBasketList(ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: _items.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SaaSCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.itemName, style: theme.textTheme.titleLarge?.copyWith(fontSize: 16)),
                      Text('${item.quantity} ${item.unitType == 'kg' ? l10n.byKg : l10n.byQuantity} x ${l10n.etbAmount(item.unitPrice.toStringAsFixed(0))}', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Text(l10n.etbAmount((item.quantity * item.unitPrice).toStringAsFixed(0)), style: theme.textTheme.titleLarge?.copyWith(fontSize: 16, color: AppTheme.primary)),
                IconButton(icon: const Icon(Icons.remove_circle_outline, color: AppTheme.error, size: 20), onPressed: () => setState(() => _items.removeAt(i))),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDeadlineSelector(ThemeData theme, AppLocalizations l10n) {
    final deadlineStr = _deadline != null ? DateFormat('MMM dd, yyyy').format(_deadline!.toLocal()) : l10n.selectDeadlineDate;
    return SaaSCard(
      onTap: () async {
        final picked = await showEthiopianDatePicker(context: context, initialDate: DateTime.now());
        if (picked != null) {
          setState(() {
            _deadline = picked;
            final eth = EthiopianCalendar.fromGregorian(picked);
            _ethiopianDeadline = {'year': eth.year, 'month': eth.month, 'day': eth.day};
          });
        }
      },
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined, color: AppTheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              deadlineStr,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: _deadline != null ? AppTheme.textPrimary : AppTheme.textMuted,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_deadline != null) ...[
            IconButton(
              icon: const Icon(Icons.clear, color: AppTheme.error, size: 20),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
              onPressed: () {
                setState(() {
                  _deadline = null;
                  _ethiopianDeadline = null;
                });
              },
            ),
            const SizedBox(width: 12),
            const Icon(Icons.check_circle, color: AppTheme.primary, size: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryAndSave(AppLocalizations l10n) {
    final tokens = Theme.of(context).extension<DubeTokens>()!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppTheme.background, border: Border(top: BorderSide(color: tokens.surfaceBorder))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.total.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppTheme.textMuted)),
                Text(l10n.etbAmount(_total.toStringAsFixed(0)), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(flex: 2, child: SaaSButton(label: l10n.saveSession, isLoading: _saving, onPressed: _items.isEmpty ? null : _saveSession)),
        ],
      ),
    );
  }

  @override
  void dispose() { _itemName.dispose(); _qty.dispose(); _price.dispose(); super.dispose(); }
}
