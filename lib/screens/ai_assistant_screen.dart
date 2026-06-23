import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../utils/language_provider.dart';

class Message {
  final String text;
  final bool isUser;
  Message(this.text, this.isUser);
}

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lang = Provider.of<LanguageProvider>(context, listen: false);
      _addBotMessage(_getWelcomeMessage(lang.currentLang));
    });
  }

  String _getWelcomeMessage(String lang) {
    switch (lang) {
      case 'am': return "ሰላም! እኔ የሲዳማ ዌይ ጎ AI ረዳት ነኝ። ስለ አውቶቡሶች፣ ታክሲዎች፣ ሆቴሎች ወይም በሀዋሳ ስላለ ማንኛውም ነገር ይጠይቁኝ!";
      case 'sid': return "Selam! SIDAMA WAY GO AI Aananchoho. Busete, taaksite, hotelu woy Hawaas daggino xallara xa'manna dandiitto!";
      default: return "Selam! I'm your SIDAMA WAY GO AI Assistant. Ask me about buses, taxis, hotels, or anything in Hawassa!";
    }
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.insert(0, Message(text, false));
    });
    _speak(text);
  }

  Future<void> _speak(String text) async {
    final lang = Provider.of<LanguageProvider>(context, listen: false).currentLang;
    String ttsLang = "en-US";
    if (lang == 'am') ttsLang = "am-ET";
    // Check if am-ET is supported, else fallback to en-US for safety
    // For SID, fallback to en-US
    await _flutterTts.setLanguage(ttsLang);
    await _flutterTts.speak(text);
  }

  void _handleSend() {
    if (_controller.text.isEmpty) return;
    final userText = _controller.text;
    setState(() {
      _messages.insert(0, Message(userText, true));
      _controller.clear();
    });

    final lang = Provider.of<LanguageProvider>(context, listen: false).currentLang;
    final response = _getAIResponse(userText, lang);
    _addBotMessage(response);
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        final lang = Provider.of<LanguageProvider>(context, listen: false).currentLang;
        String locale = "en_US";
        if (lang == 'am') locale = "am_ET";

        _speech.listen(
          onResult: (val) => setState(() {
            _controller.text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              // auto send if final? user might prefer manual
            }
          }),
          localeId: locale,
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  String _getAIResponse(String query, String langCode) {
    final q = query.toLowerCase();

    Map<String, String> responses;

    if (q.contains("id") || q.contains("card") || q.contains("መታወቂያ") || q.contains("kaarde")) {
      responses = {
        'en': "Your Smart City Digital ID is available in the Digital ID section of the home screen. It acts as your municipal residency card.",
        'am': "የእርስዎ ስማርት ሲቲ ዲጂታል መታወቂያ በዋናው ገጽ ላይ ባለው 'Digital ID' ክፍል ይገኛል። እንደ ከተማው ነዋሪነት ካርድ ያገለግላል።",
        'sid': "Simaarte Katama Deejitaale ID-ne mine skrine aana noo 'Digital ID' qixxaawo giddo afidhanno. Kunni katamu residentete kaardeeti.",
      };
    } else if (q.contains("report") || q.contains("problem") || q.contains("ሪፖርት") || q.contains("sokka")) {
      responses = {
        'en': "You can report city issues like road damage or waste problems using the 'City Report' tool on the home screen.",
        'am': "የመንገድ ብልሽት ወይም የቆሻሻ ችግሮችን በዋናው ገጽ ላይ ባለው 'City Report' መሣሪያ በመጠቀም ማሳወቅ ይችላሉ።",
        'sid': "Doogote ogoro woy koshshu rakkooba mine skrine aana noo 'City Report' qixxaancho horoonsidhe sokka dandiitto.",
      };
    } else if (q.contains("wallet") || q.contains("pay") || q.contains("ክፍያ") || q.contains("kaffala")) {
      responses = {
        'en': "The City Wallet allows you to pay for taxis, buses, and hotels using Telebirr, CBE Birr, or Chapa.",
        'am': "የከተማው ቦርሳ (City Wallet) በቴሌብር፣ በሲቢኢ ብር ወይም በቻፓ በመጠቀም ለታክሲ፣ ለአውቶቡስ እና ለሆቴሎች እንዲከፍሉ ያስችልዎታል።",
        'sid': "Katamu Boorsa (City Wallet) Telebirrenni, CBE Birrenni woy Chapa horoonsidhe taaksite, busete nna hotelubba kaffalate kaa'lanno.",
      };
    } else if (q.contains("bus") || q.contains("ticket") || q.contains("አውቶቡስ") || q.contains("otoobusi")) {
      responses = {
        'en': "I can help you book a bus ticket! Go to Bus Terminal, select Old or New Terminal, choose your route (Hawassa to Addis Ababa, Shashamane, Dilla, etc), pick a bus and seat, then pay via Telebirr or CBE Birr.",
        'am': "የአውቶቡስ ቲኬት እንዲይዙ መርዳት እችላለሁ! ወደ አውቶቡስ ተርሚናል ይሂዱ፣ አሮጌውን ወይም አዲሱን ተርሚናል ይምረጡ፣ መስመርዎን ይምረጡ (ከሀዋሳ ወደ አዲስ አበባ፣ ሻሸመኔ፣ ዲላ ወዘተ)፣ አውቶቡስ እና መቀመጫ ይምረጡ፣ ከዚያ በቴሌብር ወይም በሲቢኢ ብር ይክፈሉ።",
        'sid': "Busete tikete qixxeessate kaa'lotto! Busete terminaale ha\'ri, hunsicho woy haaricho terminaale doori, doogote ogoro (Hawaasi Addis Ababara, Shashemenera, Dillara, w.k.l) doori, busenna maccishsho doori, hakkiinni Telebirrenni woy CBE Birrenni kaffali.",
      };
    } else if (q.contains("taxi") || q.contains("ታክሲ") || q.contains("taaksii")) {
      responses = {
        'en': "For city taxi, go to City Taxi section. Routes include Piassa, Menaharia, Tabor, Gudumale and more, with fares from 6-15 ETB.",
        'am': "ለከተማ ታክሲ ወደ የከተማ ታክሲ ክፍል ይሂዱ። መስመሮች ፒያሳ፣ መናኸሪያ፣ ታቦር፣ ጉዱማሌ እና ሌሎችንም ያካትታሉ፣ ከ6-15 ብር ዋጋ ጋር።",
        'sid': "Katama taaksii hasi\'rattoha irose, Katama Taaksii qixxaawo ha\'ri. Doogote ogoro Piassa, Menaharia, Tabor, Gudumale nna wolootta daggino, waagi 6-15 ETB hee\'runni.",
      };
    } else if (q.contains("hotel") || q.contains("ሆቴል") || q.contains("hotel")) {
      responses = {
        'en': "You can search hotels in the Hotel section. Haile Resort and Lewi Hotel are popular options near Lake Hawassa.",
        'am': "በሆቴል ክፍል ውስጥ ሆቴሎችን መፈለግ ይችላሉ። ሀይሌ ሪዞርት እና ሌዊ ሆቴል በሀዋሳ ሐይቅ አቅራቢያ ተወዳጅ አማራጮች ናቸው።",
        'sid': "Hotelubba Hotelu qixxaawo giddo hasi\'ra dandiitto. Haile Resort nna Lewi Hotelu Hawaasa Baari baaxira daggino doorubbaati.",
      };
    } else if (q.contains("pharmacy") || q.contains("ፋርማሲ") || q.contains("medicine") || q.contains("xalle")) {
      responses = {
        'en': "For pharmacy services, check the Pharmacy section to search medicines and place orders.",
        'am': "ለፋርማሲ አገልግሎቶች መድሃኒቶችን ለመፈለግ እና ትዕዛዝ ለመስጠት የፋርማሲውን ክፍል ይመልከቱ።",
        'sid': "Xallote soqansiwa, Xallote qixxaawo giddo xalle hasi\'ranna sokka dandiitto.",
      };
    } else if (q.contains("hospital") || q.contains("ሆስፒታል") || q.contains("health") || q.contains("hospitaale")) {
      responses = {
        'en': "For hospital information, visit the Hospital section. In emergencies, use the red Emergency button for instant help.",
        'am': "ለሆስፒታል መረጃ የሆስፒታሉን ክፍል ይጎብኙ። በድንገተኛ ጊዜ፣ ለአፋጣኝ እርዳታ ቀይ የድንገተኛ ጊዜ ቁልፍን ይጠቀሙ።",
        'sid': "Hospitaale daggino mashalaqqe, Hospitaale qixxaawo la\'i. Dawicho ikkiro, kaa\'lo afate xiraacho Dawicho butoone kishshi.",
      };
    } else if (q.contains("emergency") || q.contains("help") || q.contains("ድንገተኛ") || q.contains("dawicho")) {
      responses = {
        'en': "For emergencies, tap the red Emergency button on the home screen. You can request Ambulance, Police, Fire Department, or Road Emergency assistance.",
        'am': "ለድንገተኛ አደጋዎች በዋናው ስክሪን ላይ ያለውን ቀይ የድንገተኛ አደጋ ቁልፍ ይጫኑ። አምቡላንስ፣ ፖሊስ፣ የእሳት አደጋ መከላከያ ወይም የመንገድ ላይ ድንገተኛ እርዳታ መጠየቅ ይችላሉ።",
        'sid': "Dawicho ikkiro, mine skrine aana noo xiraacho Dawicho butoone kishshi. Ambulaanse, Poolise, Gidira xibbiwa, woy doogote dawicho kaa\'lo xa\'ma dandiitto.",
      };
    } else if (q.contains("tourist") || q.contains("tourism") || q.contains("ቱሪስት") || q.contains("visit") || q.contains("tuuristi")) {
      responses = {
        'en': "Hawassa has amazing tourist spots! Visit Hawassa Lake & Amora Gedel for birds and fresh fish, Tabor Mountain for hiking, Gudumale Cultural Center, and Millennium Park.",
        'am': "ሀዋሳ አስደናቂ የቱሪስት ቦታዎች አሏት! ለአእዋፍ እና ትኩስ ዓሳ የሀዋሳ ሐይቅን እና አሞራ ገደልን ይጎብኙ፣ ታቦር ተራራን ለእግር ጉዞ፣ ጉዱማሌ የባህል ማዕከልን እና ሚሊኒየም ፓርክን ይጎብኙ።",
        'sid': "Hawaasa dhagga daggino tuuristete bayicho daggino! Hawaasa Baarinna Amora Gedel cironna haaricho qulxume la\'ate ha\'ri, Taboru tura hiraase hasi\'rateno, Gudumale mawaate giddo, nna Millennium Parki ha\'ri.",
      };
    } else if (q.contains("eco") || q.contains("shine")) {
      responses = {
        'en': "Eco-Shine stations offer solar-powered shoe shining with water recycling and free USB charging. Find them at Piazza and Hawassa University.",
        'am': "የኢኮ-ሻይን ጣቢያዎች በፀሐይ ኃይል የሚሰራ የጫማ ቀለም ከውሃ መልሶ ጥቅም ላይ ማዋል እና ነፃ የዩኤስቢ ኃይል መሙላት ጋር ይሰጣሉ። በፒያሳ እና በሀዋሳ ዩኒቨርሲቲ ያገኟቸዋል።",
        'sid': "Eco-Shine soqansiwa harricho huxxunni soqantanno nna USB shaaje assateno kaa\'litanno. Piazza nna Hawaasa Yuunibersiite giddo hasi\'ra dandiitto.",
      };
    } else if (q.contains("announcement") || q.contains("news") || q.contains("ማስታወቂያ") || q.contains("sokka")) {
      responses = {
        'en': "Check the Announcements section for the latest city news and updates.",
        'am': "የቅርብ ጊዜ የከተማ ዜናዎችን እና ዝመናዎችን ለማግኘት የማስታወቂያ ክፍሉን ይመልከቱ።",
        'sid': "Sokka qixxaawo giddo haaricho katama mashalaqqe nna lede la\'i.",
      };
    } else {
      responses = {
        'en': "I'm your SIDAMA WAY GO assistant! I can help with bus tickets, taxi rides, hotels, pharmacy, hospitals, emergency services, and tourist information. What would you like to know?",
        'am': "እኔ የሲዳማ ዌይ ጎ ረዳትዎ ነኝ! በአውቶቡስ ቲኬቶች፣ በታክሲ ጉዞዎች፣ በሆቴሎች፣ በፋርማሲ፣ በሆስፒታሎች፣ በድንገተኛ አደጋ አገልግሎቶች እና በቱሪስት መረጃዎች መርዳት እችላለሁ። ምን ማወቅ ይፈልጋሉ?",
        'sid': "SIDAMA WAY GO kaa\'laanchoho! Busete tikete, taaksite, hotelu, xallote, hospitaale, dawicho soqansiwa, nna tuuristete mashalaqqenni kaa\'lo dandiioommo. Ma afa hasi\'ratto?",
      };
    }

    return responses[langCode] ?? responses['en']!;
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.t('ai_assistant')),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final msg = _messages[i];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg.isUser ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(15).copyWith(
                        bottomRight: msg.isUser ? Radius.zero : null,
                        bottomLeft: !msg.isUser ? Radius.zero : null,
                      ),
                    ),
                    child: Text(msg.text),
                  ),
                );
              },
            ),
          ),
          if (_isListening)
             const Padding(
               padding: EdgeInsets.all(8.0),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(Icons.circle, color: Colors.red, size: 12),
                   SizedBox(width: 8),
                   Text("Listening...", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                 ],
               ),
             ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : Colors.grey),
                  onPressed: _listen,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type or speak...",
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF6A1B9A)),
                  onPressed: _handleSend,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
