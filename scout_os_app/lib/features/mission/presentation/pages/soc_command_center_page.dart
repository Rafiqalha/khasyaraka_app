import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:scout_os_app/features/mission/logic/mission_controller.dart';
import 'package:scout_os_app/core/config/environment.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';

class SocCommandCenterPage extends StatefulWidget {
  const SocCommandCenterPage({super.key});
  @override
  State<SocCommandCenterPage> createState() => _SocCommandCenterPageState();
}

class _SocCommandCenterPageState extends State<SocCommandCenterPage> {
  bool _missionStarted = false;
  final _searchCtrl = TextEditingController();
  int _lastScore = 0;

  static const _blue = Color(0xFF2563EB);
  static const _bg = Color(0xFFF8FAFC);
  static const _card = Colors.white;
  static const _border = Color(0xFFE5E7EB);
  static const _text = Color(0xFF111827);
  static const _sub = Color(0xFF6B7280);
  static const _green = Color(0xFF16A34A);
  static const _red = Color(0xFFDC2626);
  static const _amber = Color(0xFFF59E0B);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startMission());
  }

  void _startMission() {
    if (_missionStarted) return;
    _missionStarted = true;
    context.read<MissionController>().generateMission('beginner');
  }

  @override
  void dispose() {
    _searchCtrl.dispose(); super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Consumer<MissionController>(builder: (context, ctrl, _) {
          if (ctrl.isLoading) {
            return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 2, color: _blue)),
              SizedBox(height: 16),
              Text('Preparing workspace...', style: TextStyle(color: _sub, fontSize: 13)),
            ]));
          }

          if (ctrl.score != _lastScore) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(ctrl.score > _lastScore ? '+${ctrl.score - _lastScore} PTS' : '${ctrl.score - _lastScore} PTS', style: GoogleFonts.inter(color: ctrl.score > _lastScore ? _green : _red)),
                backgroundColor: _card, duration: const Duration(seconds: 1), behavior: SnackBarBehavior.floating,
              ));
            });
            _lastScore = ctrl.score;
          }

          return Column(children: [
            _header(ctrl),
            _objective(ctrl),
            _evidence(ctrl),
            _searchBar(ctrl),
            _quickActions(ctrl),
            Expanded(child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _aiCoach(ctrl),
                const SizedBox(height: 12),
                _infra(ctrl),
                const SizedBox(height: 12),
                _logs(ctrl),
                const SizedBox(height: 12),
                _status(ctrl),
              ]),
            )),
            _terminal(ctrl),
          ]);
        }),
      ),
    );
  }

  Widget _header(MissionController ctrl) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: _card,
      child: Row(children: [
        Text('Mission', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: _text)),
        const Spacer(),
        _badge('${ctrl.timeRemaining ~/ 60}:${(ctrl.timeRemaining % 60).toString().padLeft(2, '0')}', ctrl.timeRemaining < 60 ? _red : _blue),
        const SizedBox(width: 8),
        _badge('${ctrl.score} PTS', const Color(0xFFF59E0B)),
      ]),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withAlpha(12), borderRadius: BorderRadius.circular(999), border: Border.all(color: color.withAlpha(30))),
      child: Text(text, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _objective(MissionController ctrl) {
    String obj;
    if (ctrl.serverHealth <= 0) obj = 'Failed — all servers compromised.';
    else if (ctrl.activeThreats.isEmpty && ctrl.blockedIPs.isNotEmpty && ctrl.serverHealth > 85) obj = 'Threat contained — awaiting verification.';
    else if (ctrl.blockedIPs.isNotEmpty) obj = 'Containment in progress — monitor for residual activity.';
    else if (ctrl.activeThreats.isNotEmpty) obj = 'Identify and block the attacker IP. Search logs for anomalies.';
    else obj = 'Anomalies detected on database cluster. Begin investigation.';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      color: _card,
      child: Row(children: [
        const Icon(Icons.gps_fixed, color: _blue, size: 18), const SizedBox(width: 8),
        Expanded(child: Text(obj, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: _sub))),
      ]),
    );
  }

  Widget _evidence(MissionController ctrl) {
    final pct = ((ctrl.blockedIPs.length * 25) + (ctrl.score / 2).floor()).clamp(5, 100);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      color: _card,
      child: Row(children: [
        Text('Evidence', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: _sub)), const SizedBox(width: 10),
        Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(value: pct / 100, minHeight: 6, backgroundColor: _border, valueColor: const AlwaysStoppedAnimation(_blue)))),
        const SizedBox(width: 10),
        Text('$pct%', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: _blue)),
      ]),
    );
  }

  Widget _searchBar(MissionController ctrl) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4), color: _card,
      child: TextField(
        controller: _searchCtrl, onChanged: (v) => ctrl.setSearchQuery(v),
        style: GoogleFonts.inter(fontSize: 13, color: _text),
        decoration: InputDecoration(
          hintText: 'Search logs...', hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
          filled: true, fillColor: _bg,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _blue)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
          suffix: ctrl.searchQuery.isNotEmpty ? InkWell(onTap: () { _searchCtrl.clear(); ctrl.setSearchQuery(''); }, child: const Icon(Icons.close, color: Color(0xFF9CA3AF), size: 18)) : null,
        ),
      ),
    );
  }

  Widget _quickActions(MissionController ctrl) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8), color: _card,
      child: Row(children: [
        _chip('192.168.1.105', () { _searchCtrl.text = '192.168.1.105'; ctrl.setSearchQuery('192.168.1.105'); }),
        const SizedBox(width: 6),
        _chip('Failed logins', () { _searchCtrl.text = '401'; ctrl.setSearchQuery('401'); }),
        const SizedBox(width: 6),
        _chip('Block IP', () => _blockDialog(ctrl)),
      ]),
    );
  }

  Widget _chip(String label, VoidCallback onTap) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(999), child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(color: const Color(0xFF2563EB).withAlpha(10), borderRadius: BorderRadius.circular(999), border: Border.all(color: const Color(0xFF2563EB).withAlpha(20))),
      child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: _blue)),
    ));
  }

  Widget _aiCoach(MissionController ctrl) {
    final evt = ctrl.latestAIEvent;
    final text = evt.isNotEmpty ? evt : ctrl.blockedIPs.isNotEmpty ? 'AI: Attacker ${ctrl.blockedIPs.first} contained. Server health ${ctrl.serverHealth}%. Watch for anomalous outbound connections.' : ctrl.activeThreats.isNotEmpty ? 'AI: Active threats detected. Search for unusual authentication patterns.' : 'AI: Begin your investigation. I am monitoring the infrastructure for changes.';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(16), border: Border.all(color: _border), boxShadow: const [BoxShadow(color: Color(0x0D000000), offset: Offset(0, 4), blurRadius: 16)]),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF2563EB).withAlpha(10), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.psychology, color: _blue, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('AI Hypothesis', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _blue)),
          const SizedBox(height: 4),
          Text(text, style: GoogleFonts.inter(fontSize: 13, color: _sub, height: 1.4)),
        ])),
      ]),
    );
  }

  Widget _infra(MissionController ctrl) {
    final servers = ctrl.servers;
    if (servers.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(16), border: Border.all(color: _border), boxShadow: const [BoxShadow(color: Color(0x0D000000), offset: Offset(0, 4), blurRadius: 16)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Infrastructure', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: _text)),
          const Spacer(),
          Text('Health ${ctrl.serverHealth}%', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: ctrl.serverHealth < 30 ? _red : _green)),
        ]),
        const SizedBox(height: 12),
        ...servers.map((s) {
          final id = s['id']?.toString() ?? '';
          final name = s['name']?.toString() ?? id;
          final ip = s['ip']?.toString() ?? '';
          final breached = ctrl.isServerBreached(id);
          final cpu = ctrl.serverCpu(id);
          final color = breached ? _red : (cpu > 80 ? _amber : _green);
          return Padding(padding: const EdgeInsets.only(bottom: 6), child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withAlpha(8), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withAlpha(30))),
            child: Row(children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Expanded(child: Text(name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: _text))),
              Text(ip, style: GoogleFonts.inter(fontSize: 11, color: _sub)),
              const SizedBox(width: 16),
              Text('CPU $cpu%', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
            ]),
          ));
        }),
      ]),
    );
  }

  Widget _logs(MissionController ctrl) {
    final logs = ctrl.filteredLogs;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(16), border: Border.all(color: _border), boxShadow: const [BoxShadow(color: Color(0x0D000000), offset: Offset(0, 4), blurRadius: 16)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Logs', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: _text)),
          const Spacer(),
          Text('${logs.length} entries', style: GoogleFonts.inter(fontSize: 11, color: _sub)),
        ]),
        const SizedBox(height: 10),
        if (logs.isEmpty)
          Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Center(child: Text('Search for IPs, status codes, or keywords above.', style: GoogleFonts.inter(fontSize: 13, color: _sub))))
        else
          ...logs.take(25).map((l) {
            final anomaly = l['is_anomaly'] == true;
            return Container(
              margin: const EdgeInsets.only(bottom: 2), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(color: anomaly ? _red.withAlpha(6) : Colors.transparent, borderRadius: BorderRadius.circular(6)),
              child: Row(children: [
                Text(l['timestamp'] ?? '', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: anomaly ? _red : _sub)),
                const SizedBox(width: 8),
                SizedBox(width: 85, child: Text(l['source_ip'] ?? '', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: anomaly ? _red : _sub), overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 6),
                Expanded(child: Text(l['message'] ?? '', style: GoogleFonts.inter(fontSize: 11, color: anomaly ? _red : _text), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
            );
          }),
      ]),
    );
  }

  Widget _status(MissionController ctrl) {
    final won = ctrl.activeThreats.isEmpty && ctrl.blockedIPs.isNotEmpty && ctrl.serverHealth > 85;
    final lost = ctrl.serverHealth <= 0 || ctrl.timeRemaining <= 0;
    if (!won && !lost) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(16), border: Border.all(color: _border), boxShadow: const [BoxShadow(color: Color(0x0D000000), offset: Offset(0, 4), blurRadius: 16)]),
      child: Column(children: [
        Text(won ? 'Mission Complete' : 'Mission Failed', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: won ? _green : _red)),
        const SizedBox(height: 8),
        Text(won ? 'Threat contained. ${ctrl.serverHealth}% health. ${ctrl.score} points.' : 'Server health ${ctrl.serverHealth}%. Try a new mission.', style: GoogleFonts.inter(fontSize: 13, color: _sub)),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: () => ctrl.generateMission('apt'), style: ElevatedButton.styleFrom(backgroundColor: _blue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)), child: Text('Next Mission', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
      ]),
    );
  }

  Widget _terminal(MissionController ctrl) {
    return _TerminalBar(missionId: ctrl.missionId);
  }

  void _blockDialog(MissionController ctrl) {
    final tc = TextEditingController(text: '192.168.1.105');
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: _card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Block IP', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: _text)),
      content: TextField(controller: tc, style: GoogleFonts.inter(color: _text), decoration: InputDecoration(hintText: 'IP address', hintStyle: const TextStyle(color: Color(0xFF9CA3AF)), filled: true, fillColor: _bg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _border)))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.inter(color: _sub))),
        ElevatedButton(onPressed: () { ctrl.sendAction('block_ip', {'ip': tc.text}); Navigator.pop(ctx); }, style: ElevatedButton.styleFrom(backgroundColor: _blue), child: Text('Block', style: GoogleFonts.inter(color: Colors.white))),
      ],
    ));
  }
}

class _TerminalBar extends StatefulWidget {
  final String? missionId;
  const _TerminalBar({required this.missionId});
  @override
  State<_TerminalBar> createState() => _TerminalBarState();
}

class _TerminalBarState extends State<_TerminalBar> {
  final _cmdCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<String> _output = [];
  WebSocketChannel? _ws;
  bool _connected = false;

  @override
  void initState() { super.initState(); _connect(); }

  void _connect() {
    if (widget.missionId == null) return;
    final host = Environment.apiBaseUrl.replaceFirst('http://', '').replaceFirst('https://', '').replaceAll('/api/v1', '').split('/').first;
    final token = ApiDioProvider.cachedToken;
    if (token == null) return;
    final uri = Uri.parse('ws://$host/api/v1/missions/${widget.missionId}/terminal?token=$token');
    _ws = WebSocketChannel.connect(uri);
    _ws!.stream.listen((data) {
      setState(() { _connected = true; _output.add(data.toString()); });
      WidgetsBinding.instance.addPostFrameCallback((_) { if (_scrollCtrl.hasClients) _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent); });
    }, onError: (_) => setState(() => _connected = false));
  }

  void _exec() {
    final cmd = _cmdCtrl.text.trim();
    if (cmd.isEmpty || _ws == null) return;
    setState(() { _output.add('\$ $cmd'); _cmdCtrl.clear(); });
    _ws!.sink.add(jsonEncode({'command': cmd}));
  }

  @override
  void dispose() { _cmdCtrl.dispose(); _scrollCtrl.dispose(); _ws?.sink.close(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF1E1E2E), border: Border(top: BorderSide(color: Color(0xFF374151)))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), color: const Color(0xFF161B22),
          child: Row(children: [
            Text('Terminal', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF16A34A))), const Spacer(),
            Container(width: 6, height: 6, decoration: BoxDecoration(color: _connected ? const Color(0xFF16A34A) : const Color(0xFFDC2626), shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text(_connected ? 'Connected' : 'Offline', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: _connected ? const Color(0xFF16A34A) : const Color(0xFFDC2626))),
          ])),
        if (_output.isNotEmpty) SizedBox(height: 100, child: ListView.builder(
          controller: _scrollCtrl, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), itemCount: _output.length,
          itemBuilder: (_, i) => Text(_output[i], style: GoogleFonts.jetBrainsMono(fontSize: 11, color: const Color(0xFF9CA3AF), height: 1.4)),
        )),
        Padding(padding: const EdgeInsets.fromLTRB(16, 6, 16, 12), child: Row(children: [
          Text('\$ ', style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF16A34A))),
          Expanded(child: TextField(
            controller: _cmdCtrl, onSubmitted: (_) => _exec(),
            style: GoogleFonts.jetBrainsMono(fontSize: 14, color: const Color(0xFFD1D5DB)),
            decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero, hintText: 'type command...', hintStyle: TextStyle(color: Color(0xFF4B5563))),
          )),
          InkWell(onTap: _exec, child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.send_rounded, color: Color(0xFF16A34A), size: 18))),
        ])),
      ]),
    );
  }
}
