import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;
  String _command = '';
  String _userName = 'صديقي';
  String _response = '';
  List<Contact> _contacts = [];

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  final Map<String, String> _apps = {
    'يوتيوب': 'com.google.android.youtube',
    'youtube': 'com.google.android.youtube',
    'واتساب': 'com.whatsapp',
    'واتس': 'com.whatsapp',
    'whatsapp': 'com.whatsapp',
    'فيسبوك': 'com.facebook.katana',
    'facebook': 'com.facebook.katana',
    'انستجرام': 'com.instagram.android',
    'instagram': 'com.instagram.android',
    'تيك توك': 'com.zhiliaoapp.musically',
    'tiktok': 'com.zhiliaoapp.musically',
    'تيليجرام': 'org.telegram.messenger',
    'تلغرام': 'org.telegram.messenger',
    'telegram': 'org.telegram.messenger',
    'سناب': 'com.snapchat.android',
    'snapchat': 'com.snapchat.android',
    'تويتر': 'com.twitter.android',
    'twitter': 'com.twitter.android',
    'اكس': 'com.twitter.android',
    'سبوتيفاي': 'com.spotify.music',
    'spotify': 'com.spotify.music',
    'نتفليكس': 'com.netflix.mediaclient',
    'netflix': 'com.netflix.mediaclient',
    'كروم': 'com.android.chrome',
    'chrome': 'com.android.chrome',
    'جيميل': 'com.google.android.gm',
    'gmail': 'com.google.android.gm',
    'خرائط': 'com.google.android.apps.maps',
    'maps': 'com.google.android.apps.maps',
    'كاميرا': 'com.android.camera2',
    'camera': 'com.android.camera2',
    'إعدادات': 'com.android.settings',
    'اعدادات': 'com.android.settings',
    'settings': 'com.android.settings',
    'حاسبة': 'com.android.calculator2',
    'calculator': 'com.android.calculator2',
    'ساعة': 'com.android.deskclock',
    'clock': 'com.android.deskclock',
    'كلود': 'com.anthropic.claude',
    'claude': 'com.anthropic.claude',
    'شات جي بي تي': 'com.openai.chatgpt',
    'chatgpt': 'com.openai.chatgpt',
    'زووم': 'us.zoom.videomeetings',
    'zoom': 'us.zoom.videomeetings',
  };

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _initSpeech();
    _loadUserName();
    _loadContacts();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _requestPermissions() async {
    await Permission.phone.request();
    await Permission.contacts.request();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize();
    setState(() {});
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _userName = prefs.getString('user_name') ?? 'صديقي');
  }

  Future<void> _loadContacts() async {
    final status = await Permission.contacts.request();
    if (!status.isGranted) {
      setState(() => _response = 'محتاج صلاحية جهات الاتصال');
      return;
    }
    final contacts = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: false,
    );
    setState(() => _contacts = contacts);
  }

  static const Map<String, List<String>> _arToEn = {
    'أحمد': ['ahmed', 'ahmad'],
    'احمد': ['ahmed', 'ahmad'],
    'محمد': ['mohamed', 'mohammed', 'muhammad', 'mohammad'],
    'مهند': ['mohannad', 'muhannad'],
    'خالد': ['khaled', 'khalid'],
    'عمر': ['omar', 'omer', 'umar'],
    'علي': ['ali'],
    'حسن': ['hassan', 'hasan'],
    'حسين': ['hussein', 'husain', 'hussain'],
    'يوسف': ['yousef', 'youssef', 'yusuf', 'joseph'],
    'إبراهيم': ['ibrahim', 'abraham'],
    'ابراهيم': ['ibrahim', 'abraham'],
    'عبدالله': ['abdullah', 'abdallah'],
    'عبد الله': ['abdullah', 'abdallah'],
    'عبدالرحمن': ['abdulrahman', 'abdelrahman'],
    'عبد الرحمن': ['abdulrahman', 'abdelrahman'],
    'سعيد': ['saeed', 'said', 'saied'],
    'سعد': ['saad', 'sad'],
    'ياسر': ['yasser', 'yasir'],
    'ياسين': ['yassin', 'yassine', 'yaseen'],
    'طارق': ['tarek', 'tariq'],
    'كريم': ['karim', 'kareem'],
    'وليد': ['walid', 'waled'],
    'هاني': ['hany', 'hani'],
    'سامي': ['sami', 'sammy'],
    'رامي': ['rami', 'ramy'],
    'مازن': ['mazen', 'mazin'],
    'ماهر': ['maher', 'mahir'],
    'نادر': ['nader', 'nadir'],
    'هشام': ['hesham', 'hisham'],
    'وائل': ['wael', 'wail'],
    'عماد': ['emad', 'imad'],
    'أيمن': ['ayman'],
    'ايمن': ['ayman'],
    'مصطفى': ['mostafa', 'mustafa', 'moustafa'],
    'مصطفي': ['mostafa', 'mustafa', 'moustafa'],
    'إسلام': ['islam'],
    'اسلام': ['islam'],
    'شريف': ['sherif', 'sharif'],
    'أشرف': ['ashraf'],
    'اشرف': ['ashraf'],
    'عادل': ['adel', 'adil'],
    'جمال': ['gamal', 'jamal'],
    'فتحي': ['fathy', 'fathi'],
    'حمزة': ['hamza', 'hamzah'],
    'بلال': ['bilal', 'belal'],
    'زياد': ['ziad', 'ziyad'],
    'رضا': ['reda', 'rida', 'reza'],
    'منى': ['mona', 'muna'],
    'منة': ['menna', 'mona'],
    'نور': ['nour', 'nur', 'noor'],
    'سارة': ['sara', 'sarah'],
    'مريم': ['mariam', 'maryam', 'mary'],
    'فاطمة': ['fatima', 'fatma', 'fatema'],
    'هبة': ['heba', 'hiba'],
    'رنا': ['rana'],
    'ريم': ['reem', 'rim'],
    'دينا': ['dina', 'deena'],
    'سمر': ['samar'],
    'نهى': ['noha'],
    'إيمان': ['iman', 'eman'],
    'ايمان': ['iman', 'eman'],
    'أميرة': ['amira', 'ameera'],
    'اميرة': ['amira', 'ameera'],
    'شيماء': ['shaimaa', 'shimaa'],
    'ولاء': ['walaa', 'wala'],
    'إسراء': ['esraa', 'israa'],
    'اسراء': ['esraa', 'israa'],
    'يارا': ['yara'],
    'لينا': ['lina', 'leena'],
    'نادية': ['nadia'],
    'عبير': ['abeer', 'abir'],
    'رحمة': ['rahma'],
    'أسماء': ['asmaa', 'asma'],
    'اسماء': ['asmaa', 'asma'],
    'ياسمين': ['yasmine', 'jasmine', 'yasmeen'],
    'ناديا': ['nadia'],
    'مي': ['may', 'mai'],
    'غادة': ['ghada'],
    'كريمة': ['karima'],
    'سوسن': ['sawsan'],
    'حنان': ['hanan'],
    'إنجي': ['engy', 'ingy'],
    'انجي': ['engy', 'ingy'],
    'ماما': ['mama', 'mom', 'mother', 'mum'],
    'بابا': ['baba', 'dad', 'father', 'papa'],
    'جدو': ['gedo', 'grandpa'],
    'تيتا': ['teta', 'grandma'],
    'عمو': ['amo', 'uncle'],
    'طنط': ['tante', 'aunt'],
  };

  // ===== توحيد شكل الحروف العربية (تشكيل/همزات/تاء مربوطة) قبل أي مقارنة =====
  String _normalizeArabic(String input) {
    String s = input.trim().toLowerCase();
    // شيل التشكيل
    s = s.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');
    // شيل التطويل
    s = s.replaceAll('\u0640', '');
    // وحّد كل أشكال الألف
    s = s.replaceAll(RegExp(r'[إأآا]'), 'ا');
    // وحّد الياء
    s = s.replaceAll('ى', 'ي');
    // وحّد الهمزات على الواو/الياء
    s = s.replaceAll('ؤ', 'و');
    s = s.replaceAll('ئ', 'ي');
    // التاء المربوطة زي الهاء
    s = s.replaceAll('ة', 'ه');
    // مسافات زيادة
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }

  // ===== بدائل الاسم (عربي/إنجليزي) بعد التوحيد — مطابقة تامة فقط، من غير contains =====
  Set<String> _getVariants(String word) {
    final lower = _normalizeArabic(word);
    final variants = <String>{lower};
    for (final entry in _arToEn.entries) {
      final key = _normalizeArabic(entry.key);
      if (key == lower) {
        variants.addAll(entry.value);
      }
      for (final en in entry.value) {
        if (en == lower) {
          variants.add(key);
          variants.addAll(entry.value);
        }
      }
    }
    return variants;
  }

  List<String> _splitWords(String normalized) {
    return normalized
        .split(RegExp(r'[\s,._\-]+'))
        .where((w) => w.length >= 2)
        .toList();
  }

  // ===== استخراج الاسم من أمر المكالمة =====
  String _extractCallName(String cmd) {
    String name = cmd;

    final patterns = [
      RegExp(r'اتصل\s*بـ'),
      RegExp(r'اتصل\s*ب'),
      RegExp(r'اتصل'),
      RegExp(r'رن\s*على\s*'),
      RegExp(r'رن\s*ع\s*'),
      RegExp(r'رن\s*'),
      RegExp(r'كلم\s*'),
      RegExp(r'\bcall\b', caseSensitive: false),
    ];

    for (final p in patterns) {
      name = name.replaceAll(p, '');
    }

    name = name.trim();
    final extraWords = ['على', 'علي', 'ب', 'لـ', 'ل'];
    for (final w in extraWords) {
      if (name.startsWith('$w ') || name == w) {
        name = name.substring(w.length).trim();
      }
    }

    return name.trim();
  }

  // ===== البحث في جهات الاتصال بنظام أولويات واضح =====
  // أولوية 0: تطابق تام للاسم بالكامل
  // أولوية 1: نفس عدد الكلمات بالظبط + كل كلمة مطابقة لكلمة مختلفة في اسم الجهة
  // أولوية 2: اسم الجهة فيه كل كلماتك + كلمات زيادة (الأقرب أولًا)
  List<Contact> _findContacts(String name) {
    if (_contacts.isEmpty || name.isEmpty) return [];

    final normalizedQuery = _normalizeArabic(name);
    final queryWords = _splitWords(normalizedQuery);
    if (queryWords.isEmpty) return [];

    final List<Set<String>> queryVariants =
    queryWords.map((w) => _getVariants(w)).toList();

    final List<Contact> exactFull = [];
    final List<Contact> sameLength = [];
    final List<Contact> superset = [];

    for (final c in _contacts) {
      if (c.phones.isEmpty) continue;
      final normalizedDisplay = _normalizeArabic(c.displayName);
      if (normalizedDisplay.isEmpty) continue;

      if (normalizedDisplay == normalizedQuery) {
        exactFull.add(c);
        continue;
      }

      final displayWords = _splitWords(normalizedDisplay);
      if (displayWords.isEmpty) continue;

      // كل كلمة في طلبك لازم تتطابق مع كلمة مختلفة في اسم الجهة (مش نفس الكلمة مرتين)
      final usedIndices = <int>{};
      bool allFound = true;
      for (final variants in queryVariants) {
        int? matchIndex;
        for (int i = 0; i < displayWords.length; i++) {
          if (usedIndices.contains(i)) continue;
          if (variants.contains(displayWords[i])) {
            matchIndex = i;
            break;
          }
        }
        if (matchIndex == null) {
          allFound = false;
          break;
        }
        usedIndices.add(matchIndex);
      }

      if (!allFound) continue;

      if (displayWords.length == queryWords.length) {
        sameLength.add(c);
      } else {
        superset.add(c);
      }
    }

    if (exactFull.isNotEmpty) return exactFull;
    if (sameLength.isNotEmpty) return sameLength;
    if (superset.isNotEmpty) {
      superset.sort((a, b) {
        final aw = _splitWords(_normalizeArabic(a.displayName)).length;
        final bw = _splitWords(_normalizeArabic(b.displayName)).length;
        return aw.compareTo(bw);
      });
      return superset;
    }

    // آخر حل: لكلمة واحدة بس، مطابقة جزئية (contains) كـ fallback أخير
    if (queryWords.length == 1) {
      final variants = queryVariants.first;
      final List<Contact> partial = [];
      for (final c in _contacts) {
        if (c.phones.isEmpty) continue;
        final displayWords =
        _splitWords(_normalizeArabic(c.displayName));
        for (final v in variants) {
          if (v.length < 2) continue;
          bool matched = false;
          for (final dw in displayWords) {
            if (dw.contains(v) || v.contains(dw)) {
              matched = true;
              break;
            }
          }
          if (matched) {
            partial.add(c);
            break;
          }
        }
      }
      return partial;
    }

    return [];
  }

  // ===== اختيار أفضل جهة اتصال من نتايج متعددة بنفس الأولوية =====
  Contact? _pickBestContact(List<Contact> contacts, String searchName) {
    if (contacts.isEmpty) return null;
    if (contacts.length == 1) return contacts.first;

    final queryWordCount =
        _splitWords(_normalizeArabic(searchName)).length;

    int wordCountOf(Contact c) =>
        _splitWords(_normalizeArabic(c.displayName)).length;

    final topCount = wordCountOf(contacts[0]);
    final secondCount = wordCountOf(contacts[1]);

    // لو الأول مطابق بالظبط لعدد كلماتك والثاني لأ -> الأول هو المقصود
    if (topCount == queryWordCount && secondCount != queryWordCount) {
      return contacts[0];
    }
    // لو الأول أقرب (كلمات زيادة أقل) من الثاني -> الأول هو المقصود
    if (topCount < secondCount) {
      return contacts[0];
    }

    // نفس القرب بالظبط -> ده تشابه حقيقي، سيب المستخدم يختار
    return null;
  }

  Future<void> _callNumber(String number, String displayName) async {
    final clean = number.replaceAll(RegExp(r'[\s\-()]'), '');
    final status = await Permission.phone.status;
    if (!status.isGranted) {
      final result = await Permission.phone.request();
      if (!result.isGranted) {
        setState(() => _response = 'محتاج صلاحية الاتصال');
        return;
      }
    }
    try {
      bool? called = await FlutterPhoneDirectCaller.callNumber(clean);
      setState(() {
        _response = called == true
            ? 'جاري الاتصال بـ $displayName 📞'
            : 'فشل الاتصال بـ $displayName';
      });
    } catch (e) {
      setState(() => _response = 'خطأ أثناء الاتصال: $e');
    }
  }

  Future<void> _sendWhatsApp(
      String number, String displayName, String message) async {
    String clean = number.replaceAll(RegExp(r'[\s\-\+\(\)]'), '');
    if (clean.startsWith('0')) clean = '2$clean';
    if (!clean.startsWith('20') && clean.length <= 11) clean = '2$clean';

    try {
      var request = http.Request(
        'POST',
        Uri.parse('https://api.ultramsg.com/instance180765/messages/chat'),
      );
      request.bodyFields = {
        'token': 'n1cpcptb19kpflnr',
        'to': '+$clean',
        'body': message,
      };
      request.headers
          .addAll({'Content-Type': 'application/x-www-form-urlencoded'});

      final response = await request.send();
      if (response.statusCode == 200) {
        setState(() => _response = 'الرسالة اتبعتت لـ $displayName ✅');
      } else {
        setState(
                () => _response = 'فشل الإرسال ❌\n${response.reasonPhrase}');
      }
    } catch (e) {
      setState(() => _response = 'خطأ: $e');
    }
  }

  Future<void> _showWhatsAppContactPicker(
      List<Contact> contacts, String message) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF13131f),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'في أكتر من شخص بالاسم ده 🤔\nتبعت لمين؟',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFf0f0f8), fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: contacts.map((c) {
            final number = c.phones.first.number;
            return GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                _sendWhatsApp(number, c.displayName, message);
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 10),
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1e1e32),
                  borderRadius: BorderRadius.circular(12),
                  border:
                  Border.all(color: const Color(0xFF7c6ef7), width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.displayName,
                        style: const TextStyle(
                            color: Color(0xFFf0f0f8),
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(number,
                        style: const TextStyle(
                            color: Color(0xFF7c6ef7), fontSize: 13)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء',
                style: TextStyle(color: Color(0xFF666666))),
          ),
        ],
      ),
    );
  }

  Future<void> _showContactPicker(List<Contact> contacts) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF13131f),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'في أكتر من شخص بالاسم ده 🤔\nتتصل بمين؟',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFf0f0f8), fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: contacts.map((c) {
            final number = c.phones.first.number;
            return GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                _callNumber(number, c.displayName);
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 10),
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1e1e32),
                  borderRadius: BorderRadius.circular(12),
                  border:
                  Border.all(color: const Color(0xFF7c6ef7), width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.displayName,
                        style: const TextStyle(
                            color: Color(0xFFf0f0f8),
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(number,
                        style: const TextStyle(
                            color: Color(0xFF7c6ef7), fontSize: 13)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء',
                style: TextStyle(color: Color(0xFF666666))),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) {
      setState(() => _response = 'الميكروفون مش متاح!');
      return;
    }
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() {
        _isListening = true;
        _command = '';
        _response = 'بسمعك...';
      });
      await _speech.listen(
        onResult: (result) {
          setState(() => _command = result.recognizedWords);
          if (result.finalResult && _command.isNotEmpty) {
            _processCommand(_command);
          }
        },
        localeId: 'ar_EG',
      );
    }
  }

  Future<void> _setAlarm(int hour, int minute) async {
    try {
      final intent = AndroidIntent(
        action: 'android.intent.action.SET_ALARM',
        arguments: <String, dynamic>{
          'android.intent.extra.alarm.HOUR': hour,
          'android.intent.extra.alarm.MINUTES': minute,
          'android.intent.extra.alarm.MESSAGE': 'AI Control',
          'android.intent.extra.alarm.SKIP_UI': false,
        },
      );
      await intent.launch();
      setState(() {
        _response =
        'تم فتح إعداد المنبه على ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      });
    } catch (e) {
      setState(() => _response = 'فشل ضبط المنبه: $e');
    }
  }

  Map<String, String> _parseWhatsAppCommand(String cmd) {
    String cleaned = cmd
        .replaceAll(RegExp(r'ابعت|بعت|ارسل'), '')
        .replaceAll(RegExp(r'واتساب|whatsapp'), '')
        .replaceAll(RegExp(r'\bعلى\b|\bعلي\b'), '')
        .replaceAll(RegExp(r'\bلـ\b|\bل\b'), '')
        .trim();

    final msgKeywords = RegExp(r'رسالة|message|msg|قوله|قولها|قولهم');
    final msgMatch = msgKeywords.firstMatch(cleaned);

    if (msgMatch != null) {
      final personName = cleaned.substring(0, msgMatch.start).trim();
      final messageText = cleaned.substring(msgMatch.end).trim();
      return {'name': personName, 'message': messageText};
    }

    final parts = cleaned.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      final personName = parts.first.trim();
      final messageText = parts.skip(1).join(' ').trim();
      return {'name': personName, 'message': messageText};
    }

    return {'name': cleaned, 'message': ''};
  }

  Future<void> _processCommand(String command) async {
    setState(() => _isListening = false);
    final cmd = command.trim();
    final cmdLower = cmd.toLowerCase();

    // ===== مكالمة =====
    if (cmdLower.contains('اتصل') ||
        cmdLower.contains('كلم') ||
        cmdLower.contains('رن') ||
        cmdLower.contains('call')) {
      final name = _extractCallName(cmd);

      if (name.isEmpty) {
        setState(() => _response = 'قولي تتصل بمين؟ 🤔');
        return;
      }

      final matches = _findContacts(name);
      if (matches.isEmpty) {
        setState(() => _response =
        'مش لاقي "$name" في جهات الاتصال 😔\nعندك ${_contacts.length} جهة اتصال');
        return;
      }

      if (matches.length == 1) {
        await _callNumber(
            matches.first.phones.first.number, matches.first.displayName);
        return;
      }

      final best = _pickBestContact(matches, name);
      if (best != null) {
        await _callNumber(best.phones.first.number, best.displayName);
        return;
      }

      setState(() => _response = 'لقيت ${matches.length} أشخاص بالاسم ده...');
      await _showContactPicker(matches);
      return;
    }

    // ===== واتساب =====
    final hasWhatsApp =
        cmdLower.contains('واتساب') || cmdLower.contains('whatsapp');
    final hasSend = cmdLower.contains('ابعت') ||
        cmdLower.contains('بعت') ||
        cmdLower.contains('ارسل');

    if (hasSend) {
      final parsed = _parseWhatsAppCommand(cmd);
      final personName = parsed['name'] ?? '';
      final message = parsed['message'] ?? '';

      if (personName.isEmpty || message.isEmpty) {
        await _openApp('com.whatsapp', 'واتساب');
        return;
      }

      final matches = _findContacts(personName);
      if (matches.isEmpty) {
        setState(() => _response =
        'مش لاقي "$personName" في جهات الاتصال 😔\nعندك ${_contacts.length} جهة اتصال');
        return;
      }

      if (matches.length == 1) {
        await _sendWhatsApp(matches.first.phones.first.number,
            matches.first.displayName, message);
        return;
      }

      final best = _pickBestContact(matches, personName);
      if (best != null) {
        await _sendWhatsApp(best.phones.first.number, best.displayName, message);
        return;
      }

      setState(() => _response = 'لقيت ${matches.length} أشخاص بالاسم ده...');
      await _showWhatsAppContactPicker(matches, message);
      return;
    }

    if (hasWhatsApp) {
      await _openApp('com.whatsapp', 'واتساب');
      return;
    }

    // ===== منبه =====
    if (cmdLower.contains('منبه') ||
        cmdLower.contains('نبهني') ||
        cmdLower.contains('فوقني') ||
        cmdLower.contains('alarm')) {
      final timeRegex = RegExp(
        r'(\d{1,2})(?:[:\s](\d{1,2}))?\s*(صباح|ص|مساء|م|am|pm)?',
        caseSensitive: false,
      );
      final match = timeRegex.firstMatch(cmd);
      if (match != null) {
        int hour = int.parse(match.group(1)!);
        int minute = 0;
        if ((match.group(2) ?? '').isNotEmpty)
          minute = int.parse(match.group(2)!);
        final period = (match.group(3) ?? '').toLowerCase();
        if (period.contains('pm') ||
            period == 'م' ||
            period.contains('مساء')) {
          if (hour < 12) hour += 12;
        }
        if (period.contains('am') ||
            period == 'ص' ||
            period.contains('صباح')) {
          if (hour == 12) hour = 0;
        }
        if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
          await _setAlarm(hour, minute);
        } else {
          setState(() => _response = 'الوقت غير صحيح');
        }
      } else {
        setState(() =>
        _response = 'مثال: منبه الساعة 7 صباحًا أو منبه 9:30 مساءً');
      }
      return;
    }

    // ===== فتح تطبيق =====
    for (final app in _apps.entries) {
      if (cmdLower.contains(app.key)) {
        await _openApp(app.value, app.key);
        return;
      }
    }

    // ===== بحث =====
    if (cmdLower.contains('ابحث') ||
        cmdLower.contains('دور') ||
        cmdLower.contains('سرش') ||
        cmdLower.contains('search')) {
      String query = cmd
          .replaceAll(RegExp(r'ابحث عن|ابحث|دور على|دور|سرش|search'), '')
          .trim();
      if (query.isEmpty) query = cmd;
      try {
        await launchUrl(
            Uri.parse(
                'https://www.google.com/search?q=${Uri.encodeComponent(query)}'),
            mode: LaunchMode.externalApplication);
        setState(() => _response = 'بدور على: $query 🔍');
      } catch (_) {
        setState(() => _response = 'مش قادر أفتح البراوزر');
      }
      return;
    }

    setState(() => _response =
    'مش فاهم الأمر، جرب تاني 🤔\nمثال: "افتح واتساب" أو "اتصل بأحمد"');
  }

  Future<void> _openApp(String package, String name) async {
    try {
      final uri = Uri.parse(
          'intent://#Intent;package=$package;action=android.intent.action.MAIN;category=android.intent.category.LAUNCHER;end');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      setState(() => _response = 'فتحت $name ✅');
      return;
    } catch (_) {}
    try {
      final uri = Uri.parse('market://launch?id=$package');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      setState(() => _response = 'فتحت $name ✅');
      return;
    } catch (_) {}
    try {
      await launchUrl(
          Uri.parse(
              'https://play.google.com/store/apps/details?id=$package'),
          mode: LaunchMode.externalApplication);
      setState(() => _response = '$name مش منصوب — فتحت المتجر 🏪');
    } catch (_) {
      setState(() => _response = 'مش قادر أفتح $name');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0f),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مرحبًا، $_userName 👋',
                        style: const TextStyle(
                          color: Color(0xFFf0f0f8),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_contacts.length} جهة اتصال',
                        style: const TextStyle(
                            color: Color(0xFF666666), fontSize: 12),
                      ),
                    ],
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF13131f),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1e1e32)),
                    ),
                    child: const Icon(Icons.settings,
                        color: Color(0xFF7c6ef7), size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF13131f),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isListening
                        ? const Color(0xFF7c6ef7)
                        : const Color(0xFF1e1e32),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _command.isEmpty
                          ? 'اضغط على الميكروفون وتكلم...'
                          : _command,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _command.isEmpty
                            ? const Color(0xFF444444)
                            : const Color(0xFFf0f0f8),
                        fontSize: 18,
                        height: 1.5,
                      ),
                    ),
                    if (_response.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFF1e1e32)),
                      const SizedBox(height: 12),
                      Text(
                        _response,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Color(0xFF7c6ef7), fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _toggleListening,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isListening ? _pulseAnim.value : 1.0,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: _isListening
                              ? const Color(0xFFe74c3c)
                              : const Color(0xFF7c6ef7),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7c6ef7).withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isListening ? Icons.stop : Icons.mic,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isListening ? 'اضغط لوقف الاستماع' : 'اضغط للتكلم',
                style:
                const TextStyle(color: Color(0xFF666666), fontSize: 13),
              ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    '"افتح واتساب"',
                    '"اتصل بأحمد"',
                    '"ابعت أحمد رسالة أهلاً"',
                    '"منبه الساعة 7"',
                  ]
                      .map((cmd) => GestureDetector(
                    onTap: () =>
                        _processCommand(cmd.replaceAll('"', '')),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF13131f),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFF2a2a40)),
                      ),
                      child: Text(
                        cmd,
                        style: const TextStyle(
                            color: Color(0xFF9090b8), fontSize: 12),
                      ),
                    ),
                  ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}