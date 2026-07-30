# Walkthrough - Self-Registration with Admin Approval

I have implemented the full "Self-Registration with Admin Approval" flow, adhering to the project's MVVM + BLoC architecture and design system.

## Key Changes

### 1. Registration Workflow (Worker)
- **[SignupScreen](file:///C:/Users/PAVILION/Desktop/Robox/lib/features/auth/view/signup_screen.dart)**: A new registration screen for operators.
    - Includes name, email, and password (with confirmation) fields.
    - Full client-side validation (regex for email, minimum password length, and match check).
    - Distinct error handling for "Email Already Registered" and "Request Already Pending".
- **[PendingApprovalScreen](file:///C:/Users/PAVILION/Desktop/Robox/lib/features/auth/view/pending_approval_screen.dart)**: A clean information screen shown after successful registration, directing users back to login.

### 2. Admin Management (Admin)
- **[PendingRequestsScreen](file:///C:/Users/PAVILION/Desktop/Robox/lib/features/admin/pending_requests/view/pending_requests_screen.dart)**: A dedicated management interface for administrators.
    - View all pending registrations with names, emails, and request timestamps.
    - One-tap Approval and Rejection (with confirmation dialog).
    - Success/Error snackbar feedback.
- **Admin Dashboard Integration**: Added a dynamic notification badge on the Admin Dashboard that displays the current count of pending requests.

### 3. Core Enhancements
- **Multi-Role Login Logic**: Updated the `LoginScreen` and `AuthBloc` to specifically identify and communicate when an account is still awaiting administrator approval.
- **Centralized Repositories**: Integrated `AuthRepository` updates and a new `AdminRepository` into the global provider tree.
- **State Management**: Implemented `SignupBloc` and `PendingRequestsBloc` following the established event/state pattern.

## Verification Results

### Logic & Flow
- [x] **Signup Validation**: Mismatched passwords or invalid emails are caught before submission.
- [x] **Approval Lifecycle**: Approving or Rejecting a request updates the UI list instantly.
- [x] **Dashboard Badge**: The badge automatically updates as requests are processed.

### UI/UX Consistency
- [x] All new screens utilize the "White-and-Blue" light theme.
- [x] Button states (Loading spinners/indicators) are implemented for all network simulations.
- [x] Clean empty states for the pending requests list.

> [!TIP]
> To test the "Pending Approval" login message, use the email `pending@robox.ai`. To test existing email errors in signup, use `exists@robox.ai`.
