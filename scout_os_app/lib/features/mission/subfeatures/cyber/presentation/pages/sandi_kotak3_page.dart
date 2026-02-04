import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/data/sandi_model.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/theme/cyber_theme.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/widgets/cyber_container.dart';

/// Sandi Kotak 3 (Pigpen Cipher Variant 3) Tool
///
/// NOTE:
/// - Repo tidak memiliki file gambar referensi yang disebut di prompt,
///   jadi implementasi ini mengikuti mapping yang dituliskan user dan
///   menggambar board/simbol secara simetris & scalable dengan Canvas.
class SandiKotak3Page extends StatefulWidget {
  final SandiModel sandi;

  const SandiKotak3Page({
    super.key,
    required this.sandi,
  });

  @override
  State<SandiKotak3Page> createState() => _SandiKotak3PageState();
}

class _SandiKotak3PageState extends State<SandiKotak3Page>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _encodeController = TextEditingController();
  final TextEditingController _decodeController = TextEditingController();

  final List<String> _decodeHistory = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _encodeController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _encodeController.dispose();
    _decodeController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        duration: const Duration(seconds: 1),
        backgroundColor: CyberTheme.neonCyan.withOpacity(0.2),
      ),
    );
  }

  void _onClear() {
    setState(() {
      if (_tabController.index == 1) {
        _encodeController.clear();
      } else if (_tabController.index == 2) {
        _decodeController.clear();
        _decodeHistory.clear();
      }
    });
  }

  void _onKeyTap(String letter) {
    setState(() {
      _decodeController.text += letter;
      _decodeHistory.add(letter);
    });
  }

  void _onBackspace() {
    if (_decodeController.text.isEmpty) return;
    setState(() {
      _decodeController.text =
          _decodeController.text.substring(0, _decodeController.text.length - 1);
      if (_decodeHistory.isNotEmpty) _decodeHistory.removeLast();
    });
  }

  void _onSpace() {
    setState(() {
      _decodeController.text += ' ';
      _decodeHistory.add(' ');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.sandi.name.toUpperCase(),
          style: CyberTheme.headline().copyWith(
            fontSize: 18,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: CyberTheme.neonCyan,
          labelColor: CyberTheme.neonCyan,
          unselectedLabelColor: CyberTheme.textSecondary,
          labelStyle: GoogleFonts.courierPrime(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          tabs: const [
            Tab(text: 'REFERENSI'),
            Tab(text: 'ENCODE'),
            Tab(text: 'DECODE'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear, color: CyberTheme.neonCyan),
            tooltip: 'Clear',
            onPressed: _onClear,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReferenceTab(),
          _buildEncodeTab(),
          _buildDecodeTab(),
        ],
      ),
    );
  }

  Widget _buildReferenceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CyberContainer(
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: CyberTheme.neonCyan),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Referensi Sandi Kotak 3 (Canvas). Board dibuat mengikuti diagram standar: kotak tengah, diamond luar, dan garis silang yang memanjang.',
                    style: CyberTheme.body().copyWith(
                      color: CyberTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CyberTheme.neonCyan.withOpacity(0.7)),
              boxShadow: [
                BoxShadow(
                  color: CyberTheme.neonCyan.withOpacity(0.12),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: AspectRatio(
              aspectRatio: 1,
              child: CustomPaint(
                painter: Kotak3ReferenceBoardPainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEncodeTab() {
    final input = _encodeController.text;
    final letters = input.toUpperCase().split('');
    final encoded = input.toUpperCase();
    final hasContent = input.trim().isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CyberContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Masukkan Pesan Asli',
                  style: CyberTheme.headline().copyWith(fontSize: 16),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _encodeController,
                  style: GoogleFonts.courierPrime(
                    fontSize: 18,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Contoh: PRAMUKA',
                    hintStyle: GoogleFonts.courierPrime(
                      fontSize: 14,
                      color: CyberTheme.textSecondary,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  maxLines: null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (hasContent) ...[
            CyberContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hasil Encode (Simbol)',
                        style: CyberTheme.headline().copyWith(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: CyberTheme.neonCyan),
                        tooltip: 'Copy text',
                        onPressed: encoded.isEmpty ? null : () => _copyToClipboard(encoded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: letters.map((c) {
                      if (c == ' ') {
                        return const SizedBox(width: 20, height: 48);
                      }
                      if (!_isAZ(c)) {
                        return _miniChip(c);
                      }
                      return SizedBox(
                        width: 48,
                        height: 48,
                        child: CustomPaint(
                          painter: Kotak3Painter(
                            letter: c,
                            strokeWidth: 3.5,
                            lineColor: Colors.yellowAccent,
                            dotColor: Colors.yellowAccent,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDecodeTab() {
    final decoded = _decodeController.text;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: CyberContainer(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hasil Pesan',
                        style: CyberTheme.headline().copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        decoded.isEmpty ? '—' : decoded,
                        style: GoogleFonts.courierPrime(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: CyberTheme.neonCyan),
                  tooltip: 'Copy',
                  onPressed: decoded.isEmpty ? null : () => _copyToClipboard(decoded),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_decodeHistory.isNotEmpty)
          SizedBox(
            height: 64,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemCount: _decodeHistory.length,
              itemBuilder: (context, idx) {
                final c = _decodeHistory[idx];
                if (c == ' ') {
                  return const SizedBox(width: 24);
                }
                return SizedBox(
                  width: 48,
                  height: 48,
                  child: CustomPaint(
                    painter: Kotak3Painter(
                      letter: c.toUpperCase(),
                      strokeWidth: 3.0,
                      lineColor: Colors.yellowAccent,
                      dotColor: Colors.yellowAccent,
                    ),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: CyberTheme.neonCyan),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _onBackspace,
                  icon: const Icon(Icons.backspace_outlined),
                  label: Text(
                    'BACKSPACE',
                    style: GoogleFonts.courierPrime(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: CyberTheme.neonCyan),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _onSpace,
                  icon: const Icon(Icons.space_bar),
                  label: Text(
                    'SPACE',
                    style: GoogleFonts.courierPrime(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _Kotak3Keyboard(onTap: _onKeyTap),
          ),
        ),
      ],
    );
  }

  Widget _miniChip(String c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CyberTheme.neonCyan.withOpacity(0.5)),
      ),
      child: Text(
        c,
        style: GoogleFonts.courierPrime(
          color: CyberTheme.textSecondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

bool _isAZ(String c) => RegExp(r'^[A-Z]$').hasMatch(c);

class _Kotak3Keyboard extends StatelessWidget {
  final void Function(String letter) onTap;

  const _Kotak3Keyboard({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final items = letters.split('');

    return GridView.builder(
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final letter = items[index];
        return InkWell(
          onTap: () => onTap(letter),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CyberTheme.neonCyan.withOpacity(0.7)),
              boxShadow: [
                BoxShadow(
                  color: CyberTheme.neonCyan.withOpacity(0.12),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: CustomPaint(
                size: const Size(34, 34),
                painter: Kotak3Painter(
                  letter: letter,
                  strokeWidth: 3.2,
                  lineColor: Colors.yellowAccent,
                  dotColor: Colors.yellowAccent,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Painter untuk menggambar simbol per-huruf (A-Z) sesuai mapping Kotak 3.
class Kotak3Painter extends CustomPainter {
  final String letter;
  final double strokeWidth;
  final Color lineColor;
  final Color dotColor;

  Kotak3Painter({
    required this.letter,
    required this.strokeWidth,
    required this.lineColor,
    required this.dotColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth.clamp(1.0, 4.0) as double
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    // === Source-of-truth coordinate system (as per user formulas) ===
    final W = size.width;
    final H = size.height;
    final cx = W / 2;
    final cy = H / 2;
    final m = size.shortestSide * 0.10; // ~5 for 50x50, scales well

    Offset c(double x, double y) => Offset(x, y);

    void dotAtTriangle(Offset a, Offset b, Offset c0) {
      final d = Offset(
        (a.dx + b.dx + c0.dx) / 3,
        (a.dy + b.dy + c0.dy) / 3,
      );
      canvas.drawCircle(d, size.shortestSide * 0.04, dotPaint);
    }

    void dotAtCenter() {
      canvas.drawCircle(Offset(cx, cy), size.shortestSide * 0.04, dotPaint);
    }

    void drawBox({required bool dot}) {
      // 4-sided box (only for A/B)
      canvas.drawLine(c(m, m), c(W - m, m), paint);
      canvas.drawLine(c(W - m, m), c(W - m, H - m), paint);
      canvas.drawLine(c(W - m, H - m), c(m, H - m), paint);
      canvas.drawLine(c(m, H - m), c(m, m), paint);
      if (dot) dotAtCenter();
    }

    // Brackets
    void drawBracketC() {
      // (m, cy) -> (m, m) -> (cx, m)
      canvas.drawLine(c(m, cy), c(m, m), paint);
      canvas.drawLine(c(m, m), c(cx, m), paint);
    }

    void drawBracketI() {
      // (W-m, cy) -> (W-m, m) -> (cx, m)
      canvas.drawLine(c(W - m, cy), c(W - m, m), paint);
      canvas.drawLine(c(W - m, m), c(cx, m), paint);
    }

    void drawBracketO() {
      // (W-m, cy) -> (W-m, H-m) -> (cx, H-m)
      canvas.drawLine(c(W - m, cy), c(W - m, H - m), paint);
      canvas.drawLine(c(W - m, H - m), c(cx, H - m), paint);
    }

    void drawBracketU() {
      // (m, cy) -> (m, H-m) -> (cx, H-m)
      canvas.drawLine(c(m, cy), c(m, H - m), paint);
      canvas.drawLine(c(m, H - m), c(cx, H - m), paint);
    }

    // Corner inner "triangles" must be OPEN 2-LINE angles (no close, no 3rd side).
    // We still use the implied 3 points for dot centroid.
    void drawAngleD({required bool dot}) {
      // TL: draw (m,cy)->(m,m) and (m,m)->(cx,m)
      final v = c(m, m);
      final a = c(m, cy);
      final b = c(cx, m);
      canvas.drawLine(a, v, paint);
      canvas.drawLine(v, b, paint);
      if (dot) dotAtTriangle(v, a, b);
    }

    void drawAngleJ({required bool dot}) {
      // TR: draw (cx,m)->(W-m,m) and (W-m,m)->(W-m,cy)
      final v = c(W - m, m);
      final a = c(cx, m);
      final b = c(W - m, cy);
      canvas.drawLine(a, v, paint);
      canvas.drawLine(v, b, paint);
      if (dot) dotAtTriangle(v, a, b);
    }

    void drawAngleP({required bool dot}) {
      // BR: draw (W-m,cy)->(W-m,H-m) and (W-m,H-m)->(cx,H-m)
      final v = c(W - m, H - m);
      final a = c(W - m, cy);
      final b = c(cx, H - m);
      canvas.drawLine(a, v, paint);
      canvas.drawLine(v, b, paint);
      if (dot) dotAtTriangle(v, a, b);
    }

    void drawAngleV({required bool dot}) {
      // BL: draw (cx,H-m)->(m,H-m) and (m,H-m)->(m,cy)
      final v = c(m, H - m);
      final a = c(cx, H - m);
      final b = c(m, cy);
      canvas.drawLine(a, v, paint);
      canvas.drawLine(v, b, paint);
      if (dot) dotAtTriangle(v, a, b);
    }

    // Side "triangles" must be OPEN 2-LINE angles (V-shapes).
    void drawAngleF() {
      // Outer Top: (m,H-m)->(cx,m) and (W-m,H-m)->(cx,m)
      final v = c(cx, m);
      final a = c(m, H - m);
      final b = c(W - m, H - m);
      canvas.drawLine(a, v, paint);
      canvas.drawLine(b, v, paint);
    }

    void drawAngleG({required bool dot}) {
      // Inner Top: (m,cy)->(cx,m) and (W-m,cy)->(cx,m)
      final v = c(cx, m);
      final a = c(m, cy);
      final b = c(W - m, cy);
      canvas.drawLine(a, v, paint);
      canvas.drawLine(b, v, paint);
      if (dot) dotAtTriangle(v, a, b);
    }

    void drawAngleL() {
      // Outer Right: (m,m)->(W-m,cy) and (m,H-m)->(W-m,cy)
      final v = c(W - m, cy);
      final a = c(m, m);
      final b = c(m, H - m);
      canvas.drawLine(a, v, paint);
      canvas.drawLine(b, v, paint);
    }

    void drawAngleM({required bool dot}) {
      // Inner Right: (cx,m)->(W-m,cy) and (cx,H-m)->(W-m,cy)
      final v = c(W - m, cy);
      final a = c(cx, m);
      final b = c(cx, H - m);
      canvas.drawLine(a, v, paint);
      canvas.drawLine(b, v, paint);
      if (dot) dotAtTriangle(v, a, b);
    }

    void drawAngleR() {
      // Outer Bottom: (m,m)->(cx,H-m) and (W-m,m)->(cx,H-m)
      final v = c(cx, H - m);
      final a = c(m, m);
      final b = c(W - m, m);
      canvas.drawLine(a, v, paint);
      canvas.drawLine(b, v, paint);
    }

    void drawAngleS({required bool dot}) {
      // Inner Bottom: (m,cy)->(cx,H-m) and (W-m,cy)->(cx,H-m)
      final v = c(cx, H - m);
      final a = c(m, cy);
      final b = c(W - m, cy);
      canvas.drawLine(a, v, paint);
      canvas.drawLine(b, v, paint);
      if (dot) dotAtTriangle(v, a, b);
    }

    void drawAngleX() {
      // Outer Left: (W-m,m)->(m,cy) and (W-m,H-m)->(m,cy)
      final v = c(m, cy);
      final a = c(W - m, m);
      final b = c(W - m, H - m);
      canvas.drawLine(a, v, paint);
      canvas.drawLine(b, v, paint);
    }

    void drawAngleY({required bool dot}) {
      // Inner Left: (cx,m)->(m,cy) and (cx,H-m)->(m,cy)
      final v = c(m, cy);
      final a = c(cx, m);
      final b = c(cx, H - m);
      canvas.drawLine(a, v, paint);
      canvas.drawLine(b, v, paint);
      if (dot) dotAtTriangle(v, a, b);
    }

    // === Single-source-of-truth switch-case A-Z ===
    switch (letter.toUpperCase()) {
      // 1) Center
      case 'A':
        drawBox(dot: false);
        return;
      case 'B':
        drawBox(dot: true);
        return;

      // 2) Top-left
      case 'C':
        drawBracketC();
        return;
      case 'D':
        drawAngleD(dot: false);
        return;
      case 'E':
        drawAngleD(dot: true);
        return;

      // 3) Top
      case 'F':
        drawAngleF();
        return;
      case 'G':
        drawAngleG(dot: false);
        return;
      case 'H':
        drawAngleG(dot: true);
        return;

      // 4) Top-right
      case 'I':
        drawBracketI();
        return;
      case 'J':
        drawAngleJ(dot: false);
        return;
      case 'K':
        drawAngleJ(dot: true);
        return;

      // 5) Right
      case 'L':
        drawAngleL();
        return;
      case 'M':
        drawAngleM(dot: false);
        return;
      case 'N':
        drawAngleM(dot: true);
        return;

      // 6) Bottom-right
      case 'O':
        drawBracketO();
        return;
      case 'P':
        drawAngleP(dot: false);
        return;
      case 'Q':
        drawAngleP(dot: true);
        return;

      // 7) Bottom
      case 'R':
        drawAngleR();
        return;
      case 'S':
        drawAngleS(dot: false);
        return;
      case 'T':
        drawAngleS(dot: true);
        return;

      // 8) Bottom-left
      case 'U':
        drawBracketU();
        return;
      case 'V':
        drawAngleV(dot: false);
        return;
      case 'W':
        drawAngleV(dot: true);
        return;

      // 9) Left
      case 'X':
        drawAngleX();
        return;
      case 'Y':
        drawAngleY(dot: false);
        return;
      case 'Z':
        drawAngleY(dot: true);
        return;

      default:
        return;
    }
  }

  @override
  bool shouldRepaint(covariant Kotak3Painter oldDelegate) {
    return oldDelegate.letter != letter ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.dotColor != dotColor;
  }
}

/// Reference board: menggambar struktur Kotak 3 lengkap + label huruf.
class Kotak3ReferenceBoardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter;

    final rect = Offset.zero & size;
    final cx = rect.center.dx;
    final cy = rect.center.dy;

    // Geometry based on the standard diagram:
    // - Center square corners sit on the diamond edges.
    final a = size.shortestSide * 0.18; // half-size of center square
    final b = 2 * a; // diamond radius so that (a,a) lies on |x|+|y|=b
    final pad = size.shortestSide * 0.06;

    final center = Rect.fromCenter(
      center: Offset(cx, cy),
      width: 2 * a,
      height: 2 * a,
    );

    // Diamond vertices
    final topV = Offset(cx, cy - b);
    final rightV = Offset(cx + b, cy);
    final bottomV = Offset(cx, cy + b);
    final leftV = Offset(cx - b, cy);

    // Extend lines beyond the diamond (like the reference image)
    final ext = size.shortestSide * 0.26;

    // Horizontal lines through the top/bottom edges of the center square
    final yTop = cy - a;
    final yBot = cy + a;
    canvas.drawLine(Offset(cx - b - ext, yTop), Offset(cx + b + ext, yTop), paint);
    canvas.drawLine(Offset(cx - b - ext, yBot), Offset(cx + b + ext, yBot), paint);

    // Vertical lines through the left/right edges of the center square
    final xLeft = cx - a;
    final xRight = cx + a;
    canvas.drawLine(Offset(xLeft, cy - b - ext), Offset(xLeft, cy + b + ext), paint);
    canvas.drawLine(Offset(xRight, cy - b - ext), Offset(xRight, cy + b + ext), paint);

    // Center square
    canvas.drawRect(center, paint);

    // Diamond (rotated square)
    final diamond = Path()
      ..moveTo(topV.dx, topV.dy)
      ..lineTo(rightV.dx, rightV.dy)
      ..lineTo(bottomV.dx, bottomV.dy)
      ..lineTo(leftV.dx, leftV.dy)
      ..close();
    canvas.drawPath(diamond, paint);

    // Text styling (black on white like the reference)
    final fontSize = size.shortestSide * 0.055;

    // "AB" in the center
    _drawLabel(canvas, size, 'AB', Offset(cx, cy), fontSize: size.shortestSide * 0.08, color: Colors.black);

    // Labels positioned to match the provided diagram (approximate but faithful structure)
    // Top group
    _drawLabel(canvas, size, 'F', topV + Offset(0, fontSize * 0.10), fontSize: fontSize, color: Colors.black);
    _drawLabel(canvas, size, 'E', Offset(cx - a * 0.55, cy - a * 1.55), fontSize: fontSize, color: Colors.black);
    _drawLabel(canvas, size, 'G', Offset(cx + a * 0.55, cy - a * 1.55), fontSize: fontSize, color: Colors.black);
    _drawLabel(canvas, size, 'D', Offset(xLeft - fontSize * 0.6, yTop - fontSize * 1.05), fontSize: fontSize, color: Colors.black);
    _drawLabel(canvas, size, 'H', Offset(xRight + fontSize * 0.6, yTop - fontSize * 1.05), fontSize: fontSize, color: Colors.black);
    _drawLabel(canvas, size, 'C', Offset(xLeft - fontSize * 1.35, yTop - fontSize * 0.25), fontSize: fontSize, color: Colors.black);
    _drawLabel(canvas, size, 'I', Offset(xRight + fontSize * 1.35, yTop - fontSize * 0.25), fontSize: fontSize, color: Colors.black);

    // Right side group
    _drawLabel(canvas, size, 'L', rightV + Offset(-fontSize * 0.2, 0), fontSize: fontSize, color: Colors.black);
    _drawLabel(canvas, size, 'J', Offset(xRight + a * 0.65, yTop + a * 0.30), fontSize: fontSize, color: Colors.black);
    _drawLabel(canvas, size, 'K', Offset(xRight + fontSize * 0.55, cy - fontSize * 0.45), fontSize: fontSize, color: Colors.black);
    _drawLabel(canvas, size, 'M', Offset(xRight + fontSize * 0.55, cy + fontSize * 0.65), fontSize: fontSize, color: Colors.black);
    _drawLabel(canvas, size, 'N', Offset(xRight + fontSize * 1.35, yBot + fontSize * 0.25), fontSize: fontSize, color: Colors.black);

    // Bottom group
    _drawLabel(canvas, size, 'R', bottomV + Offset(0, -fontSize * 0.10), fontSize: fontSize, color: Colors.black);
    _drawLabel(canvas, size, 'Q', Offset(cx + a * 0.55, cy + a * 1.55), fontSize: fontSize, color: Colors.black);
    _drawLabel(canvas, size, 'S', Offset(cx - a * 0.55, cy + a * 1.55), fontSize: fontSize, color: Colors.black);
    _drawLabel(canvas, size, 'P', Offset(xRight + a * 0.05, yBot + a * 0.30), fontSize: fontSize, color: Colors.black);
    _drawLabel(canvas, size, 'T', Offset(xLeft - a * 0.05, yBot + a * 0.30), fontSize: fontSize, color: Colors.black);
    _drawLabel(canvas, size, 'O', Offset(xRight + fontSize * 1.35, yBot + fontSize * 0.25), fontSize: fontSize, color: Colors.black);
    _drawLabel(canvas, size, 'U', Offset(xLeft - fontSize * 1.35, yBot + fontSize * 0.25), fontSize: fontSize, color: Colors.black);

    // Left side group
    _drawLabel(canvas, size, 'X', leftV + Offset(fontSize * 0.2, 0), fontSize: fontSize, color: Colors.black);
    _drawLabel(canvas, size, 'Z', Offset(xLeft - fontSize * 1.35, yTop - fontSize * 0.25 + fontSize * 0.95), fontSize: fontSize, color: Colors.black);
    _drawLabel(canvas, size, 'Y', Offset(xLeft - fontSize * 0.55, cy - fontSize * 0.45), fontSize: fontSize, color: Colors.black);
    _drawLabel(canvas, size, 'W', Offset(xLeft - fontSize * 0.55, cy + fontSize * 0.65), fontSize: fontSize, color: Colors.black);
    _drawLabel(canvas, size, 'V', Offset(xLeft - fontSize * 1.35, yBot + fontSize * 0.25 - fontSize * 0.95), fontSize: fontSize, color: Colors.black);

    // Safety: avoid unused var warning
    // ignore: unused_local_variable
    final _ = pad;
  }

  void _drawLabel(
    Canvas canvas,
    Size size,
    String text,
    Offset center, {
    double? fontSize,
    TextAlign align = TextAlign.center,
    Color color = Colors.white,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.courierPrime(
          fontSize: fontSize ?? size.shortestSide * 0.055,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant Kotak3ReferenceBoardPainter oldDelegate) => false;
}

