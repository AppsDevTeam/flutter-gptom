class JsonUtils {
  const JsonUtils._();

  static String? asString(Object? v) {
    if (v == null) return null;
    if (v is String) return v;
    return v.toString();
  }

  static int? asInt(Object? v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static int asRequiredInt(Object? v, {int fallback = 0}) {
    return asInt(v) ?? fallback;
  }

  static double? asDouble(Object? v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static double asRequiredDouble(Object? v, {double fallback = 0.0}) {
    return asDouble(v) ?? fallback;
  }

  static bool? asBool(Object? v) {
    if (v == null) return null;
    if (v is bool) return v;
    if (v is String) {
      if (v.toLowerCase() == 'true') return true;
      if (v.toLowerCase() == 'false') return false;
    }
    if (v is num) {
      if (v == 1) return true;
      if (v == 0) return false;
    }
    return null;
  }

  static bool asRequiredBool(Object? v, {bool fallback = false}) {
    return asBool(v) ?? fallback;
  }

  static DateTime? asDateTime(Object? v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is num) return DateTime.fromMillisecondsSinceEpoch(v.toInt());
    return null;
  }

  static Map<String, dynamic>? asMap(Object? v) {
    if (v == null) return null;
    if (v is Map) return v.cast<String, dynamic>();
    return null;
  }

  static List<dynamic>? asList(Object? v) {
    if (v == null) return null;
    if (v is List) return v;
    return null;
  }

  static T? enumFromName<T extends Enum>(Object? v, List<T> values) {
    if (v == null) return null;
    if (v is! String) return null;

    for (final e in values) {
      if (e.name == v) return e;
    }
    return null;
  }

  static T enumFromNameRequired<T extends Enum>(Object? v, List<T> values, {required T fallback}) {
    return enumFromName<T>(v, values) ?? fallback;
  }

  static T? enumFromInt<T extends Enum>(Object? v, List<T> values, int Function(T) codeOf) {
    final code = asInt(v);
    if (code == null) return null;

    for (final e in values) {
      if (codeOf(e) == code) return e;
    }
    return null;
  }

  static T enumFromIntRequired<T extends Enum>(
    Object? v,
    List<T> values,
    int Function(T) codeOf, {
    required T fallback,
  }) {
    return enumFromInt<T>(v, values, codeOf) ?? fallback;
  }
}
