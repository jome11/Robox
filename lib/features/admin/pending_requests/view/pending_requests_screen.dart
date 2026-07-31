import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/pending_requests_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/robox_button.dart';

class PendingRequestsScreen extends StatefulWidget {
  const PendingRequestsScreen({super.key});

  @override
  State<PendingRequestsScreen> createState() => _PendingRequestsScreenState();
}

class _PendingRequestsScreenState extends State<PendingRequestsScreen> {
  @override
  void initState() {
    super.initState();
    // Refetch every time this screen is opened, so new signups
    // submitted after the admin section first loaded actually show up.
    context.read<PendingRequestsBloc>().add(FetchPendingRequests());
  }

  void _confirmReject(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Reject Request', style: AppTextStyles.headline.copyWith(fontSize: 20)),
        content: Text('Are you sure you want to reject the registration request from $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('CANCEL', style: AppTextStyles.label),
          ),
          TextButton(
            onPressed: () {
              context.read<PendingRequestsBloc>().add(RejectRequest(id));
              Navigator.pop(dialogContext);
            },
            child: Text('REJECT', style: AppTextStyles.label.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PENDING APPROVALS', style: AppTextStyles.label),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: BlocConsumer<PendingRequestsBloc, PendingRequestsState>(
        listener: (context, state) {
          if (state is RequestActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.primary),
            );
          }
          if (state is PendingRequestsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          if (state is PendingRequestsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PendingRequestsLoaded) {
            if (state.requests.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<PendingRequestsBloc>().add(FetchPendingRequests());
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_outline, size: 64, color: AppColors.textMuted.withAlpha(100)),
                            const SizedBox(height: 16),
                            Text('No pending requests right now', style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<PendingRequestsBloc>().add(FetchPendingRequests());
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: state.requests.length,
                itemBuilder: (context, index) {
                  final request = state.requests[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  request.name,
                                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('MMM dd, HH:mm').format(request.requestedDate),
                                style: AppTextStyles.label.copyWith(fontSize: 10),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(request.email, style: AppTextStyles.label),
                          const Divider(height: 24, color: AppColors.border),
                          Row(
                            children: [
                              Expanded(
                                child: RoboxButton(
                                  label: 'REJECT',
                                  isSecondary: true,
                                  onPressed: () => _confirmReject(context, request.id, request.name),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: RoboxButton(
                                  label: 'APPROVE',
                                  onPressed: () => context.read<PendingRequestsBloc>().add(ApproveRequest(request.id)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return Center(
            child: RoboxButton(
              label: 'RETRY FETCH',
              onPressed: () => context.read<PendingRequestsBloc>().add(FetchPendingRequests()),
            ),
          );
        },
      ),
    );
  }
}