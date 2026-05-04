# Proposal: Remove AI & Analytics Section

| Field          | Value                                    |
| -------------- | ---------------------------------------- |
| **Change ID**  | `remove-ai-analytics-section`            |
| **Status**     | Draft                                    |
| **Created**    | 2026-01-03                               |

## Summary

Remove the "AI & Phân tích" (AI & Analytics) section from the Settings screen and delete the unused `analytics_screen.dart` file. This simplifies the settings UI by removing AI-related features that are not functional in the current e-commerce app.

## Motivation

The current Settings screen includes an "AI & Phân tích" section with:
- Auto-analysis toggle
- Sensitive content filter toggle
- AI sensitivity slider

These features appear to be leftover from a previous design (possibly a comment analysis system) and are not connected to any backend functionality in the e-commerce context. Removing them cleans up the UI and reduces user confusion.

Additionally, `analytics_screen.dart` exists in the codebase but is never used in routing or navigation.

## Scope

### In Scope
- Remove "AI & Phân tích" section from `settings_screen.dart`
- Remove associated state variables (`_autoAnalysis`, `_filterSensitive`, `_aiSensitivity`)
- Remove `_buildSliderTile` method (only used for AI sensitivity)
- Delete unused `analytics_screen.dart` file

### Out of Scope
- Backend analytics API endpoints (can be cleaned up separately)
- Other settings sections (Notifications, Theme, Account, etc.)
- Admin Reports screen (separate feature with different purpose)

## Impact

- **Files Modified**: 1 (`settings_screen.dart`)
- **Files Deleted**: 1 (`analytics_screen.dart`)
- **Breaking Changes**: None (removes unused features)
- **User Impact**: Cleaner settings screen without confusing AI options

## Related

- No dependencies on other specs
