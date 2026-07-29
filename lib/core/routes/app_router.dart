import 'package:go_router/go_router.dart';
import '../../features/auth/view/login_screen.dart';
import '../../navigation/admin_shell.dart';
import '../../navigation/worker_shell.dart';
import '../../data/models/user_model.dart';

import '../../features/admin/dashboard/view/admin_dashboard_screen.dart';

import '../../features/worker/dashboard/view/worker_dashboard_screen.dart';

import '../../features/admin/task_allocation/view/task_allocation_screen.dart';
import '../../features/admin/financial_management/view/financial_management_screen.dart';
import '../../features/shared/leaderboard/view/leaderboard_screen.dart';
import '../../features/worker/my_tasks/view/my_tasks_screen.dart';
import '../../features/worker/finance/view/worker_finance_screen.dart';
import '../../features/shared/chat/view/chat_screen.dart';

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
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/admin/tasks',
                  builder: (context, state) => const TaskAllocationScreen(),
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
