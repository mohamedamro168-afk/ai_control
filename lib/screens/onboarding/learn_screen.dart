import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'permissions_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  final Set<String> _selected = {'calls', 'whatsapp', 'apps'};

  final List<Map<String, dynamic>> _tasks = [
    {'id': 'calls', 'icon': '📞', 'title': 'مكالمات', 'subtitle': 'اتصل بجهات الاتصال', 'bg': Color(0xFF1e3a2a), 'examples': ['اتصل بأحمد', 'كلم ماما']},
    {'id': 'whatsapp', 'icon': '💬', 'title': 'واتساب', 'subtitle': 'ابعت رسايل وفويس نوت', 'bg': Color(0xFF1a2e1a), 'examples': ['ابعت واتساب لماما', 'بعت رسالة لأحمد']},
    {'id': 'download', 'icon': '📥', 'title': 'تنزيل ملفات', 'subtitle': 'محاضرات، مستندات، صور', 'bg': Color(0xFF1a2038), 'examples': ['نزّل المحاضرة دي', 'احفظ الصورة دي']},
    {'id': 'alarm', 'icon': '⏰', 'title': 'المنبه', 'subtitle': 'ظبط وادارة التنبيهات', 'bg': Color(0xFF2a1e10), 'examples': ['حط منبه الساعة 7', 'فوّقني الساعة 8']},
    {'id': 'maps', 'icon': '📍', 'title': 'الخرائط', 'subtitle': 'ابحث عن أماكن قريبة', 'bg': Color(0xFF1e1e10), 'examples': ['فين أقرب مستشفى', 'دورني على كافيه']},
    {'id': 'apps', 'icon': '📱', 'title': 'فتح تطبيقات', 'subtitle': 'افتح أي تطبيق بصوتك', 'bg': Color(0xFF1e1030), 'examples': ['افتح يوتيوب', 'شغّل سبوتيفاي']},
    {'id': 'settings', 'icon': '⚙️', 'title': 'إعدادات الموبايل', 'subtitle': 'واي فاي، بلوتوث، صوت', 'bg': Color(0xFF1a1a28), 'examples': ['شغّل الواي فاي', 'هدّي الصوت']},
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  Future<void> _handleNext() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_tasks', jsonEncode(_selected.toList()));
    if (mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const PermissionsScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0f),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 56),
                const Text('الخطوة 2 من 4',
                    style: TextStyle(color: Color(0xFF7c6ef7), fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: 0.50,
                    backgroundColor: const Color(0xFF1e1e32),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF7c6ef7)),
                    minHeight: 3,
                  ),
                ),
                const SizedBox(height: 28),
                const Text('عايز تعلّمني إيه؟',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFf0f0f8))),
                const SizedBox(height: 6),
                const Text('اختار المهام اللي بتعملها كتير',
                    style: TextStyle(fontSize: 13, color: Color(0xFF555555))),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, i) {
                      final task = _tasks[i];
                      final isSelected = _selected.contains(task['id']);
                      return GestureDetector(
                        onTap: () => _toggle(task['id']),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF1a1830) : const Color(0xFF13131f),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF7c6ef7) : const Color(0xFF1e1e32),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: task['bg'] as Color,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(child: Text(task['icon'], style: const TextStyle(fontSize: 20))),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(task['title'],
                                        style: const TextStyle(color: Color(0xFFe0e0f0), fontSize: 14, fontWeight: FontWeight.w600)),
                                    Text(task['subtitle'],
                                        style: const TextStyle(color: Color(0xFF666666), fontSize: 12)),
                                    if (isSelected) ...[
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 4,
                                        children: (task['examples'] as List<String>).map((ex) => Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1e1840),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text('"$ex"',
                                              style: const TextStyle(color: Color(0xFF9090c8), fontSize: 11)),
                                        )).toList(),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Container(
                                width: 22, height: 22,
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF7c6ef7) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(11),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF7c6ef7) : const Color(0xFF333333),
                                    width: 1.5,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text('${_selected.length} مهمة مختارة',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF666666), fontSize: 12)),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selected.isEmpty ? null : _handleNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selected.isEmpty ? const Color(0xFF2a2a40) : const Color(0xFF7c6ef7),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('التالي ←',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}