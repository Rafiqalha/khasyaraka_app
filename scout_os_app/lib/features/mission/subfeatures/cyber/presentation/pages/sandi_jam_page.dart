import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/data/sandi_model.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/theme/cyber_theme.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/widgets/cyber_container.dart';

/// Sandi Jam (Clock Cipher) Tool
/// 
/// Uses a starting time as 'A' and a fixed interval to determine subsequent letters.
/// Example: Start 07:00, Interval 5 mins → 07:00=A, 07:05=B, 07:10=C, etc.
class SandiJamPage extends StatefulWidget {
  final SandiModel sandi;

  const SandiJamPage({
    super.key,
    required this.sandi,
  });

  @override
  State<SandiJamPage> createState() => _SandiJamPageState();
}

class _SandiJamPageState extends State<SandiJamPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _encodeController = TextEditingController();
  final TextEditingController _decodeController = TextEditingController();
  
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  int _interval = 15; // minutes
  final List<String> _decodeTimes = [];
  String _decodedText = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _encodeController.addListener(_onEncodeInputChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _encodeController.dispose();
    _decodeController.dispose();
    super.dispose();
  }

  void _onEncodeInputChanged() {
    setState(() {});
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: CyberTheme.neonCyan,
              onPrimary: Colors.black,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  void _onClear() {
    setState(() {
      if (_tabController.index == 0) {
        _encodeController.clear();
      } else {
        _decodeController.clear();
        _decodeTimes.clear();
        _decodedText = '';
      }
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard'),
        duration: const Duration(seconds: 1),
        backgroundColor: CyberTheme.neonCyan.withOpacity(0.2),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  TimeOfDay _addMinutes(TimeOfDay time, int minutes) {
    int totalMinutes = time.hour * 60 + time.minute + minutes;
    // Handle 24-hour wrap
    totalMinutes = totalMinutes % (24 * 60);
    return TimeOfDay(hour: totalMinutes ~/ 60, minute: totalMinutes % 60);
  }

  int _getMinutesDifference(TimeOfDay time1, TimeOfDay time2) {
    int minutes1 = time1.hour * 60 + time1.minute;
    int minutes2 = time2.hour * 60 + time2.minute;
    int diff = minutes2 - minutes1;
    // Handle wrap around
    if (diff < 0) {
      diff += 24 * 60;
    }
    return diff;
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
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
          tabs: const [
            Tab(text: 'ENCODE'),
            Tab(text: 'DECODE'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEncodeTab(),
          _buildDecodeTab(),
        ],
      ),
    );
  }

  Widget _buildEncodeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Settings Section
          CyberContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: CyberTheme.headline().copyWith(fontSize: 16),
                ),
                const SizedBox(height: 16),
                // Start Time Picker
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start Time (A)',
                            style: CyberTheme.body().copyWith(
                              color: CyberTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _selectStartTime,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                border: Border.all(
                                  color: CyberTheme.neonCyan,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatTime(_startTime),
                                    style: GoogleFonts.courierPrime(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Icon(
                                    Icons.access_time,
                                    color: CyberTheme.neonCyan,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Interval Selector
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Interval (minutes)',
                            style: CyberTheme.body().copyWith(
                              color: CyberTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              border: Border.all(
                                color: CyberTheme.neonCyan,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<int>(
                              value: _interval,
                              isExpanded: true,
                              dropdownColor: Colors.black,
                              style: GoogleFonts.courierPrime(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              underline: const SizedBox(),
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: CyberTheme.neonCyan,
                              ),
                              items: [5, 10, 15, 20, 30].map((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text('$value min'),
                                );
                              }).toList(),
                              onChanged: (int? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _interval = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Cheat Sheet
          CyberContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Time Mapping (Cheat Sheet)',
                  style: CyberTheme.headline().copyWith(fontSize: 16),
                ),
                const SizedBox(height: 16),
                _buildCheatSheet(),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Input Section
          CyberContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Plaintext',
                      style: CyberTheme.headline().copyWith(fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear, color: CyberTheme.neonCyan, size: 20),
                      onPressed: _onClear,
                      tooltip: 'Clear',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _encodeController,
                  style: GoogleFonts.courierPrime(
                    fontSize: 18,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter text to encode...',
                    hintStyle: GoogleFonts.courierPrime(
                      fontSize: 14,
                      color: CyberTheme.textSecondary,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.characters,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Output Section
          if (_encodeController.text.isNotEmpty) ...[
            CyberContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Encoded Times',
                        style: CyberTheme.headline().copyWith(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: CyberTheme.neonCyan),
                        onPressed: () {
                          final times = _encodeText(_encodeController.text);
                          _copyToClipboard(times);
                        },
                        tooltip: 'Copy',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SelectableText(
                    _encodeText(_encodeController.text),
                    style: GoogleFonts.courierPrime(
                      fontSize: 18,
                      color: Colors.white,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Settings Section (same as encode)
          CyberContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: CyberTheme.headline().copyWith(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start Time (A)',
                            style: CyberTheme.body().copyWith(
                              color: CyberTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _selectStartTime,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                border: Border.all(
                                  color: CyberTheme.neonCyan,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatTime(_startTime),
                                    style: GoogleFonts.courierPrime(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Icon(
                                    Icons.access_time,
                                    color: CyberTheme.neonCyan,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Interval (minutes)',
                            style: CyberTheme.body().copyWith(
                              color: CyberTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              border: Border.all(
                                color: CyberTheme.neonCyan,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<int>(
                              value: _interval,
                              isExpanded: true,
                              dropdownColor: Colors.black,
                              style: GoogleFonts.courierPrime(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              underline: const SizedBox(),
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: CyberTheme.neonCyan,
                              ),
                              items: [5, 10, 15, 20, 30].map((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text('$value min'),
                                );
                              }).toList(),
                              onChanged: (int? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _interval = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Add Time Section
          CyberContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Time',
                  style: CyberTheme.headline().copyWith(fontSize: 16),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _addDecodeTime(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                              color: CyberTheme.neonCyan,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                                color: CyberTheme.neonCyan,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'ADD TIME',
                                style: GoogleFonts.courierPrime(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: CyberTheme.neonCyan,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.clear, color: CyberTheme.neonCyan, size: 20),
                      onPressed: _onClear,
                      tooltip: 'Clear All',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Time List
          if (_decodeTimes.isNotEmpty) ...[
            CyberContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Time Sequence',
                        style: CyberTheme.headline().copyWith(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: CyberTheme.neonCyan),
                        onPressed: () => _copyToClipboard(_decodeTimes.join(', ')),
                        tooltip: 'Copy',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _decodeTimes.asMap().entries.map((entry) {
                      final index = entry.key;
                      final timeStr = entry.value;
                      final isValid = _isValidTime(timeStr, index);
                      return _buildTimeChip(timeStr, index, isValid);
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Decoded Result
            CyberContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Decoded Text',
                        style: CyberTheme.headline().copyWith(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: CyberTheme.neonCyan),
                        onPressed: _decodedText.isNotEmpty
                            ? () => _copyToClipboard(_decodedText)
                            : null,
                        tooltip: 'Copy',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      _decodedText.isEmpty ? 'No valid sequence' : _decodedText,
                      style: GoogleFonts.courierPrime(
                        fontSize: 20,
                        color: _decodedText.isEmpty
                            ? CyberTheme.textSecondary
                            : Colors.white,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCheatSheet() {
    final letters = List.generate(26, (index) => String.fromCharCode(65 + index));
    return Container(
      height: 300,
      child: ListView.builder(
        itemCount: letters.length,
        itemBuilder: (context, index) {
          final letter = letters[index];
          final time = _addMinutes(_startTime, index * _interval);
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: CyberTheme.neonCyan.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  letter,
                  style: GoogleFonts.courierPrime(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _formatTime(time),
                  style: GoogleFonts.courierPrime(
                    fontSize: 16,
                    color: Colors.yellow,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeChip(String timeStr, int index, bool isValid) {
    return GestureDetector(
      onTap: () => _removeDecodeTime(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isValid
              ? Colors.transparent
              : CyberTheme.error.withOpacity(0.2),
          border: Border.all(
            color: isValid
                ? CyberTheme.neonCyan
                : CyberTheme.error,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              timeStr,
              style: GoogleFonts.courierPrime(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isValid ? Colors.white : CyberTheme.error,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.close,
              size: 16,
              color: isValid ? CyberTheme.neonCyan : CyberTheme.error,
            ),
          ],
        ),
      ),
    );
  }

  String _encodeText(String text) {
    final upperText = text.toUpperCase();
    final times = <String>[];
    
    for (int i = 0; i < upperText.length; i++) {
      final char = upperText[i];
      if (char == ' ') {
        times.add(' ');
        continue;
      }
      if (char.codeUnitAt(0) >= 65 && char.codeUnitAt(0) <= 90) {
        final letterIndex = char.codeUnitAt(0) - 65;
        final time = _addMinutes(_startTime, letterIndex * _interval);
        times.add(_formatTime(time));
      }
    }
    
    return times.join(', ');
  }

  Future<void> _addDecodeTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _decodeTimes.isEmpty
          ? _startTime
          : _parseTime(_decodeTimes.last),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: CyberTheme.neonCyan,
              onPrimary: Colors.black,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _decodeTimes.add(_formatTime(picked));
        _updateDecodedText();
      });
    }
  }

  void _removeDecodeTime(int index) {
    setState(() {
      _decodeTimes.removeAt(index);
      _updateDecodedText();
    });
  }

  bool _isValidTime(String timeStr, int index) {
    final time = _parseTime(timeStr);
    final expectedTime = _addMinutes(_startTime, index * _interval);
    return _formatTime(time) == _formatTime(expectedTime);
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  void _updateDecodedText() {
    final buffer = StringBuffer();
    
    for (int i = 0; i < _decodeTimes.length; i++) {
      final timeStr = _decodeTimes[i];
      if (timeStr == ' ') {
        buffer.write(' ');
        continue;
      }
      
      final time = _parseTime(timeStr);
      final diffMinutes = _getMinutesDifference(_startTime, time);
      
      if (diffMinutes % _interval == 0) {
        final letterIndex = diffMinutes ~/ _interval;
        if (letterIndex >= 0 && letterIndex < 26) {
          buffer.write(String.fromCharCode(65 + letterIndex));
        }
      }
    }
    
    setState(() {
      _decodedText = buffer.toString();
    });
  }
}
