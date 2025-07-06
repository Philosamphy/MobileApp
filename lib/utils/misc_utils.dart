/// 杂项工具函数

/// 颜色工具类
class ColorUtils {
  /// 将十六进制颜色字符串转换为Color对象
  static int hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return int.parse(buffer.toString(), radix: 16);
  }

  /// 将Color对象转换为十六进制字符串
  static String colorToHex(int color) {
    return '#${color.toRadixString(16).padLeft(8, '0')}';
  }

  /// 获取颜色的亮度
  static double getBrightness(int color) {
    final r = (color >> 16) & 0xFF;
    final g = (color >> 8) & 0xFF;
    final b = color & 0xFF;
    return (r * 299 + g * 587 + b * 114) / 1000;
  }

  /// 判断颜色是否为深色
  static bool isDarkColor(int color) {
    return getBrightness(color) < 128;
  }
}

/// 字符串工具类
class StringUtils {
  /// 检查字符串是否为数字
  static bool isNumeric(String str) {
    return double.tryParse(str) != null;
  }

  /// 检查字符串是否为整数
  static bool isInteger(String str) {
    return int.tryParse(str) != null;
  }

  /// 反转字符串
  static String reverse(String str) {
    return String.fromCharCodes(str.codeUnits.reversed);
  }

  /// 计算字符串中的字符出现次数
  static int countOccurrences(String str, String char) {
    return str.split(char).length - 1;
  }

  /// 移除字符串中的重复字符
  static String removeDuplicates(String str) {
    final seen = <String>{};
    return str.split('').where((char) => seen.add(char)).join();
  }
}

/// 数字工具类
class NumberUtils {
  /// 格式化数字为千分位格式
  static String formatWithCommas(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// 将数字转换为中文数字
  static String toChineseNumber(int number) {
    if (number == 0) return '零';

    const units = ['', '十', '百', '千', '万', '十', '百', '千', '亿'];
    const digits = ['零', '一', '二', '三', '四', '五', '六', '七', '八', '九'];

    if (number < 10) return digits[number];
    if (number < 20) return '十${number > 10 ? digits[number - 10] : ''}';

    final str = number.toString();
    final result = StringBuffer();

    for (int i = 0; i < str.length; i++) {
      final digit = int.parse(str[i]);
      if (digit != 0) {
        result.write(digits[digit]);
        result.write(units[str.length - 1 - i]);
      } else if (i < str.length - 1 && int.parse(str[i + 1]) != 0) {
        result.write('零');
      }
    }

    return result.toString();
  }

  /// 检查数字是否为质数
  static bool isPrime(int number) {
    if (number < 2) return false;
    if (number == 2) return true;
    if (number % 2 == 0) return false;

    for (int i = 3; i * i <= number; i += 2) {
      if (number % i == 0) return false;
    }
    return true;
  }

  /// 获取数字的所有因子
  static List<int> getFactors(int number) {
    final factors = <int>[];
    for (int i = 1; i <= number; i++) {
      if (number % i == 0) {
        factors.add(i);
      }
    }
    return factors;
  }
}

/// 时间工具类
class TimeUtils {
  /// 获取相对时间描述
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  /// 检查是否为同一天
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// 获取月份的天数
  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// 检查是否为闰年
  static bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }
}

/// 文件工具类
class FileUtils {
  /// 获取文件扩展名
  static String getExtension(String fileName) {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last : '';
  }

  /// 获取不带扩展名的文件名
  static String getFileNameWithoutExtension(String fileName) {
    final parts = fileName.split('.');
    return parts.first;
  }

  /// 检查文件是否为图片
  static bool isImage(String fileName) {
    final ext = getExtension(fileName).toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
  }

  /// 检查文件是否为视频
  static bool isVideo(String fileName) {
    final ext = getExtension(fileName).toLowerCase();
    return ['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm'].contains(ext);
  }

  /// 检查文件是否为音频
  static bool isAudio(String fileName) {
    final ext = getExtension(fileName).toLowerCase();
    return ['mp3', 'wav', 'flac', 'aac', 'ogg'].contains(ext);
  }
}
