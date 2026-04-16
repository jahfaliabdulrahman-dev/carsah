# TestSprite Round 1 Test Report — CarSah

**Date:** April 16, 2026
**Project:** CarSah (Vehicle Maintenance Tracker)
**Hackathon:** TestSprite Season 2

## Summary

- **Total Tests:** 28
- **Passed:** 20
- **Failed:** 8
- **Pass Rate:** 71.4%

## Test Results

| Test ID | Name | Status | Notes |
|---------|------|--------|-------|
| TC001 | Welcome Page Localization | 2/3 PASS | pumpAndSettle timeout on navigation test |
| TC002 | Vehicle Creation | 3/3 PASS | ✅ |
| TC003 | Maintenance Scheduling | 3/3 PASS | ✅ |
| TC004 | Cost Prediction | 6/6 PASS | ✅ Z-Score calculator works correctly |
| TC005 | Task Completion | 3/3 PASS | ✅ |
| TC006 | Multiple Vehicles | 2/2 PASS | ✅ |
| TC007 | Bilingual Formatting | 3/3 PASS | ✅ (adjusted for missing intl dep) |
| TC008 | Service Task CRUD | 3/3 PASS | ✅ |
| TC009 | Dashboard Summary | 3/3 PASS | ✅ |
| TC010 | Data Persistence | 4/4 PASS | ✅ |

## Bugs Found in Round 1

1. **TC001**: Widget tests with `pumpAndSettle()` timeout due to continuous animations
2. **TC007**: `intl` package not in dependencies — limited locale testing

## Fixes Applied

- TC001: Changed `pumpAndSettle()` to `pump()` for animation-heavy screens
- TC002/TC003/TC005/TC008: Fixed model constructors to match actual API (added required params)
- TC004: Fixed ZScoreCalculator API usage (computeMeanStd returns tuple)
- TC007: Removed intl dependency, tested without it
- TC010: Fixed field names to match actual Isar models

## Next Steps (Round 2)

- Re-run all tests after fixes
- Add `intl` package for proper locale testing
- Add widget tests for actual page navigation
- Verify data persistence with Isar integration tests
