import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'NewsCard.dart';

void main() {
  runApp(MaterialApp(home: NewsScreen()));
}

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List articles = [];
  List translatedArticles = [];
  String selectedLanguage = 'English';
  bool isLoading = false;
  bool isTranslating = false;
  bool useStaticNews = false;


  String translationProgress = '';

  // Replace with your actual NewsAPI key
  final String apiKey = '576605d717c24de7935e1ec07c03a38e';

  // Language translations for UI elements
  final Map<String, Map<String, String>> translations = {
    'English': {
      'appTitle': 'News App',
      'loading': 'Loading news...',
      'translating': 'Translating articles...',
      'wait': 'Please wait, this may take a moment',
      'source': 'Source',
      'noTitle': 'No title',
      'readMore': 'Read More',
      'readLess': 'Read Less',
      'errorLoading': 'Error loading news',
      'translationFailed': 'Translation failed',
      'English': 'English',
      'Hindi': 'Hindi',
      'Marathi': 'Marathi',
    },
    'Hindi': {
      'appTitle': 'समाचार ऐप',
      'loading': 'समाचार लोड हो रहा है...',
      'translating': 'लेख अनुवाद हो रहे हैं...',
      'wait': 'कृपया प्रतीक्षा करें, इसमें थोड़ा समय लग सकता है',
      'source': 'स्रोत',
      'noTitle': 'कोई शीर्षक नहीं',
      'readMore': 'और पढ़ें',
      'readLess': 'कम पढ़ें',
      'errorLoading': 'समाचार लोड करने में त्रुटि',
      'translationFailed': 'अनुवाद असफल',
      'English': 'अंग्रेजी',
      'Hindi': 'हिंदी',
      'Marathi': 'मराठी',
    },
    'Marathi': {
      'appTitle': 'बातम्या ॲप',
      'loading': 'बातम्या लोड होत आहेत...',
      'translating': 'लेख भाषांतर होत आहेत...',
      'wait': 'कृपया प्रतीक्षा करा, यास थोडा वेळ लागू शकतो',
      'source': 'स्रोत',
      'noTitle': 'शीर्षक नाही',
      'readMore': 'अधिक वाचा',
      'readLess': 'कमी वाचा',
      'errorLoading': 'बातम्या लोड करण्यात त्रुटी',
      'translationFailed': 'भाषांतर अयशस्वी',
      'English': 'इंग्रजी',
      'Hindi': 'हिंदी',
      'Marathi': 'मराठी',
    },
  };

  String getTranslation(String key) {
    return translations[selectedLanguage]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    fetchNews();
    useStaticNews ? loadStaticNews() : fetchNews();
  }
  Future<void> loadStaticNews() async {
    final String response = await rootBundle.loadString('assets/news.json');
    final List data = json.decode(response);
    setState(() {
      articles = data;
      translatedArticles = List.from(data);
      isLoading = false;
    });
  }

  Future<void> fetchNews() async {
    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse(
          'https://newsapi.org/v2/top-headlines?country=us&category=business&pageSize=10&apiKey=$apiKey'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          articles = data['articles'];
          translatedArticles = List.from(articles);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${getTranslation('errorLoading')}: $e')),
      );
    }
  }

  Future<void> translateArticles(String lang) async {
    if (lang == selectedLanguage) return; // No need to translate if same language

    setState(() {
      isTranslating = true;
      translationProgress = '';
    });

    if (lang == 'English') {
      setState(() {
        translatedArticles = List.from(articles);
        selectedLanguage = lang;
        isTranslating = false;
        translationProgress = '';
      });
      return;
    }

    try {
      List<Map> translatedList = [];

      for (int i = 0; i < articles.length; i++) {
        final article = articles[i];

        setState(() {
          translationProgress = 'Translating article ${i + 1} of ${articles.length}...';
        });

        final translatedTitle = await translateTextUsingAPI(
            article['title'] ?? '',
            lang
        );

        final translatedDesc = await translateTextUsingAPI(
            article['description'] ?? '',
            lang
        );

        translatedList.add({
          ...article,
          'title': translatedTitle,
          'description': translatedDesc,
        });
      }

      setState(() {
        translatedArticles = translatedList;
        selectedLanguage = lang;
        isTranslating = false;
        translationProgress = '';
      });
    } catch (e) {
      setState(() {
        isTranslating = false;
        translationProgress = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${getTranslation('translationFailed')}: $e')),
      );
    }
  }

  Future<String> translateTextUsingAPI(String text, String targetLang) async {
    if (text.isEmpty) return '';

    try {
      // Method 1: Using Google Translate API (Free tier)
      final googleTranslateUrl = 'https://translate.googleapis.com/translate_a/single';
      final googleParams = {
        'client': 'gtx',
        'sl': 'en',
        'tl': targetLang == 'Hindi' ? 'hi' : 'mr',
        'dt': 't',
        'q': text,
      };

      final googleResponse = await http.get(
        Uri.parse(googleTranslateUrl).replace(queryParameters: googleParams),
      );

      if (googleResponse.statusCode == 200) {
        final decoded = json.decode(googleResponse.body);
        if (decoded != null && decoded[0] != null && decoded[0][0] != null) {
          return decoded[0][0][0] ?? text;
        }
      }

      // Method 2: MyMemory API (backup)
      final myMemoryUrl = 'https://api.mymemory.translated.net/get';
      final myMemoryParams = {
        'q': text,
        'langpair': 'en|${targetLang == 'Hindi' ? 'hi' : 'mr'}',
      };

      final myMemoryResponse = await http.get(
        Uri.parse(myMemoryUrl).replace(queryParameters: myMemoryParams),
      );

      if (myMemoryResponse.statusCode == 200) {
        final data = json.decode(myMemoryResponse.body);
        if (data['responseStatus'] == 200) {
          return data['responseData']['translatedText'] ?? text;
        }
      }

      // Method 3: LibreTranslate (backup)
      final libretranslateUrl = 'https://libretranslate.de/translate';
      final libretranslateResponse = await http.post(
        Uri.parse(libretranslateUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': text,
          'source': 'en',
          'target': targetLang == 'Hindi' ? 'hi' : 'mr',
          'format': 'text'
        }),
      );

      if (libretranslateResponse.statusCode == 200) {
        final data = json.decode(libretranslateResponse.body);
        return data['translatedText'] ?? text;
      }

      print('All translation methods failed');
      return text;
    } catch (e) {
      print('Translation error: $e');
      return text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          getTranslation('appTitle'),
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: DropdownButton<String>(
              value: selectedLanguage,
              onChanged: isTranslating ? null : (String? newLang) {
                if (newLang != null) {
                  translateArticles(newLang);
                }
              },
              items: ['English', 'Hindi', 'Marathi']
                  .map((lang) => DropdownMenuItem(
                value: lang,
                child: Text(
                  getTranslation(lang),
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ))
                  .toList(),
              dropdownColor: Colors.blue,
              iconEnabledColor: Colors.white,
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              getTranslation('loading'),
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      )
          : isTranslating
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              getTranslation('translating'),
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              getTranslation('wait'),
              style: TextStyle(fontSize: 16),
            ),
            if (translationProgress.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  translationProgress,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: fetchNews,
        child: ListView.builder(
          itemCount: translatedArticles.length,
          itemBuilder: (context, index) {
            final article = translatedArticles[index];
            return NewsCard(article: article, getTranslation: getTranslation);
          },
        ),
      ),
    );
  }
}