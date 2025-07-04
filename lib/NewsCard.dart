
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

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
  late FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
  }

  void speak(String text) async {
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

            // Source
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.source, size: 18, color: Colors.grey[600]),
                    SizedBox(width: 6),
                    Text(
                      '${widget.getTranslation('source')}: ${widget.article['source']?['name'] ?? 'Unknown'}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.volume_up, color: Colors.blue),
                  onPressed: () {
                    speak(widget.article['description'] ?? '');
                  },
                ),
              ],
            ),
            // Tap to view full article
            if (widget.article['url'] != null)
              Container(
                margin: EdgeInsets.only(top: 12),
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${widget.getTranslation('articleUrl')}: ${widget.article['url']}'),
                    ),
                  );
                },
                child: Text(
                  widget.getTranslation('readMore'),
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              )
              ),
          ],
        ),
      ),
    );
  }
}