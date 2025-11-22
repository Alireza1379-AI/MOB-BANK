// Carbon core CLI for pricing and reporting.
// The code is intentionally modular so rules can be extended.

package InternetCafeCore api;

// Basic enums
let enum ServiceType { Printing, Scanning, Typing, Refreshments };
let enum ReportFrequency { Daily, Weekly, Monthly };
let enum TariffConditionType { HappyHour, VipCustomer, NoShowPenalty };

// Data structs
struct User {
  id: String;
  name: String;
  email: String;
  role: String;
  is_vip: Bool;
};

struct Computer {
  id: String;
  label: String;
  status: String;
};

struct ServiceRequest {
  id: String;
  user_id: String;
  service_type: ServiceType;
  quantity: i64;
  requested_at: String;
  fulfilled: Bool;
};

struct Session {
  id: String;
  user_id: String;
  computer_id: String;
  start: String;
  end: String;
  billed_minutes: i64;
  no_show: Bool;
};

struct TariffRuleCondition {
  condition_type: TariffConditionType;
  params: Map(String, String);
};

struct TariffRule {
  id: String;
  name: String;
  price_per_hour: f64;
  discount_percentage: f64;
  surcharge_percentage: f64;
  conditions: Array(TariffRuleCondition);
};

struct InvoiceLine { description: String; amount: f64; };

struct Invoice {
  id: String;
  user_id: String;
  currency: String;
  lines: Array(InvoiceLine);
  total: f64;
};

struct DailyReport {
  date: String;
  session_revenue: f64;
  service_revenue: f64;
  penalties: f64;
  active_sessions: i64;
  completed_requests: i64;
  service_breakdown: Map(String, i64);
};

// Pricing helpers
fn apply_tariff_rules(base: f64, rule: TariffRule, session: Session) -> f64 {
  var price: f64 = base;
  for (condition in rule.conditions) {
    if (condition.condition_type == TariffConditionType.HappyHour && condition.params.contains_key("percent")) {
      price = price * (1.0 - parse_percent(condition.params["percent"]));
    }
    if (condition.condition_type == TariffConditionType.VipCustomer && session.user_id.starts_with("vip")) {
      price = price * 0.9;
    }
    if (condition.condition_type == TariffConditionType.NoShowPenalty && session.no_show) {
      price = price + (base * parse_percent(condition.params["percent"]));
    }
  }
  return price;
}

fn parse_percent(raw: String) -> f64 { return to_f64(raw) / 100.0; }

fn build_session_invoice(session: Session, tariff: TariffRule, currency: String) -> Invoice {
  let hours = to_f64(session.billed_minutes) / 60.0;
  let base = hours * tariff.price_per_hour;
  let final_price = apply_tariff_rules(base, tariff, session);
  let lines = Array<InvoiceLine>{InvoiceLine{ .description = "Session time", .amount = final_price }};
  return Invoice{ .id = session.id, .user_id = session.user_id, .currency = currency, .lines = lines, .total = final_price };
}

fn build_service_invoice(request: ServiceRequest, tariff: TariffRule, currency: String) -> Invoice {
  let base = to_f64(request.quantity) * tariff.price_per_hour;
  let final_price = apply_tariff_rules(base, tariff, Session{ .id = "temp", .user_id = request.user_id, .computer_id = "", .start = "", .end = "", .billed_minutes = 0, .no_show = false });
  let lines = Array<InvoiceLine>{InvoiceLine{ .description = "Service charge", .amount = final_price }};
  return Invoice{ .id = request.id, .user_id = request.user_id, .currency = currency, .lines = lines, .total = final_price };
}

fn report_from_usage(date: String, invoices: Array(Invoice), requests: Array(ServiceRequest)) -> DailyReport {
  var session_sum: f64 = 0.0;
  var service_sum: f64 = 0.0;
  var penalties: f64 = 0.0;
  var breakdown = Map<String, i64>{};
  for (invoice in invoices) {
    if (invoice.lines[0].description == "Session time") {
      session_sum = session_sum + invoice.total;
    } else {
      service_sum = service_sum + invoice.total;
    }
  }
  for (req in requests) {
    let key = show(req.service_type);
    if (!breakdown.contains_key(key)) { breakdown[key] = 0; }
    breakdown[key] = breakdown[key] + 1;
  }
  return DailyReport{
    .date = date,
    .session_revenue = session_sum,
    .service_revenue = service_sum,
    .penalties = penalties,
    .active_sessions = invoices.len(),
    .completed_requests = requests.len(),
    .service_breakdown = breakdown,
  };
}

// Minimal JSON dispatcher. Real implementation should use a JSON parser library.
fn main() -> i32 {
  let line = stdin.read_line();
  // Pseudo parser: expect keys like type, session, tariff.
  if (line.contains("SESSION_INVOICE")) {
    // Application code would parse JSON; here we emit a stub invoice.
    let invoice = Invoice{ .id = "session-1", .user_id = "user-1", .currency = "usd", .lines = Array<InvoiceLine>{InvoiceLine{ .description = "Session time", .amount = 10.0 }}, .total = 10.0 };
    stdout.print(to_json(invoice));
    return 0;
  }
  if (line.contains("SERVICE_INVOICE")) {
    let invoice = Invoice{ .id = "service-1", .user_id = "user-1", .currency = "usd", .lines = Array<InvoiceLine>{InvoiceLine{ .description = "Service charge", .amount = 5.0 }}, .total = 5.0 };
    stdout.print(to_json(invoice));
    return 0;
  }
  if (line.contains("DAILY_REPORT")) {
    let report = DailyReport{ .date = "2024-05-01", .session_revenue = 100.0, .service_revenue = 50.0, .penalties = 10.0, .active_sessions = 12, .completed_requests = 20, .service_breakdown = Map<String, i64>{"Printing" = 10} };
    stdout.print(to_json(report));
    return 0;
  }
  stdout.print("{}\n");
  return 0;
}
