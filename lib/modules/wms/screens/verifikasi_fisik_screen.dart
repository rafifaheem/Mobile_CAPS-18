import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cargoind/modules/wms/models/penitipan_model.dart';

class VerifikasiFisikScreen extends StatefulWidget {
  final PenitipanBarang? pengajuan;

  const VerifikasiFisikScreen({super.key, this.pengajuan});

  @override
  State<VerifikasiFisikScreen> createState() => _VerifikasiFisikScreenState();
}

class _VerifikasiFisikScreenState extends State<VerifikasiFisikScreen> {
  static const Color _red = Color(0xFFD32F2F);
  static const Color _green = Color(0xFF2E7D32);
  static const Color _bgSection = Color(0xFFF8F9FA);

  final _formKey = GlobalKey<FormState>();
  final _jumlahController = TextEditingController();
  final _keteranganController = TextEditingController();
  final _catatanController = TextEditingController();

  String _kondisi = 'sesuai';
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  late PenitipanBarang _pengajuan;

  @override
  void initState() {
    super.initState();
    _pengajuan = widget.pengajuan ??
        mockPengajuanList.firstWhere(
          (p) => p.statusPengajuan == StatusPengajuan.diterima,
          orElse: () => mockPengajuanList.first,
        );
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _keteranganController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  void _submitVerifikasi() async {
    if (!_formKey.currentState!.validate()) return;

    final jumlahAktual = int.tryParse(_jumlahController.text.trim());
    if (jumlahAktual == null) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _isSubmitting = false;
      _isSubmitted = true;
      _pengajuan.jumlahAktual = jumlahAktual;
      _pengajuan.kondisiVerifikasi = _kondisi;
      _pengajuan.keteranganVerifikasi = _keteranganController.text.trim();
      _pengajuan.namaPetugas = 'Petugas Gudang';
      _pengajuan.statusPengajuan = _kondisi == 'sesuai'
          ? StatusPengajuan.terverifikasiSesuai
          : StatusPengajuan.terverifikasiTidakSesuai;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgSection,
      appBar: _buildAppBar(),
      body: _isSubmitted ? _buildSuccessView() : _buildFormView(),
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
        'Verifikasi Fisik Barang',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.black54),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildFormView() {
    return Column(
      children: [
        _StepProgressBar(
          step: 2,
          totalSteps: 2,
          percent: 100,
          label: 'Verifikasi Fisik',
          color: _red,
        ),
        Expanded(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailSection(),
                  const SizedBox(height: 12),
                  _buildVerifikasiSection(),
                  if (_kondisi != 'sesuai') ...[
                    const SizedBox(height: 12),
                    _buildKeteranganSection(),
                  ],
                  const SizedBox(height: 12),
                  _buildBuktiFotoSection(),
                  const SizedBox(height: 12),
                  _buildCatatanSection(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
        _buildBottomButton(),
      ],
    );
  }

  Widget _buildDetailSection() {
    final fmt = DateFormat('dd MMM yyyy', 'id');
    return _CardSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'DETAIL PENGAJUAN', icon: Icons.inventory_2_outlined),
          const SizedBox(height: 16),
          _DetailInfoRow(
            icon: Icons.label_outline,
            label: 'ID Pengajuan',
            value: _pengajuan.id,
            valueStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFFD32F2F),
              letterSpacing: 0.5,
            ),
          ),
          const _Divider(),
          _DetailInfoRow(
            icon: Icons.inventory_outlined,
            label: 'Nama Barang',
            value: _pengajuan.namaBarang,
          ),
          const _Divider(),
          _DetailInfoRow(
            icon: Icons.numbers,
            label: 'Jumlah Ekspektasi',
            value: '${_pengajuan.jumlahEkspektasi} unit',
            valueWidget: Row(
              children: [
                Text(
                  '${_pengajuan.jumlahEkspektasi} unit',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(label: 'TARGET', color: const Color(0xFF1565C0)),
              ],
            ),
          ),
          const _Divider(),
          _DetailInfoRow(
            icon: Icons.category_outlined,
            label: 'Jenis Barang',
            value: _pengajuan.jenisBarang,
          ),
          const _Divider(),
          _DetailInfoRow(
            icon: Icons.shield_outlined,
            label: 'Klasifikasi',
            value: _pengajuan.klasifikasi,
          ),
          const _Divider(),
          _DetailInfoRow(
            icon: Icons.business_outlined,
            label: 'Customer',
            value: _pengajuan.namaCustomer,
          ),
          const _Divider(),
          _DetailInfoRow(
            icon: Icons.date_range_outlined,
            label: 'Periode Penitipan',
            value:
                '${fmt.format(_pengajuan.periodeAwal)} — ${fmt.format(_pengajuan.periodeAkhir)}',
          ),
        ],
      ),
    );
  }

  Widget _buildVerifikasiSection() {
    return _CardSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
              title: 'HASIL VERIFIKASI', icon: Icons.fact_check_outlined),
          const SizedBox(height: 16),
          Text(
            'Jumlah Aktual (unit)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _jumlahController,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'Masukkan jumlah aktual',
              hintStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.grey[400],
              ),
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFFD32F2F), width: 2),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixText: 'unit',
              suffixStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Jumlah aktual wajib diisi';
              }
              if (int.tryParse(v.trim()) == null) {
                return 'Masukkan angka yang valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Kondisi Barang',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          _ConditionRadioGroup(
            value: _kondisi,
            onChanged: (val) => setState(() => _kondisi = val),
          ),
        ],
      ),
    );
  }

  Widget _buildKeteranganSection() {
    return _CardSection(
      borderColor: const Color(0xFFD32F2F),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFD32F2F), size: 18),
              const SizedBox(width: 8),
              Text(
                'ALASAN KETIDAKSESUAIAN',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFD32F2F),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _keteranganController,
            maxLines: 3,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            decoration: InputDecoration(
              hintText:
                  'Jelaskan ketidaksesuaian barang (jumlah, kondisi, jenis, dll.)...',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
              filled: true,
              fillColor: const Color(0xFFFDECEC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFFD32F2F), width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFFEF9A9A), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFFD32F2F), width: 2),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
            validator: (v) {
              if (_kondisi != 'sesuai' && (v == null || v.trim().isEmpty)) {
                return 'Keterangan wajib diisi jika barang tidak sesuai';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBuktiFotoSection() {
    return _CardSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
              title: 'BUKTI FOTO', icon: Icons.photo_camera_outlined),
          const SizedBox(height: 4),
          Text(
            '* Foto bukti wajib dilampirkan. Pastikan semua label terlihat jelas.',
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _PhotoUploadSlot(
                  label: 'TAMPAK DEPAN',
                  icon: Icons.front_hand_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PhotoUploadSlot(
                  label: 'TAMPAK SAMPING',
                  icon: Icons.view_sidebar_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PhotoUploadSlot(
                  label: 'LABEL / KODE BARANG',
                  icon: Icons.qr_code_scanner_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PhotoUploadSlot(
                  label: 'KONDISI KEMASAN',
                  icon: Icons.inventory_2_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCatatanSection() {
    return _CardSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
              title: 'CATATAN PETUGAS', icon: Icons.edit_note_outlined),
          const SizedBox(height: 12),
          TextFormField(
            controller: _catatanController,
            maxLines: 3,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'Tambahkan catatan tambahan jika diperlukan...',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFFD32F2F), width: 2),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submitVerifikasi,
          style: ElevatedButton.styleFrom(
            backgroundColor: _red,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'KONFIRMASI VERIFIKASI',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    final isSesuai = _kondisi == 'sesuai';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isSesuai ? const Color(0xFFE8F5E9) : const Color(0xFFFDECEC),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSesuai ? Icons.check_circle : Icons.warning_amber_rounded,
              color: isSesuai ? _green : _red,
              size: 48,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isSesuai ? 'Verifikasi Selesai' : 'Ketidaksesuaian Tercatat',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isSesuai ? _green : _red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSesuai
                ? 'Barang telah dinyatakan sesuai dan dicatat dalam sistem.'
                : 'Ketidaksesuaian telah dicatat. Notifikasi akan dikirim ke customer.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 28),
          _CardSection(
            borderColor: isSesuai ? const Color(0xFF4CAF50) : _red,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  title: 'RINGKASAN VERIFIKASI',
                  icon: Icons.summarize_outlined,
                  color: isSesuai ? _green : _red,
                ),
                const SizedBox(height: 14),
                _DetailInfoRow(
                  icon: Icons.inventory_outlined,
                  label: 'Nama Barang',
                  value: _pengajuan.namaBarang,
                ),
                const _Divider(),
                _DetailInfoRow(
                  icon: Icons.numbers,
                  label: 'Jumlah Ekspektasi',
                  value: '${_pengajuan.jumlahEkspektasi} unit',
                ),
                const _Divider(),
                _DetailInfoRow(
                  icon: Icons.numbers,
                  label: 'Jumlah Aktual',
                  value: '${_pengajuan.jumlahAktual} unit',
                  valueStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isSesuai ? _green : _red,
                  ),
                ),
                const _Divider(),
                _DetailInfoRow(
                  icon: Icons.verified_outlined,
                  label: 'Kondisi',
                  valueWidget: _StatusBadge(
                    label: isSesuai ? 'SESUAI' : 'TIDAK SESUAI',
                    color: isSesuai ? _green : _red,
                  ),
                ),
                const _Divider(),
                _DetailInfoRow(
                  icon: Icons.person_outlined,
                  label: 'Petugas',
                  value: _pengajuan.namaPetugas ?? 'Petugas Gudang',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSesuai ? _green : _red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'KEMBALI KE DAFTAR',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Sub-Widgets ──────────────────────────────────────────────────────

class _StepProgressBar extends StatelessWidget {
  final int step;
  final int totalSteps;
  final int percent;
  final String label;
  final Color color;

  const _StepProgressBar({
    required this.step,
    required this.totalSteps,
    required this.percent,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STEP $step OF $totalSteps',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[500],
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '$percent%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  final Widget child;
  final Color? borderColor;

  const _CardSection({required this.child, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.icon,
    this.color = const Color(0xFFD32F2F),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _DetailInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? valueWidget;
  final TextStyle? valueStyle;

  const _DetailInfoRow({
    required this.icon,
    required this.label,
    this.value,
    this.valueWidget,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[500]),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: valueWidget ??
                Text(
                  value ?? '-',
                  style: valueStyle ??
                      const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.right,
                ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, color: Colors.grey[100], thickness: 1);
  }
}

class _ConditionRadioGroup extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _ConditionRadioGroup({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ConditionOption(
          value: 'sesuai',
          groupValue: value,
          label: 'Sesuai',
          description: 'Jumlah dan kondisi barang sesuai dengan form pengajuan',
          icon: Icons.check_circle_outline,
          activeColor: const Color(0xFF2E7D32),
          activeBg: const Color(0xFFE8F5E9),
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
        _ConditionOption(
          value: 'sebagian',
          groupValue: value,
          label: 'Sebagian Sesuai',
          description: 'Terdapat perbedaan jumlah atau kondisi sebagian barang',
          icon: Icons.remove_circle_outline,
          activeColor: const Color(0xFFE65100),
          activeBg: const Color(0xFFFFF3E0),
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
        _ConditionOption(
          value: 'tidak_sesuai',
          groupValue: value,
          label: 'Tidak Sesuai',
          description: 'Barang tidak sesuai — jumlah, kondisi, atau jenis berbeda',
          icon: Icons.cancel_outlined,
          activeColor: const Color(0xFFD32F2F),
          activeBg: const Color(0xFFFDECEC),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ConditionOption extends StatelessWidget {
  final String value;
  final String groupValue;
  final String label;
  final String description;
  final IconData icon;
  final Color activeColor;
  final Color activeBg;
  final ValueChanged<String> onChanged;

  const _ConditionOption({
    required this.value,
    required this.groupValue,
    required this.label,
    required this.description,
    required this.icon,
    required this.activeColor,
    required this.activeBg,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : Colors.grey[400],
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? activeColor : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? activeColor.withValues(alpha: 0.8) : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.radio_button_checked, color: activeColor, size: 20)
            else
              Icon(Icons.radio_button_unchecked,
                  color: Colors.grey[300], size: 20),
          ],
        ),
      ),
    );
  }
}

class _PhotoUploadSlot extends StatefulWidget {
  final String label;
  final IconData icon;

  const _PhotoUploadSlot({required this.label, required this.icon});

  @override
  State<_PhotoUploadSlot> createState() => _PhotoUploadSlotState();
}

class _PhotoUploadSlotState extends State<_PhotoUploadSlot> {
  bool _hasPhoto = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _hasPhoto = !_hasPhoto),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: _hasPhoto
              ? const Color(0xFFE8F5E9)
              : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _hasPhoto
                ? const Color(0xFF4CAF50)
                : Colors.grey.shade300,
            width: 1.5,
            style: _hasPhoto ? BorderStyle.solid : BorderStyle.none,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: CustomPaint(
            painter: _hasPhoto ? null : _DashedBorderPainter(),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _hasPhoto ? Icons.check_circle : widget.icon,
                    size: 28,
                    color: _hasPhoto
                        ? const Color(0xFF4CAF50)
                        : Colors.grey[400],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _hasPhoto ? 'Tersimpan' : widget.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _hasPhoto
                          ? const Color(0xFF4CAF50)
                          : Colors.grey[500],
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(10),
      ));

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next < metric.length ? next : metric.length),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) => false;
}

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
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
