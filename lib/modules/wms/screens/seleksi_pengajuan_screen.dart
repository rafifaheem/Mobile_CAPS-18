import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cargoind/modules/wms/models/penitipan_model.dart';
import 'package:cargoind/modules/wms/screens/verifikasi_fisik_screen.dart';

class SeleksiPengajuanScreen extends StatefulWidget {
  const SeleksiPengajuanScreen({super.key});

  @override
  State<SeleksiPengajuanScreen> createState() => _SeleksiPengajuanScreenState();
}

class _SeleksiPengajuanScreenState extends State<SeleksiPengajuanScreen>
    with SingleTickerProviderStateMixin {
  static const Color _red = Color(0xFFD32F2F);

  late TabController _tabController;
  late List<PenitipanBarang> _list;

  final List<String> _tabs = ['Semua', 'Menunggu', 'Diterima', 'Ditolak'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _list = List.from(mockPengajuanList);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<PenitipanBarang> get _filtered {
    final idx = _tabController.index;
    if (idx == 0) return _list;
    final statusMap = {
      1: StatusPengajuan.pending,
      2: StatusPengajuan.diterima,
      3: StatusPengajuan.ditolak,
    };
    return _list
        .where((p) => p.statusPengajuan == statusMap[idx])
        .toList();
  }

  void _onTabTap(int i) => setState(() => _tabController.index = i);

  void _showActionSheet(PenitipanBarang item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SelectionActionSheet(
        item: item,
        onTerima: () {
          Navigator.pop(context);
          setState(() => item.statusPengajuan = StatusPengajuan.diterima);
          _showSnack('Pengajuan ${item.id} diterima', Colors.green.shade700);
        },
        onTolak: (reason) {
          Navigator.pop(context);
          setState(() {
            item.statusPengajuan = StatusPengajuan.ditolak;
            item.keteranganPenolakan = reason;
          });
          _showSnack('Pengajuan ${item.id} ditolak', _red);
        },
      ),
    );
  }

  void _showResiSheet(PenitipanBarang item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ResiGudangPreviewSheet(item: item),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: AnimatedBuilder(
              animation: _tabController,
              builder: (_, __) {
                final items = _filtered;
                if (items.isEmpty) return _buildEmptyState();
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _PengajuanListCard(
                    item: items[i],
                    onTap: () => _handleCardTap(items[i]),
                    onViewResi: items[i].statusPengajuan ==
                            StatusPengajuan.terverifikasiSesuai
                        ? () => _showResiSheet(items[i])
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleCardTap(PenitipanBarang item) {
    if (item.statusPengajuan == StatusPengajuan.pending) {
      _showActionSheet(item);
    } else if (item.statusPengajuan == StatusPengajuan.diterima) {
      _showDiterimaOptions(item);
    } else if (item.statusPengajuan == StatusPengajuan.terverifikasiSesuai) {
      _showResiSheet(item);
    }
  }

  void _showDiterimaOptions(PenitipanBarang item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              item.namaBarang,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            _StatusBadge(
              label: item.statusLabel.toUpperCase(),
              color: _statusColor(item.statusPengajuan),
            ),
            const SizedBox(height: 20),
            _ActionTile(
              icon: Icons.fact_check_outlined,
              label: 'Lakukan Verifikasi Fisik',
              subtitle: 'Petugas verifikasi barang saat tiba di gudang',
              color: _red,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VerifikasiFisikScreen(pengajuan: item),
                  ),
                ).then((_) => setState(() {}));
              },
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Seleksi Pengajuan Penitipan',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.tune_outlined, color: Colors.black54),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        onTap: _onTabTap,
        labelColor: _red,
        unselectedLabelColor: Colors.grey[500],
        labelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        indicatorColor: _red,
        indicatorWeight: 3,
        tabs: _tabs.map((t) {
          int count = 0;
          if (t == 'Menunggu') {
            count = _list
                .where((p) => p.statusPengajuan == StatusPengajuan.pending)
                .length;
          }
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(t),
                if (count > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: _red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 56, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'Tidak ada pengajuan',
            style: TextStyle(
                fontSize: 16, color: Colors.grey[500], fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Belum ada pengajuan masuk untuk kategori ini',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}

// ─── Pengajuan List Card ──────────────────────────────────────────────────────

class _PengajuanListCard extends StatelessWidget {
  final PenitipanBarang item;
  final VoidCallback onTap;
  final VoidCallback? onViewResi;

  const _PengajuanListCard({
    required this.item,
    required this.onTap,
    this.onViewResi,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy', 'id');
    final color = _statusColor(item.statusPengajuan);

    return GestureDetector(
      onTap: item.statusPengajuan == StatusPengajuan.ditolak
          ? () => _showRejectionDetail(context)
          : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _statusIcon(item.statusPengajuan),
                      color: color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.namaBarang,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _StatusBadge(
                              label: item.statusLabel.toUpperCase(),
                              color: color,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.namaCustomer,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Row(
                children: [
                  _MetaChip(
                    icon: Icons.numbers,
                    label: '${item.jumlahEkspektasi} unit',
                  ),
                  const SizedBox(width: 8),
                  _MetaChip(
                    icon: Icons.category_outlined,
                    label: item.jenisBarang,
                  ),
                  const Spacer(),
                  Text(
                    fmt.format(item.tanggalPengajuan),
                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            if (item.statusPengajuan == StatusPengajuan.ditolak &&
                item.keteranganPenolakan != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDECEC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline,
                        size: 14, color: Color(0xFFD32F2F)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.keteranganPenolakan!,
                        style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFD32F2F),
                            height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[100]!, width: 1),
                ),
              ),
              child: _buildCardFooter(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFooter(BuildContext context) {
    if (item.statusPengajuan == StatusPengajuan.pending) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: _FooterButton(
                label: 'TOLAK',
                color: const Color(0xFFD32F2F),
                isOutlined: true,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FooterButton(
                label: 'TERIMA',
                color: Colors.green.shade700,
                onTap: onTap,
              ),
            ),
          ],
        ),
      );
    }

    if (item.statusPengajuan == StatusPengajuan.diterima) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: _FooterButton(
          label: 'VERIFIKASI FISIK →',
          color: const Color(0xFFD32F2F),
          onTap: onTap,
        ),
      );
    }

    if (item.statusPengajuan == StatusPengajuan.terverifikasiSesuai) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: _FooterButton(
          label: 'LIHAT RESI GUDANG',
          color: Colors.green.shade700,
          onTap: onViewResi ?? () {},
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
          const SizedBox(width: 4),
          Text(
            'Pengajuan ${item.statusLabel.toLowerCase()}',
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  void _showRejectionDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.cancel_outlined,
                    color: Color(0xFFD32F2F), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'ALASAN PENOLAKAN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFD32F2F),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.namaBarang,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFDECEC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFFEF9A9A), width: 1),
              ),
              child: Text(
                item.keteranganPenolakan ?? '-',
                style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFD32F2F),
                    height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Selection Action Sheet ───────────────────────────────────────────────────

class _SelectionActionSheet extends StatefulWidget {
  final PenitipanBarang item;
  final VoidCallback onTerima;
  final ValueChanged<String> onTolak;

  const _SelectionActionSheet({
    required this.item,
    required this.onTerima,
    required this.onTolak,
  });

  @override
  State<_SelectionActionSheet> createState() => _SelectionActionSheetState();
}

class _SelectionActionSheetState extends State<_SelectionActionSheet> {
  static const Color _red = Color(0xFFD32F2F);
  bool _showTolakForm = false;
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 28),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 3,
                  height: 18,
                  decoration: BoxDecoration(
                    color: _red,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'TINDAKAN PENGAJUAN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFD32F2F),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.namaBarang,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.item.namaCustomer,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _MetaChip(
                          icon: Icons.numbers,
                          label: '${widget.item.jumlahEkspektasi} unit'),
                      const SizedBox(width: 8),
                      _MetaChip(
                          icon: Icons.category_outlined,
                          label: widget.item.jenisBarang),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (!_showTolakForm) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text(
                    'TERIMA PENGAJUAN',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800,
                        letterSpacing: 0.5),
                  ),
                  onPressed: widget.onTerima,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text(
                    'TOLAK PENGAJUAN',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800,
                        letterSpacing: 0.5),
                  ),
                  onPressed: () => setState(() => _showTolakForm = true),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _red,
                    side: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ] else ...[
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alasan Penolakan',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _reasonController,
                      maxLines: 3,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText:
                            'Jelaskan alasan penolakan pengajuan ini...',
                        hintStyle: TextStyle(
                            fontSize: 13, color: Colors.grey[400]),
                        filled: true,
                        fillColor: const Color(0xFFFDECEC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFFD32F2F), width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFFEF9A9A), width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFFD32F2F), width: 2),
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Alasan penolakan wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                setState(() => _showTolakForm = false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey[700],
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                widget.onTolak(_reasonController.text.trim());
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _red,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'KONFIRMASI TOLAK',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Resi Gudang Preview Sheet ────────────────────────────────────────────────

class _ResiGudangPreviewSheet extends StatelessWidget {
  final PenitipanBarang item;

  const _ResiGudangPreviewSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy', 'id');
    final currFmt =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildSheetHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                children: [
                  _buildResiHeader(),
                  const SizedBox(height: 12),
                  _buildBarangDetails(fmt),
                  const SizedBox(height: 12),
                  _buildBiayaBreakdown(currFmt),
                  const SizedBox(height: 12),
                  _buildDigitalSignature(),
                  const SizedBox(height: 20),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSheetHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5E20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.verified, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'DOKUMEN RESMI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 20, color: Colors.black54),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'BUKTI KEPEMILIKAN BARANG',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.grey[500],
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResiHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RESI GUDANG',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.grey[500],
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.nomorResi ?? 'RG-2024-${item.id.split('-').last}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.green.shade800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Nomor Registrasi Barang Penitipan',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _ResiMetaItem(
                label: 'TANGGAL TERBIT',
                value: DateFormat('dd MMM yyyy', 'id').format(DateTime.now()),
              ),
              const SizedBox(width: 20),
              _ResiMetaItem(
                label: 'BERLAKU HINGGA',
                value: DateFormat('dd MMM yyyy', 'id')
                    .format(item.periodeAkhir),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarangDetails(DateFormat fmt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'IDENTITAS BARANG',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.green.shade700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ResiRow(label: 'Nama Barang', value: item.namaBarang),
          const Divider(height: 16),
          _ResiRow(label: 'Jenis', value: item.jenisBarang),
          const Divider(height: 16),
          _ResiRow(label: 'Klasifikasi', value: item.klasifikasi),
          const Divider(height: 16),
          _ResiRow(
            label: 'Jumlah',
            value: '${item.jumlahAktual ?? item.jumlahEkspektasi} unit',
            valueStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const Divider(height: 16),
          _ResiRow(label: 'Customer', value: item.namaCustomer),
          const Divider(height: 16),
          _ResiRow(
            label: 'Periode',
            value:
                '${fmt.format(item.periodeAwal)} s/d ${fmt.format(item.periodeAkhir)}',
          ),
          const Divider(height: 16),
          _ResiRow(label: 'Durasi', value: '${item.totalHari} hari'),
        ],
      ),
    );
  }

  Widget _buildBiayaBreakdown(NumberFormat currFmt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'RINCIAN BIAYA PENITIPAN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFD32F2F),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _BiayaRow(
            label: 'Biaya Penitipan',
            sublabel: '${currFmt.format(item.tarifPerHari)}/hari × ${item.totalHari} hari',
            value: currFmt.format(item.biayaPenitipan),
          ),
          const Divider(height: 16),
          _BiayaRow(
            label: 'Biaya Handling',
            value: currFmt.format(item.biayaHandling),
          ),
          const Divider(height: 16),
          _BiayaRow(
            label: 'Biaya Administrasi',
            value: currFmt.format(item.biayaAdministrasi),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1B5E20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL BIAYA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  currFmt.format(item.totalBiaya),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDigitalSignature() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'TANDA TANGAN DIGITAL',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Petugas Gudang',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.namaPetugas ?? 'Petugas Gudang',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Container(
                height: 60,
                width: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.draw_outlined,
                        size: 22, color: Colors.grey[400]),
                    const SizedBox(height: 4),
                    Text(
                      'Tanda Tangan',
                      style: TextStyle(
                          fontSize: 10, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.verified_user_outlined,
                    color: Colors.green.shade700, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Data disimpan secara digital & terenkripsi',
                  style: TextStyle(
                      fontSize: 11, color: Colors.green.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.download_outlined, size: 18),
            label: const Text(
              'UNDUH RESI GUDANG',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5),
            ),
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.dashboard_outlined, size: 18),
            label: const Text(
              'KEMBALI KE DASHBOARD',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3),
            ),
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
                fontSize: 11, color: Colors.grey[700], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _FooterButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isOutlined;
  final VoidCallback onTap;

  const _FooterButton({
    required this.label,
    required this.color,
    this.isOutlined = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return SizedBox(
        height: 36,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color, width: 1.5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ),
      );
    }
    return SizedBox(
      height: 36,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700, color: color),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}

class _ResiMetaItem extends StatelessWidget {
  final String label;
  final String value;

  const _ResiMetaItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey[500]),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87),
        ),
      ],
    );
  }
}

class _ResiRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _ResiRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: valueStyle ??
                const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
          ),
        ),
      ],
    );
  }
}

class _BiayaRow extends StatelessWidget {
  final String label;
  final String? sublabel;
  final String value;

  const _BiayaRow({
    required this.label,
    this.sublabel,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              if (sublabel != null)
                Text(
                  sublabel!,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
            ],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black87),
        ),
      ],
    );
  }
}

Color _statusColor(StatusPengajuan status) {
  switch (status) {
    case StatusPengajuan.pending:
      return const Color(0xFFE65100);
    case StatusPengajuan.diterima:
      return const Color(0xFF1565C0);
    case StatusPengajuan.ditolak:
      return const Color(0xFFD32F2F);
    case StatusPengajuan.terverifikasiSesuai:
      return const Color(0xFF2E7D32);
    case StatusPengajuan.terverifikasiTidakSesuai:
      return const Color(0xFFD32F2F);
  }
}

IconData _statusIcon(StatusPengajuan status) {
  switch (status) {
    case StatusPengajuan.pending:
      return Icons.hourglass_top_outlined;
    case StatusPengajuan.diterima:
      return Icons.thumb_up_outlined;
    case StatusPengajuan.ditolak:
      return Icons.thumb_down_outlined;
    case StatusPengajuan.terverifikasiSesuai:
      return Icons.verified_outlined;
    case StatusPengajuan.terverifikasiTidakSesuai:
      return Icons.report_problem_outlined;
  }
}
