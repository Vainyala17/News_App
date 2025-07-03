import 'package:flutter/material.dart';
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
  String translationProgress = '';

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
      'articleUrl': 'Article URL',
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
      'articleUrl': 'लेख URL',
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
      'articleUrl': 'लेख URL',
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
        throw Exception('Failed to load news');
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
      selectedLanguage = lang;

      List<Future<Map>> translationTasks = articles.map((article) async {
        final translatedTitle = await translateTextUsingAPI(article['title'] ?? '', lang);
        final translatedDesc = await translateTextUsingAPI(article['description'] ?? '', lang);

        return {
          ...article,
          'title': translatedTitle,
          'description': translatedDesc,
        };
      }).toList();

      final translated = await Future.wait(translationTasks);

      setState(() {
        translatedArticles = translated;
        isTranslating = false;
        translationProgress = '';
      });
    } catch (e) {
      setState(() {
        isTranslating = false;
        translationProgress = '';
        selectedLanguage = 'English';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${getTranslation('translationFailed')}: $e')),
      );
    }
  }


  Future<String> translateTextUsingAPI(String text, String targetLang) async {
    if (text.isEmpty) return '';

    try {
      // Alternative translation APIs due to LibreTranslate issues
      // Using MyMemory API as backup
      final uri = Uri.parse('https://api.mymemory.translated.net/get');
      final queryParams = {
        'q': text,
        'langpair': 'en|${targetLang == 'Hindi' ? 'hi' : 'mr'}',
      };

      final response = await http.get(uri.replace(queryParameters: queryParams));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['responseStatus'] == 200) {
          return data['responseData']['translatedText'] ?? text;
        }
      }

      // If MyMemory fails, try LibreTranslate
      final libretranslateUri = Uri.parse('https://libretranslate.de/translate');
      final libretranslateResponse = await http.post(
        libretranslateUri,
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

      print('Translation API error: ${libretranslateResponse.statusCode}');
      return text; // Return original text if translation fails
    } catch (e) {
      print('Translation error: $e');
      return text; // Return original text if translation fails
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
                if (newLang != null) translateArticles(newLang);
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
