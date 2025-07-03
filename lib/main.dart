import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/system_service.dart';
import 'services/config_service.dart';
import 'screens/system_dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/logs_screen.dart';
import 'models/system_info.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  runApp(const SystemManagementApp());
}

class SystemManagementApp extends StatelessWidget {
  const SystemManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SystemService()),
        ChangeNotifierProvider(create: (_) => ConfigService()),
      ],
      child: MaterialApp(
        title: '系统管理系统',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
          useMaterial3: true,
        ),
        home: const SystemDashboardScreen(),
      ),
    );
  }
}

class SystemDashboardScreen extends StatefulWidget {
  const SystemDashboardScreen({super.key});

  @override
  State<SystemDashboardScreen> createState() => _SystemDashboardScreenState();
}

class _SystemDashboardScreenState extends State<SystemDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SystemService>().fetchSystemInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('系统管理'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: '系统概览'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '系统设置'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: '系统日志'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const SystemOverviewScreen();
      case 1:
        return const SettingsScreen();
      case 2:
        return const LogsScreen();
      default:
        return const SystemOverviewScreen();
    }
  }
}

class SystemOverviewScreen extends StatelessWidget {
  const SystemOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SystemService>(
      builder: (context, systemService, child) {
        if (systemService.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final systemInfo = systemService.systemInfo;
        if (systemInfo == null) {
          return const Center(child: Text('无法获取系统信息'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 系统状态卡片
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.computer,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '系统状态',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildStatusRow('系统版本', systemInfo.version),
                      _buildStatusRow('运行时间', systemInfo.uptime),
                      _buildStatusRow('CPU使用率', '${systemInfo.cpuUsage}%'),
                      _buildStatusRow('内存使用率', '${systemInfo.memoryUsage}%'),
                      _buildStatusRow('磁盘使用率', '${systemInfo.diskUsage}%'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 性能指标卡片
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.speed,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '性能指标',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildProgressIndicator('CPU', systemInfo.cpuUsage / 100),
                      const SizedBox(height: 8),
                      _buildProgressIndicator(
                        '内存',
                        systemInfo.memoryUsage / 100,
                      ),
                      const SizedBox(height: 8),
                      _buildProgressIndicator('磁盘', systemInfo.diskUsage / 100),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 系统信息卡片
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '系统信息',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('操作系统', systemInfo.os),
                      _buildInfoRow('架构', systemInfo.architecture),
                      _buildInfoRow('主机名', systemInfo.hostname),
                      _buildInfoRow('IP地址', systemInfo.ipAddress),
                      _buildInfoRow('最后更新', systemInfo.lastUpdate),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label), Text('${(value * 100).toInt()}%')],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            value > 0.8 ? Colors.red : Colors.green,
          ),
        ),
      ],
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfigService>(
      builder: (context, configService, child) {
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('通知设置'),
                    subtitle: const Text('管理系统通知'),
                    trailing: Switch(
                      value: configService.notificationsEnabled,
                      onChanged: (value) {
                        configService.updateNotificationSettings(value);
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text('安全设置'),
                    subtitle: const Text('系统安全配置'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: 实现安全设置页面
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.backup),
                    title: const Text('备份设置'),
                    subtitle: const Text('数据备份配置'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: 实现备份设置页面
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.update),
                    title: const Text('系统更新'),
                    subtitle: const Text('检查系统更新'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: 实现系统更新检查
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.restore),
                    title: const Text('系统恢复'),
                    subtitle: const Text('恢复系统设置'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: 实现系统恢复功能
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SystemService>(
      builder: (context, systemService, child) {
        if (systemService.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final logs = systemService.systemLogs;

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                leading: Icon(
                  _getLogIcon(log.level),
                  color: _getLogColor(log.level),
                ),
                title: Text(log.message),
                subtitle: Text(log.timestamp),
                trailing: Text(
                  log.level.toUpperCase(),
                  style: TextStyle(
                    color: _getLogColor(log.level),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getLogIcon(String level) {
    switch (level.toLowerCase()) {
      case 'error':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      case 'info':
        return Icons.info;
      default:
        return Icons.debug;
    }
  }

  Color _getLogColor(String level) {
    switch (level.toLowerCase()) {
      case 'error':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'info':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
