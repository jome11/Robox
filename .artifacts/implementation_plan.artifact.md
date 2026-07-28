# Implementation Plan - ROBOX Industrial Task/Workforce Management App

Build the ROBOX app with a role-based experience (Admin and Worker) using Flutter, following an MVVM + BLoC architecture with a clean, feature-first folder structure.

## User Review Required

> [!IMPORTANT]
> - **Dependencies**: I will need to add `flutter_bloc`, `equatable`, `go_router`, `google_fonts`, `fl_chart`, and `intl` to `pubspec.yaml`.
> - **Mock Data**: Since there's no backend specified, I will implement mock repositories with in-memory data.
> - **Icons**: I will use Material Icons unless specific custom icons are provided.

## Proposed Changes

### Core Layer
#### [NEW] [app_colors.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/core/theme/app_colors.dart)
Define the Industrial-Tech palette:
- Background: `#101415`
- Surface: `#1d2022`, `#272a2c`
- Accent (Electric Cyan): `#4cd7f6`
- Text: `#e0e3e5`, `#c6c6cd`

#### [NEW] [app_text_styles.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/core/theme/app_text_styles.dart)
Define typography using Inter for headings/body and JetBrains Mono for labels.

#### [NEW] [app_theme.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/core/theme/app_theme.dart)
Configure `ThemeData` with the defined colors and text styles, including card and button themes.

#### [NEW] [app_router.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/core/routes/app_router.dart)
Setup `GoRouter` with routes for Auth, Admin Shell (with sub-routes), and Worker Shell (with sub-routes).

### Data Layer
#### [NEW] [models](file:///C:/Users/PAVILION/Desktop/Robox/lib/data/models/)
- `user_model.dart`: Includes `UserRole` (admin, worker).
- `task_model.dart`: Task details, status, priority.
- `transaction_model.dart`: Amount, type, timestamp.
- `leaderboard_entry_model.dart`: User stats for ranking.

#### [NEW] [repositories](file:///C:/Users/PAVILION/Desktop/Robox/lib/data/repositories/)
- `auth_repository.dart`: Mock login and user role retrieval.
- `task_repository.dart`: Fetch and allocate tasks.
- `finance_repository.dart`: Fetch transactions and business insights.
- `leaderboard_repository.dart`: Fetch rankings.

### Navigation Layer
#### [NEW] [admin_shell.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/navigation/admin_shell.dart)
Bottom navigation shell for Admins (Dashboard, Tasks, Finance, Leaderboard).
#### [NEW] [worker_shell.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/navigation/worker_shell.dart)
Bottom navigation shell for Workers (Dashboard, Tasks, Finance, Leaderboard).

### Feature Layer
#### [NEW] [auth](file:///C:/Users/PAVILION/Desktop/Robox/lib/features/auth/)
- Login screen with BLoC for authentication state.
#### [NEW] [admin/dashboard](file:///C:/Users/PAVILION/Desktop/Robox/lib/features/admin/dashboard/)
- AI Business Insights card.
- Financial Overview chart (`fl_chart`).
- Active Task Groups list.
#### [NEW] [admin/task_allocation](file:///C:/Users/PAVILION/Desktop/Robox/lib/features/admin/task_allocation/)
- Form for creating and assigning tasks.
#### [NEW] [worker/dashboard](file:///C:/Users/PAVILION/Desktop/Robox/lib/features/worker/dashboard/)
- Neural Insights card.
- Task list with progress bars.
#### [NEW] [shared/leaderboard](file:///C:/Users/PAVILION/Desktop/Robox/lib/features/shared/leaderboard/)
- Ranking list, highlighting the current user for workers.

### App Entry
#### [MODIFY] [main.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/main.dart)
Initialize repositories and providers.
#### [NEW] [app.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/app.dart)
MaterialApp with theme and router.

## Verification Plan

### Manual Verification
- Verify role-based routing: Logging in as "admin" redirects to Admin Shell; "worker" redirects to Worker Shell.
- Verify Navigation: Tabs switch correctly and display role-specific content.
- Verify Theme: UI matches the "Industrial-Tech" style (colors, borders, typography).
- Verify Task Allocation: Admin can "create" a task (mock update).
