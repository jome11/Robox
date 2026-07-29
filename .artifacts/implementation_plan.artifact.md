# Implementation Plan - Light Theme Update

Update the app's theme from dark (Robotic Blue/Electric Cyan) to a light theme (White/Blue) by centralizing changes in the core theme files.

## User Review Required

> [!IMPORTANT]
> The primary color is changing from `Electric Cyan` (light) to `Strong Blue` (darker). This affects `onPrimary` and contrast on elements like `RoboxButton`.

## Proposed Changes

### Core Theme
#### [MODIFY] [app_colors.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/core/theme/app_colors.dart)
Update the color palette to the new light scheme:
- `background`: `#F7F9FC`
- `surface`: `#F0F4FA`
- `surfaceHigh`: `#E3EAF5`
- `primary`: `#1565C0`
- `onPrimary`: `#FFFFFF`
- `secondary`: `#42A5F5`
- `onSecondary`: `#FFFFFF`
- `text`: `#1A1F2B`
- `textMuted`: `#6B7280`
- `border`: `#D6DEEA`

#### [MODIFY] [app_theme.dart](file:///C:/Users/PAVILION/Desktop/Robox/lib/core/theme/app_theme.dart)
Update `ThemeData` to reflect the light mode:
- Set `brightness` to `Brightness.light`.
- Use `ColorScheme.light`.
- Ensure `AppBarTheme`, `InputDecorationTheme`, `CardThemeData`, and `ButtonTheme` work well with light colors.

## Verification Plan

### Manual Verification
- **Login Screen**: Verify headline and button readability.
- **Admin Dashboard**: Check the LineChart visibility against the new light background.
- **Worker Dashboard**: Verify task progress bars and stat cards.
- **Leaderboard**: Check the "You" highlight row contrast.
- **Bottom Navigation**: Ensure the frosted glass effect still looks good in light mode.
- **Task Allocation/Finance**: Verify form fields and transaction logs.
