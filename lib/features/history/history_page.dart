import 'package:clearskin_ai/core/config.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _analysisService = SkinAnalysisService.instance;
  List<ScanResult> _scanHistory = [];
  bool _isLoading = true;
  final _util = APPUTILS.instance;
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final history = await _analysisService.getScanHistory();
    setState(() {
      _scanHistory = history;
      _isLoading = false;
    });
  }

  Future<void> _deleteScan(String id) async {
    await _analysisService.deleteScanResult(id);
    await _loadHistory();
    if (mounted) {
      // context.showSnackBar(
      //   message: context.locale.delScan,
      //   textStyle: context.textTheme.bodySmall!.copyWith(
      //     color: context.colorScheme.onPrimary,
      //   ),
      // );
      _util.appSnackBar(context, context.locale.delScan);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar(text: context.locale.scanHis),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: context.colorScheme.primary,
              ),
            )
          : _scanHistory.isEmpty
          ? Center(
              child: Padding(
                padding: .all(32.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 80.r,
                      color: context.colorScheme.onSurface.withValues(
                        alpha: 0.3,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      context.locale.noHist,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: .bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      context.locale.prevScan,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      textAlign: .center,
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadHistory,
              child: ListView.builder(
                padding: .all(16.r),
                itemCount: _scanHistory.length,
                itemBuilder: (context, index) {
                  final scan = _scanHistory[index];
                  return Padding(
                    padding: .only(bottom: 12.h),
                    child: ScanHistoryCard(
                      scan: scan,
                      onTap: () => context.go('/resPage', extra: scan),
                      onDelete: () => _deleteScan(scan.id),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
