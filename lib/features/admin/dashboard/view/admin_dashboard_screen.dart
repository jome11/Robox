import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/robox_button.dart';
import '../../../../core/widgets/stat_strip.dart';
import '../../../../data/models/task_model.dart';
import '../../../../data/models/inventory_item.dart';
import '../../../../data/models/financial_record.dart';
import '../../../../data/repositories/admin_repository.dart';
import '../../../../data/repositories/task_repository.dart';
import '../helpers/dashboard_data_helper.dart';
import '../widgets/financial_comparison_chart.dart';
import '../widgets/inventory_breakdown_list.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../pending_requests/bloc/pending_requests_bloc.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final TaskRepository _taskRepository = TaskRepositoryImpl();
  final AdminRepository _adminRepository = AdminRepositoryImpl();

  List<TaskModel> _tasks = [];
  List<InventoryItem> _inventory = [];
  List<FinancialRecord> _financialData = [];
  int _workerCount = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Trigger pending requests fetch in the bloc so the badge updates
      if (mounted) {
        context.read<PendingRequestsBloc>().add(FetchPendingRequests());
      }

      final results = await Future.wait([
        _taskRepository.getAllTasks(),
        _adminRepository.getWorkers(),
      ]);
      setState(() {
        _tasks = results[0] as List<TaskModel>;
        _workerCount = (results[1] as List<Map<String, String>>).length;
        _inventory = DashboardDataHelper.getOpeningStock();
        _financialData = DashboardDataHelper.generateFinancialData();
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Could not load dashboard data. Check your connection.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeTasks = _tasks.where((t) => t.status != TaskStatus.completed).toList();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dashboard', style: AppTextStyles.headline),
                      const SizedBox(height: 4),
                      Text('Team and business overview',
                          style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                  BlocBuilder<PendingRequestsBloc, PendingRequestsState>(
                    builder: (context, state) {
                      if (state is PendingRequestsLoaded && state.requests.isNotEmpty) {
                        return GestureDetector(
                          onTap: () => context.push('/admin/pending-requests'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.person_add_alt_1, size: 16, color: Colors.white),
                                const SizedBox(width: 6),
                                Text(
                                  '${state.requests.length} PENDING',
                                  style: AppTextStyles.label.copyWith(color: Colors.white, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_error!, style: AppTextStyles.body.copyWith(color: Colors.red)),
                      const SizedBox(height: 8),
                      TextButton(onPressed: _loadData, child: const Text('Retry')),
                    ],
                  ),
                )
              else ...[
                  StatStrip(items: [
                    StatStripItem(
                      value: '${activeTasks.length}',
                      label: 'Active Tasks',
                      icon: Icons.assignment_outlined,
                      accentColor: AppColors.primary,
                    ),
                    StatStripItem(
                      value: '$_workerCount',
                      label: 'Workers',
                      icon: Icons.groups_outlined,
                      accentColor: AppColors.warning,
                    ),
                  ]),
                  const SizedBox(height: 24),

                  Text('FINANCIAL TREND (INCOME VS EXPENSE)', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _LegendItem(label: 'Income', color: AppColors.primary),
                      const SizedBox(width: 16),
                      _LegendItem(label: 'Expense', color: AppColors.error),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: SizedBox(
                      height: 200,
                      child: FinancialComparisonChart(data: _financialData),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('INVENTORY BREAKDOWN', style: AppTextStyles.label),
                  const SizedBox(height: 12),
                  InventoryBreakdownList(items: _inventory),
                  const SizedBox(height: 24),

                  RoboxButton(
                    label: 'Allocate New Task',
                    onPressed: () async {
                      await context.push('/admin/tasks');
                      _loadData(); // refresh in case a new task was just created
                    },
                  ),
                  const SizedBox(height: 24),

                  Text('ACTIVE TASK GROUPS', style: AppTextStyles.label),
                  const SizedBox(height: 12),
                  if (activeTasks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text('No active tasks right now.',
                          style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: activeTasks.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final task = activeTasks[index];
                        final memberCount = task.assignedWorkers.length;
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(task.title, style: AppTextStyles.body),
                                    Text(
                                      memberCount == 0
                                          ? 'Unassigned'
                                          : memberCount == 1
                                          ? task.assignedWorkers.first.name
                                          : '$memberCount active members',
                                      style: AppTextStyles.label,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: AppColors.primary),
                            ],
                          ),
                        );
                      },
                    ),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.label.copyWith(fontSize: 10)),
      ],
    );
  }
}
