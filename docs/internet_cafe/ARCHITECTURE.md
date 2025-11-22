# Architecture and Reasoning

This document summarizes the assumptions used to produce the Flutter and Carbon artifacts in this folder and highlights extension points for future business rules.

## Assumptions
- Flutter targets Web and Desktop (Material 3) and communicates with Carbon via a JSON CLI process started by Dart.
- The Carbon core computes pricing for sessions and ad-hoc services, and produces daily reports summarizing revenue, usage, and penalties.
- Pricing rules are intentionally modular so features like happy hours, VIP discounts, and no-show penalties can be added by extending either the Carbon pricing functions or the tariff rule definitions.

## Extension guidance
- **Add time-based or membership discounts**: introduce new `TariffRuleCondition` variants in Carbon and map them from Dart, then branch in `apply_tariff_rules`.
- **Add new services**: extend the `ServiceType` enum in both languages, add mapping in `JsonServiceRequest`, and render new cards in the Flutter `ServiceRequestScreen`.
- **Reporting frequency**: the `ReportFrequency` enum currently holds daily/weekly/monthly; extend it to yearly with minor changes in `report_from_usage`.

## Data ownership
- Flutter holds optimistic UI state (reservations, requests) and persists to its backend (not shown here). Carbon is stateless; it receives a JSON request, computes pricing/reporting, and returns JSON.
