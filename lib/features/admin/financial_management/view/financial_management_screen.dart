import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/robox_button.dart';
import '../../../../core/widgets/income_category_dropdown.dart';
import '../../../../data/models/transaction_model.dart';

class FinancialManagementScreen extends StatefulWidget {
  const FinancialManagementScreen({super.key});

  @override
  State<FinancialManagementScreen> createState() => _FinancialManagementScreenState();
}

class _FinancialManagementScreenState extends State<FinancialManagementScreen> {
  TransactionType _type = TransactionType.income;
  IncomeCategory? _category;
  final _customCategoryController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Mock recent transactions — replace with repository data later.
  final List<TransactionModel> _transactions = [
    TransactionModel(
      id: '1',
      title: 'Filament restock sale',
      amount: 1240.00,
      type: TransactionType.income,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      category: IncomeCategory.filament,
    ),
    TransactionModel(
      id: '2',
      title: 'Grid consumption',
      amount: 450.00,
      type: TransactionType.expense,
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    TransactionModel(
      id: '3',
      title: '3D printer sold',
      amount: 4800.00,
      type: TransactionType.income,
      date: DateTime.now().subtract(const Duration(days: 2)),
      category: IncomeCategory.threeDMachineSale,
    ),
  ];

  @override
  void dispose() {
    _customCategoryController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _logEntry() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;
    if (_type == TransactionType.income && _category == null) return;

    setState(() {
      _transactions.insert(
        0,
        TransactionModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _descriptionController.text.isEmpty
              ? (_type == TransactionType.income ? 'Income entry' : 'Expense entry')
              : _descriptionController.text,
          amount: amount,
          type: _type,
          date: DateTime.now(),
          category: _type == TransactionType.income ? _category : null,
          customCategory: _category == IncomeCategory.other ? _customCategoryController.text : null,
        ),
      );
      _amountController.clear();
      _descriptionController.clear();
      _customCategoryController.clear();
      _category = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Finance', style: AppTextStyles.headline),
            const SizedBox(height: 4),
            Text('Industrial resource allocation and transaction monitoring.', style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 20),

            // Income / Expense toggle
            Row(
              children: [
                Expanded(child: _TypeToggleButton(
                  label: 'Income',
                  selected: _type == TransactionType.income,
                  onTap: () => setState(() => _type = TransactionType.income),
                )),
                const SizedBox(width: 8),
                Expanded(child: _TypeToggleButton(
                  label: 'Expense',
                  selected: _type == TransactionType.expense,
                  onTap: () => setState(() => _type = TransactionType.expense),
                )),
              ],
            ),
            const SizedBox(height: 16),

            if (_type == TransactionType.income) ...[
              IncomeCategoryDropdown(
                selected: _category,
                customController: _customCategoryController,
                onChanged: (c) => setState(() => _category = c),
              ),
              const SizedBox(height: 16),
            ],

            Text('AMOUNT (USD)', style: AppTextStyles.label),
            const SizedBox(height: 8),
            _StyledField(controller: _amountController, hint: '0.00', keyboardType: TextInputType.number),
            const SizedBox(height: 16),

            Text('DESCRIPTION', style: AppTextStyles.label),
            const SizedBox(height: 8),
            _StyledField(controller: _descriptionController, hint: 'Enter transaction details...', maxLines: 3),
            const SizedBox(height: 16),

            RoboxButton(label: 'Log Transaction', onPressed: _logEntry),
            const SizedBox(height: 24),

            Text('RECENT TRANSACTIONS', style: AppTextStyles.label),
            const SizedBox(height: 12),
            ..._transactions.map((t) => _TransactionTile(transaction: t)),
          ],
        ),
      ),
    );
  }
}

class _TypeToggleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeToggleButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(color: selected ? AppColors.onPrimary : AppColors.textMuted),
        ),
      ),
    );
  }
}

class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;

  const _StyledField({required this.controller, required this.hint, this.maxLines = 1, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.title, style: AppTextStyles.body),
                if (transaction.categoryLabel != null)
                  Text(transaction.categoryLabel!, style: AppTextStyles.label),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
            style: AppTextStyles.body.copyWith(
              color: isIncome ? AppColors.primary : AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
