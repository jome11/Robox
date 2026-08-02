import 'package:go_router/go_router.dart';
import '../../features/auth/view/login_screen.dart';
import '../../navigation/admin_shell.dart';
import '../../navigation/worker_shell.dart';
import '../../data/models/user_model.dart';

import '../../features/admin/dashboard/view/admin_dashboard_screen.dart';

import '../../features/worker/dashboard/view/worker_dashboard_screen.dart';

import '../../features/admin/task_allocation/view/task_allocation_screen.dart';
import '../../features/admin/task_allocation/view/create_task_screen.dart';
import '../../features/admin/financial_management/view/financial_management_screen.dart';
import '../../features/admin/stock/view/stock_screen.dart';
import '../../features/shared/leaderboard/view/leaderboard_screen.dart';
import '../../features/worker/my_tasks/view/my_tasks_screen.dart';
import '../../features/worker/finance/view/worker_finance_screen.dart';
import '../../features/shared/chat/view/chat_screen.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/view/signup_screen.dart';
import '../../features/auth/view/forgot_password_screen.dart';
import '../../features/auth/view/pending_approval_screen.dart';
import '../../features/admin/pending_requests/view/pending_requests_screen.dart';
import '../../features/auth/bloc/signup_bloc.dart';
import '../../data/repositories/auth_repository.dart';

class AppRouter {
  static GoRouter router(UserModel? user) {
    return GoRouter(
      initialLocation: user == null ? '/login' : (user.role == UserRole.admin ? '/admin' : '/worker'),
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => BlocProvider(
            create: (context) => SignupBloc(context.read<AuthRepository>()),
            child: const SignupScreen(),
          ),
        ),
        GoRoute(
          path: '/pending-approval',
          builder: (context, state) => const PendingApprovalScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        
        GoRoute(
          path: '/chat/:taskId',
          builder: (context, state) {
            final taskId = state.pathParameters['taskId'] ?? 'unknown';
            final taskTitle = state.extra as String? ?? 'Chat';
            return ChatScreen(taskId: taskId, taskTitle: taskTitle);
          },
        ),

        // Admin Shell
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => AdminShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/admin',
                  builder: (context, state) => const AdminDashboardScreen(),
                  routes: [
                    GoRoute(
                      path: 'pending-requests',
                      builder: (context, state) => const PendingRequestsScreen(),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/admin/tasks',
                  builder: (context, state) => const TaskAllocationScreen(),
                  routes: [
                    GoRoute(
                      path: 'create',
                      builder: (context, state) => const CreateTaskScreen(),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/admin/stock',
                  builder: (context, state) => const StockScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/admin/finance',
                  builder: (context, state) => const FinancialManagementScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/admin/ranking',
                  builder: (context, state) => const LeaderboardScreen(),
                ),
              ],
            ),
          ],
        ),

        // Worker Shell
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => WorkerShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/worker',
                  builder: (context, state) => const WorkerDashboardScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/worker/tasks',
                  builder: (context, state) => const MyTasksScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/worker/finance',
                  builder: (context, state) => const WorkerFinanceScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/worker/ranking',
                  builder: (context, state) => const LeaderboardScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
