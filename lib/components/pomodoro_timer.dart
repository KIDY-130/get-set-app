import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class PomodoroTimer extends StatefulWidget {
  final String taskName;
  final VoidCallback onExit;
  final VoidCallback onComplete;

  const PomodoroTimer({
    super.key,
    required this.taskName,
    required this.onExit,
    required this.onComplete,
  });

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  int _minutes = 25;
  int _seconds = 0;
  int _pomodoroLength = 25;
  bool _isActive = false;
  bool _isBreak = false;
  int _completedPomodoros = 0;
  Timer? _timer;

  // 🔊 소리 관련 변수
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSoundOn = true;
  String _selectedSound = 'alarm_1.mp3';

  // 🎵 알람음 목록
  final Map<String, String> _soundList = {
    '기본 알람': 'alarm_1.mp3',
    //'디지털 알람': 'alarm_2.mp3',
    '부드러운 알람': 'alarm_3.mp3',
  };

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  // 알람 재생
  Future<void> _playAlarm() async {
    if (_isSoundOn) {
      try {
        await _audioPlayer.stop();
        await _audioPlayer.play(AssetSource('sounds/$_selectedSound'));
      } catch (e) {
        debugPrint("알람 재생 오류: $e");
      }
    }
  }

  void _startTimer() {
    if (_isActive) return;
    setState(() => _isActive = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        if (_minutes == 0) {
          timer.cancel();
          _playAlarm();

          setState(() {
            _isActive = false;
            if (_isBreak) {
              _isBreak = false;
              _minutes = _pomodoroLength;
            } else {
              _completedPomodoros++;
              _isBreak = true;
              _minutes = 5;
            }
          });
        } else {
          setState(() {
            _minutes--;
            _seconds = 59;
          });
        }
      } else {
        setState(() => _seconds--);
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isActive = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isActive = false;
      _minutes = _isBreak ? 5 : _pomodoroLength;
      _seconds = 0;
    });
  }

  void _skipToBreak() {
    _timer?.cancel();
    setState(() {
      _isActive = false;
      _isBreak = true;
      _minutes = 5;
      _seconds = 0;
      _completedPomodoros++;
    });
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(
                "🔔 알람 설정",
                style: TextStyle(color: Colors.purple[400]),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text("알람 소리 켜기"),
                    activeTrackColor: Colors.purple[400],
                    value: _isSoundOn,
                    onChanged: (value) {
                      setState(() => _isSoundOn = value);
                      setStateDialog(() {});
                    },
                  ),
                  if (_isSoundOn) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _selectedSound,
                      isExpanded: true,
                      items: _soundList.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.value,
                          child: Text(entry.key),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedSound = value);
                          setStateDialog(() {});

                          _audioPlayer.stop();
                          _audioPlayer.play(AssetSource('sounds/$value'));
                        }
                      },
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _audioPlayer.stop();
                    Navigator.pop(context);
                  },
                  child: const Text("확인", style: TextStyle(color: Colors.grey)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalSeconds = _isBreak ? 5 * 60 : _pomodoroLength * 60;
    final currentSeconds = _minutes * 60 + _seconds;
    final progress = totalSeconds == 0
        ? 0.0
        : 1.0 - (currentSeconds / totalSeconds);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFa18cd1), Color(0xFFfbc2eb)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: widget.onExit,
                      icon: const Icon(Icons.close),
                      label: const Text("나가기"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.grey,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: widget.onComplete,
                      icon: const Icon(Icons.check_circle),
                      label: const Text("완료하기"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[400],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _isBreak ? "☕ 휴식 시간" : "🎯 집중 시간",
                              style: TextStyle(
                                color: Colors.purple[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: Icon(
                              _isSoundOn
                                  ? Icons.notifications_active
                                  : Icons.notifications_off,
                              color: Colors.purple[200],
                              size: 20,
                            ),
                            onPressed: _showSettingsDialog,
                            tooltip: "알람 설정",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Text(
                      widget.taskName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "완료한 뽀모도로: $_completedPomodoros개",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),

                    LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 12,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _isBreak ? Colors.green[300]! : Colors.purple[300]!,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    const SizedBox(height: 24),

                    if (!_isBreak && !_isActive)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [25, 50]
                            .map(
                              (len) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: ChoiceChip(
                                  label: Text("$len분"),
                                  selected: _pomodoroLength == len,
                                  onSelected: (s) => setState(() {
                                    _pomodoroLength = len;
                                    _minutes = len;
                                    _seconds = 0;
                                  }),
                                ),
                              ),
                            )
                            .toList(),
                      ),

                    const SizedBox(height: 24),
                    Text(
                      "${_minutes.toString().padLeft(2, '0')}:${_seconds.toString().padLeft(2, '0')}",
                      style: TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: _isBreak
                            ? Colors.green[400]
                            : Colors.purple[400],
                      ),
                    ),
                    const SizedBox(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isActive ? _pauseTimer : _startTimer,
                          icon: Icon(
                            _isActive ? Icons.pause : Icons.play_arrow,
                          ),
                          label: Text(_isActive ? "일시정지" : "시작"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            backgroundColor: _isBreak
                                ? Colors.green[400]
                                : Colors.purple[400],
                            foregroundColor: Colors.white,
                          ),
                        ),
                        if (!_isBreak) ...[
                          const SizedBox(width: 16),
                          OutlinedButton.icon(
                            onPressed: _skipToBreak,
                            icon: const Icon(Icons.skip_next),
                            label: const Text("휴식"),
                          ),
                        ],
                      ],
                    ),
                    TextButton(
                      onPressed: _resetTimer,
                      child: const Text(
                        "리셋",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
