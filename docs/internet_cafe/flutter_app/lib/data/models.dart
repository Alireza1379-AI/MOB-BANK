/// Data models shared across the Flutter layers.
/// These align 1:1 with the Carbon structs defined in `carbon_core/main.carbon`.

enum UserRole { customer, operator, admin }

enum ServiceType { printing, scanning, typing, refreshments }

enum ComputerStatus { free, reserved, inUse, offline }

enum ReportFrequency { daily, weekly, monthly }

enum TariffConditionType { happyHour, vipCustomer, noShowPenalty }

enum Currency { usd, eur, gbp }

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final bool isVip;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isVip = false,
  });
}

class OperatorProfile {
  final String id;
  final String userId;
  final List<String> shiftIds;
  const OperatorProfile({required this.id, required this.userId, this.shiftIds = const []});
}

class Computer {
  final String id;
  final String label;
  final ComputerStatus status;
  final bool reserved;
  final String? currentSessionId;

  const Computer({
    required this.id,
    required this.label,
    required this.status,
    this.reserved = false,
    this.currentSessionId,
  });
}

class ServiceRequest {
  final String id;
  final String userId;
  final ServiceType type;
  final int quantity;
  final DateTime requestedAt;
  final bool fulfilled;

  const ServiceRequest({
    required this.id,
    required this.userId,
    required this.type,
    required this.quantity,
    required this.requestedAt,
    this.fulfilled = false,
  });
}

class Session {
  final String id;
  final String userId;
  final String computerId;
  final DateTime startTime;
  final DateTime endTime;
  final Duration billedDuration;
  final bool noShow;

  const Session({
    required this.id,
    required this.userId,
    required this.computerId,
    required this.startTime,
    required this.endTime,
    required this.billedDuration,
    this.noShow = false,
  });
}

class TariffRuleCondition {
  final TariffConditionType type;
  final Map<String, dynamic> params;
  const TariffRuleCondition({required this.type, this.params = const {}});
}

class TariffRule {
  final String id;
  final String name;
  final double pricePerHour;
  final double? discountPercentage;
  final double? surchargePercentage;
  final List<TariffRuleCondition> conditions;

  const TariffRule({
    required this.id,
    required this.name,
    required this.pricePerHour,
    this.discountPercentage,
    this.surchargePercentage,
    this.conditions = const [],
  });
}

class InvoiceLine {
  final String description;
  final double amount;
  const InvoiceLine({required this.description, required this.amount});
}

class Invoice {
  final String id;
  final String userId;
  final Currency currency;
  final List<InvoiceLine> lines;
  final double total;

  const Invoice({
    required this.id,
    required this.userId,
    required this.currency,
    required this.lines,
    required this.total,
  });
}

class DailyReport {
  final DateTime date;
  final double sessionRevenue;
  final double serviceRevenue;
  final int activeSessions;
  final int completedRequests;
  final Map<ServiceType, int> serviceBreakdown;
  final double penalties;
  const DailyReport({
    required this.date,
    required this.sessionRevenue,
    required this.serviceRevenue,
    required this.activeSessions,
    required this.completedRequests,
    required this.serviceBreakdown,
    required this.penalties,
  });
}
