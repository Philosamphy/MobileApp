/// 辅助类集合

/// 结果包装类
class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  const Result.success(this.data) : error = null, isSuccess = true;
  const Result.error(this.error) : data = null, isSuccess = false;

  bool get isError => !isSuccess;

  T get value => data!;

  Result<R> map<R>(R Function(T) transform) {
    if (isSuccess) {
      return Result.success(transform(data!));
    } else {
      return Result.error(error);
    }
  }
}

/// 分页数据类
class PaginatedData<T> {
  final List<T> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;

  const PaginatedData({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
  });

  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  int get nextPage => hasNextPage ? currentPage + 1 : currentPage;
  int get previousPage => hasPreviousPage ? currentPage - 1 : currentPage;
}

/// 缓存管理类
class CacheManager {
  static final Map<String, dynamic> _cache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};

  static void set(String key, dynamic value, {Duration? expiration}) {
    _cache[key] = value;
    _cacheTimestamps[key] = DateTime.now();

    if (expiration != null) {
      Future.delayed(expiration, () => remove(key));
    }
  }

  static T? get<T>(String key) {
    if (_cache.containsKey(key)) {
      return _cache[key] as T?;
    }
    return null;
  }

  static void remove(String key) {
    _cache.remove(key);
    _cacheTimestamps.remove(key);
  }

  static void clear() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  static bool contains(String key) {
    return _cache.containsKey(key);
  }

  static int get size => _cache.length;

  static List<String> get keys => _cache.keys.toList();
}

/// 事件总线类
class EventBus {
  static final Map<String, List<Function>> _listeners = {};

  static void on(String event, Function callback) {
    if (!_listeners.containsKey(event)) {
      _listeners[event] = [];
    }
    _listeners[event]!.add(callback);
  }

  static void off(String event, Function callback) {
    if (_listeners.containsKey(event)) {
      _listeners[event]!.remove(callback);
    }
  }

  static void emit(String event, [dynamic data]) {
    if (_listeners.containsKey(event)) {
      for (final callback in _listeners[event]!) {
        callback(data);
      }
    }
  }

  static void clear() {
    _listeners.clear();
  }
}

/// 配置管理类
class ConfigManager {
  static final Map<String, dynamic> _config = {};

  static void set(String key, dynamic value) {
    _config[key] = value;
  }

  static T? get<T>(String key, {T? defaultValue}) {
    return _config[key] as T? ?? defaultValue;
  }

  static bool has(String key) {
    return _config.containsKey(key);
  }

  static void remove(String key) {
    _config.remove(key);
  }

  static void clear() {
    _config.clear();
  }

  static Map<String, dynamic> get all => Map.unmodifiable(_config);
}
