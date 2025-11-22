import 'dart:convert';
import 'dart:io';

import '../data/models.dart';

/// A thin process wrapper that exchanges JSON messages with the Carbon core CLI.
/// The Carbon binary path can be configured via [binaryPath].
class CarbonBridge {
  CarbonBridge({this.binaryPath = './carbon_core'});

  final String binaryPath;

  Future<Invoice> requestSessionInvoice({
    required Session session,
    required TariffRule rule,
    Currency currency = Currency.usd,
  }) async {
    final payload = {
      'type': 'SESSION_INVOICE',
      'session': _sessionToJson(session),
      'tariff': _tariffToJson(rule),
      'currency': currency.name,
    };
    final response = await _send(payload);
    return _invoiceFromJson(response['invoice']);
  }

  Future<Invoice> requestServiceInvoice({
    required ServiceRequest request,
    required TariffRule rule,
    Currency currency = Currency.usd,
  }) async {
    final payload = {
      'type': 'SERVICE_INVOICE',
      'serviceRequest': _serviceRequestToJson(request),
      'tariff': _tariffToJson(rule),
      'currency': currency.name,
    };
    final response = await _send(payload);
    return _invoiceFromJson(response['invoice']);
  }

  Future<DailyReport> requestDailyReport({required DateTime date}) async {
    final payload = {
      'type': 'DAILY_REPORT',
      'date': date.toIso8601String(),
    };
    final response = await _send(payload);
    return _dailyReportFromJson(response['report']);
  }

  Future<Map<String, dynamic>> _send(Map<String, dynamic> payload) async {
    final process = await Process.start(binaryPath, []);
    process.stdin.writeln(jsonEncode(payload));
    await process.stdin.close();
    final rawOutput = await process.stdout.transform(utf8.decoder).join();
    return jsonDecode(rawOutput) as Map<String, dynamic>;
  }

  Map<String, dynamic> _sessionToJson(Session session) => {
        'id': session.id,
        'userId': session.userId,
        'computerId': session.computerId,
        'start': session.startTime.toIso8601String(),
        'end': session.endTime.toIso8601String(),
        'billedMinutes': session.billedDuration.inMinutes,
        'noShow': session.noShow,
      };

  Map<String, dynamic> _serviceRequestToJson(ServiceRequest request) => {
        'id': request.id,
        'userId': request.userId,
        'type': request.type.name,
        'quantity': request.quantity,
        'requestedAt': request.requestedAt.toIso8601String(),
      };

  Map<String, dynamic> _tariffToJson(TariffRule tariff) => {
        'id': tariff.id,
        'name': tariff.name,
        'pricePerHour': tariff.pricePerHour,
        'discountPercentage': tariff.discountPercentage,
        'surchargePercentage': tariff.surchargePercentage,
        'conditions': tariff.conditions
            .map((c) => {'type': c.type.name, 'params': c.params})
            .toList(),
      };

  Invoice _invoiceFromJson(Map<String, dynamic> json) {
    final lines = (json['lines'] as List<dynamic>)
        .map((line) => InvoiceLine(description: line['description'], amount: (line['amount'] as num).toDouble()))
        .toList();
    return Invoice(
      id: json['id'],
      userId: json['userId'],
      currency: Currency.values.firstWhere((c) => c.name == json['currency']),
      lines: lines,
      total: (json['total'] as num).toDouble(),
    );
  }

  DailyReport _dailyReportFromJson(Map<String, dynamic> json) {
    final breakdownRaw = json['serviceBreakdown'] as Map<String, dynamic>;
    final breakdown = {
      for (final entry in breakdownRaw.entries)
        ServiceType.values.firstWhere((t) => t.name == entry.key): (entry.value as num).toInt(),
    };
    return DailyReport(
      date: DateTime.parse(json['date'] as String),
      sessionRevenue: (json['sessionRevenue'] as num).toDouble(),
      serviceRevenue: (json['serviceRevenue'] as num).toDouble(),
      penalties: (json['penalties'] as num).toDouble(),
      activeSessions: json['activeSessions'] as int,
      completedRequests: json['completedRequests'] as int,
      serviceBreakdown: breakdown,
    );
  }
}
