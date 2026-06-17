import 'package:flutter/material.dart';
import 'ready_screen.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  final Map<String, bool> _granted = {
    'mic': false,
    'contacts': false,
    'notifications': false,
    'accessibility': false,
  };

  final List<Map<String, dynamic>> _perms = [
    {'id': 'mic', 'icon': '🎤', 'title': 'الميكروفون', 'subtitle': 'ضروري للأوامر الصوتية', 'bg': Color(0xFF1e1838), 'required': true},
    {'id': 'contacts', 'icon': '📱', 'title': 'جهات الاتصال', 'subtitle': 'عشان يتصل بالناس بالاسم', 'bg': Color(0xFF1a2e1a), 'required': false},
    {'id': 'notifications', 'icon': '🔔', 'title': 'الإشعارات', 'subtitle': 'عشان يبعتلك ردود وتأكيدات', 'bg': Color(0xFF2a1e10), 'required': false},
    {'id': 'accessibility', 'icon': '♿', 'title': 'Accessibility Service', 'subtitle': 'للتحكم الكامل في التطبيقات', 'bg': Color(0xFF1e1e38), 'required': false},
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

  @override
  Widget build(BuildContext context) {
    final canContinue = _granted['mic'] == true;

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
                const Text('الخطوة 3 من 4',
                    style: TextStyle(color: Color(0xFF7c6ef7), fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: 0.75,
                    backgroundColor: const Color(0xFF1e1e32),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF7c6ef7)),
                    minHeight: 3,
                  ),
                ),
                const SizedBox(height: 28),
                const Text('الصلاحيات',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFf0f0f8))),
                const SizedBox(height: 6),
                const Text('عشان المساعد يقدر ينفذ الأوامر',
                    style: TextStyle(fontSize: 13, color: Color(0xFF555555))),
                const SizedBox(height: 20),
                ..._perms.map((perm) => GestureDetector(
                  onTap: () => setState(() => _granted[perm['id']] = !_granted[perm['id']]!),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF13131f),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF1e1e32)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: perm['bg'] as Color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(child: Text(perm['icon'], style: const TextStyle(fontSize: 20))),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(perm['title'],
                                      style: const TextStyle(color: Color(0xFFe0e0f0), fontSize: 14, fontWeight: FontWeight.w500)),
                                  if (perm['required'] == true) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1e1838),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text('مطلوب',
                                          style: TextStyle(color: Color(0xFF7c6ef7), fontSize: 10)),
                                    ),
                                  ],
                                ],
                              ),
                              Text(perm['subtitle'],
                                  style: const TextStyle(color: Color(0xFF555555), fontSize: 11)),
                            ],
                          ),
                        ),
                        Switch(
                          value: _granted[perm['id']] ?? false,
                          onChanged: (v) => setState(() => _granted[perm['id']] = v),
                          activeColor: const Color(0xFF7c6ef7),
                          inactiveTrackColor: const Color(0xFF222222),
                        ),
                      ],
                    ),
                  ),
                )),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1a1208),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF3a2a10)),
                  ),
                  child: const Row(
                    children: [
                      Text('🔒', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'كل الصلاحيات بتشتغل محليًا على موبايلك فقط.',
                          style: TextStyle(color: Color(0xFF997755), fontSize: 12, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!canContinue) ...[
                  const SizedBox(height: 8),
                  const Text('⚠️ الميكروفون مطلوب للمتابعة',
                      style: TextStyle(color: Color(0xFFf7a64c), fontSize: 12)),
                ],
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: canContinue
                        ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReadyScreen()))
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canContinue ? const Color(0xFF7c6ef7) : const Color(0xFF2a2a40),
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