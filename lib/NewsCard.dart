
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class NewsCard extends StatefulWidget {
  final Map article;
  final String Function(String) getTranslation;

  const NewsCard({Key? key, required this.article, required this.getTranslation})
      : super(key: key);

  @override
  _NewsCardState createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  bool isExpanded = false;
  double pitch = 1.0;
  late FlutterTts flutterTts;
  late stt.SpeechToText _speech;
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _speech = stt.SpeechToText();
    requestMicPermission();
  }

  void startListening(String textToRead) async {
    if (!_speech.isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('Status: $status'),
        onError: (error) => print('Error: $error'),
      );
      if (!available) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Speech recognition not available")),
        );
        return;
      }

      setState(() => isListening = true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🎤 Listening... Say 'start' or 'stop'")),
      );

      _speech.listen(
        onResult: (result) {
          final command = result.recognizedWords.toLowerCase();
          if (command.contains("start")) {
            speak(textToRead);
          } else if (command.contains("stop")) {
            flutterTts.stop();
          }
        },
      );
    }
  }

  Future<void> requestMicPermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  @override
  void dispose() {
    _speech.stop();
    flutterTts.stop();
    super.dispose();
  }

  void speak(String text) async {
    await flutterTts.setPitch(pitch); // Add this
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(12),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large Image
            if (widget.article['urlToImage'] != null)
              Container(
                width: double.infinity,
                height: 200,
                margin: EdgeInsets.only(bottom: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.article['urlToImage'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey[600],
                          ),
                        ),
                  ),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Pitch Control", style: TextStyle(fontSize: 14)),
                Slider(
                  min: 0.5,
                  max: 2.0,
                  divisions: 6,
                  value: pitch,
                  label: pitch.toStringAsFixed(1),
                  onChanged: (value) {
                    setState(() {
                      pitch = value;
                      flutterTts.setPitch(pitch);
                    });
                  },
                ),
              ],
            ),

            // Title with bigger font
            Text(
              widget.article['title'] ?? widget.getTranslation('noTitle'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                height: 1.3,
              ),
            ),
            SizedBox(height: 12),

            // Description with Read More functionality
            if (widget.article['description'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.article['description'],
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      color: Colors.grey[700],
                    ),
                    maxLines: isExpanded ? null : 3,
                    overflow: isExpanded ? null : TextOverflow.ellipsis,
                  ),
                  if (widget.article['description'].length > 100)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          isExpanded
                              ? widget.getTranslation('readLess')
                              : widget.getTranslation('readMore'),
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.getTranslation('source')}: ${widget.article['source']?['name'] ?? 'Unknown'}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.volume_up, color: Colors.green),
                  onPressed: () {
                    speak(widget.article['description'] ?? '');
                  },
                ),
                IconButton(
                  icon: Icon(Icons.mic, color: isListening ? Colors.red : Colors.blue),
                  onPressed: isListening ? null : () {
                    if ((widget.article['description'] ?? '').isNotEmpty) {
                      startListening(widget.article['description'] ?? '');
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}