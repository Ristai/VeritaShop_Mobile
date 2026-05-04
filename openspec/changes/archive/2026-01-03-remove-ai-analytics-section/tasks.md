# Tasks: Remove AI & Analytics Section

## Implementation Tasks

### 1. Clean up SettingsScreen state variables
- [x] Remove `_autoAnalysis` state variable (line 16)
- [x] Remove `_filterSensitive` state variable (line 17)
- [x] Remove `_aiSensitivity` state variable (line 20)

### 2. Remove AI & Phân tích section from build method
- [x] Remove the "AI & Phân tích" section (lines 61-85) from the `build()` method
- [x] Remove the `SizedBox(height: 16)` after the section

### 3. Remove unused helper method
- [x] Remove `_buildSliderTile` method (lines 275-322) - only used by AI section

### 4. Delete unused analytics screen
- [x] Delete `lib/presentation/screens/analytics_screen.dart`

### 5. Verify no broken imports
- [x] Run `flutter analyze` to confirm no broken references
- [x] Verify the app builds successfully

## Verification

- [x] Settings screen displays without AI section
- [x] All other settings sections work correctly
- [x] No import errors or build failures
