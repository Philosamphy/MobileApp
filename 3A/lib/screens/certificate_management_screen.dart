import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/certificate_service.dart';
import '../models/certificate_model.dart';
import '../widgets/common_widgets.dart';
import '../utils/constants.dart';

/// 证书管理界面
class CertificateManagementScreen extends StatefulWidget {
  const CertificateManagementScreen({super.key});

  @override
  State<CertificateManagementScreen> createState() =>
      _CertificateManagementScreenState();
}

class _CertificateManagementScreenState
    extends State<CertificateManagementScreen> {
  String _selectedFilter = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CertificateService>().fetchCertificates();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('证书管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCertificateDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: Consumer<CertificateService>(
              builder: (context, certificateService, child) {
                if (certificateService.isLoading) {
                  return const LoadingWidget(message: '加载证书中...');
                }

                if (certificateService.error != null) {
                  return CustomErrorWidget(
                    message: certificateService.error!,
                    onRetry: () => certificateService.fetchCertificates(),
                  );
                }

                final filteredCertificates = _getFilteredCertificates(
                  certificateService,
                );

                if (filteredCertificates.isEmpty) {
                  return const Center(child: Text('暂无证书数据'));
                }

                return ListView.builder(
                  itemCount: filteredCertificates.length,
                  itemBuilder: (context, index) {
                    final certificate = filteredCertificates[index];
                    return _buildCertificateCard(
                      certificate,
                      certificateService,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 搜索框
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '搜索证书...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),
          // 筛选器
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', '全部'),
                _buildFilterChip(AppConstants.statusActive, '有效'),
                _buildFilterChip(AppConstants.statusExpired, '已过期'),
                _buildFilterChip(AppConstants.statusRevoked, '已吊销'),
                _buildFilterChip(AppConstants.statusPending, '待审核'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: _selectedFilter == value,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = value;
          });
        },
      ),
    );
  }

  Widget _buildCertificateCard(
    Certificate certificate,
    CertificateService service,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(certificate.statusColor),
          child: Icon(
            _getCertificateIcon(certificate.type),
            color: Colors.white,
          ),
        ),
        title: Text(
          certificate.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('类型: ${certificate.typeDisplayName}'),
            Text('状态: ${certificate.statusDisplayName}'),
            Text('过期时间: ${_formatDate(certificate.expiryDate)}'),
            if (certificate.isExpiringSoon)
              Text(
                '即将过期 (${certificate.daysUntilExpiry}天)',
                style: const TextStyle(color: Colors.orange),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) =>
              _handleCertificateAction(value, certificate, service),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('查看详情'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [Icon(Icons.edit), SizedBox(width: 8), Text('编辑')],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [Icon(Icons.delete), SizedBox(width: 8), Text('删除')],
              ),
            ),
          ],
        ),
        onTap: () => _showCertificateDetails(certificate),
      ),
    );
  }

  IconData _getCertificateIcon(String type) {
    switch (type) {
      case AppConstants.certTypeSSL:
        return Icons.lock;
      case AppConstants.certTypeCodeSigning:
        return Icons.code;
      case AppConstants.certTypeEmail:
        return Icons.email;
      case AppConstants.certTypeClient:
        return Icons.person;
      default:
        return Icons.security;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  List<Certificate> _getFilteredCertificates(CertificateService service) {
    List<Certificate> certificates = service.certificates;

    // 应用搜索过滤
    if (_searchQuery.isNotEmpty) {
      certificates = service.searchCertificates(_searchQuery);
    }

    // 应用状态过滤
    if (_selectedFilter != 'all') {
      certificates = certificates
          .where((cert) => cert.status == _selectedFilter)
          .toList();
    }

    return certificates;
  }

  void _handleCertificateAction(
    String action,
    Certificate certificate,
    CertificateService service,
  ) {
    switch (action) {
      case 'view':
        _showCertificateDetails(certificate);
        break;
      case 'edit':
        _showEditCertificateDialog(certificate);
        break;
      case 'delete':
        _showDeleteConfirmation(certificate, service);
        break;
    }
  }

  void _showCertificateDetails(Certificate certificate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(certificate.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('证书名称', certificate.name),
              _buildDetailRow('证书类型', certificate.typeDisplayName),
              _buildDetailRow('状态', certificate.statusDisplayName),
              _buildDetailRow('颁发者', certificate.issuer),
              _buildDetailRow('主题', certificate.subject),
              _buildDetailRow('序列号', certificate.serialNumber),
              _buildDetailRow('颁发日期', _formatDate(certificate.issuedDate)),
              _buildDetailRow('过期日期', _formatDate(certificate.expiryDate)),
              if (certificate.description != null)
                _buildDetailRow('描述', certificate.description!),
              if (certificate.ownerName != null)
                _buildDetailRow('所有者', certificate.ownerName!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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

  void _showAddCertificateDialog() {
    // TODO: 实现添加证书对话框
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('添加证书功能待实现')));
  }

  void _showEditCertificateDialog(Certificate certificate) {
    // TODO: 实现编辑证书对话框
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('编辑证书功能待实现')));
  }

  void _showDeleteConfirmation(
    Certificate certificate,
    CertificateService service,
  ) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: '删除证书',
        content: '确定要删除证书 "${certificate.name}" 吗？此操作不可撤销。',
        confirmText: '删除',
        cancelText: '取消',
      ),
    ).then((confirmed) async {
      if (confirmed == true) {
        final success = await service.deleteCertificate(certificate.id);
        if (success && mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('证书删除成功')));
        }
      }
    });
  }
}
