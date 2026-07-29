# Walkthrough - Light Theme Migration

I have migrated the ROBOX app from the "Industrial-Tech" dark theme to a clean **White-and-Blue light theme**.

## Changes Made

### 1. Theme Configuration
- **[app_colors.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/core/theme/app_colors.dart)**: Updated the palette to a white background (#F7F9FC) with strong blue (#1565C0) and light blue (#42A5F5) accents.
- **[app_theme.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/core/theme/app_theme.dart)**: Switched `brightness` to `Brightness.light` and updated the `ColorScheme` and component themes (AppBar, Inputs, Cards, Buttons) to match.
- **[app.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/app.dart)**: Updated the `MaterialApp` to use the new `lightTheme`.

### 2. UI Verification
The app now uses light surfaces with dark text, significantly improving legibility in high-brightness environments.

## Items for Manual Review

> [!IMPORTANT]
> The following screens use hardcoded transparency values that were tuned for a dark background. Please review these specifically:

- **[Leaderboard Screen](file:///C:/Users/PAVILION/Desktop/Robox/lib/features/shared/leaderboard/view/leaderboard_screen.dart#L93)**: The "YOU" row highlight uses `primary.withAlpha(0.1)`. Since the background is now a light blue-grey, this highlight may be too subtle to distinguish.
- **[Admin Dashboard Chart](file:///C:/Users/PAVILION/Desktop/Robox/lib/features/admin/dashboard/view/admin_dashboard_screen.dart#L67)**: The financial overview chart fill uses `primary.withAlpha(0.12)`. Verify if the fill is visible enough against the white background.
- **[Priority Tags](file:///C:/Users/PAVILION/Desktop/Robox/lib/core/widgets/priority_tag.dart#L34)**: Low-opacity backgrounds (`alpha: 25`) on tags (especially the High/Red tag) might look washed out on the new light surface.
- **[Bottom Navigation](file:///C:/Users/PAVILION/Desktop/Robox/lib/navigation/admin_shell.dart#L24)**: The frosted glass effect uses `surface.withAlpha(200)`. In light mode, this appears as a slightly translucent white/grey bar which may differ from the intended aesthetic.
