import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(BibleApp());
}

class BibleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bible App',
      theme: ThemeData(
        primaryColor: Colors.black,
      ),
      home: BibleVerseScreen(),
    );
  }
}

class BibleVerseScreen extends StatefulWidget {
  @override
  _BibleVerseScreenState createState() => _BibleVerseScreenState();
}

class _BibleVerseScreenState extends State<BibleVerseScreen> {
  String? verseText;
  String? reference;

  @override
  void initState() {
    super.initState();
    fetchStoredVerse();
  }

  Future<void> fetchStoredVerse() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('verseText') && prefs.containsKey('reference')) {
      setState(() {
        verseText = prefs.getString('verseText');
        reference = prefs.getString('reference');
      });
    } else {
      fetchRandomVerse();
    }
  }

  Future<void> fetchRandomVerse() async {
    final response = await get(Uri.parse('https://bible-api.com/?random=verse'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        verseText = data['text'] ?? 'Failed to fetch verse.';
        reference = data['reference'] ?? 'Unknown';
      });

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('verseText', verseText!);
      prefs.setString('reference', reference!);
    } else {
      setState(() {
        verseText = 'Failed to fetch verse.';
        reference = 'Unknown';
      });
    }
  }

  _launchBibleProject() async {
    const url = 'https://bibleproject.com/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Heavenly Hues',
          style: GoogleFonts.getFont('Cookie').copyWith(
            fontSize: 30,
          ),
        ),
        backgroundColor: Color(0xFF121212),
      ),
      body: Container(
        color: Color(0xFF000000),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color(0xFF333333),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Verse of the Day',
                      style: GoogleFonts.getFont('Libre Baskerville').copyWith(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 18),
                    Text(
                      verseText ?? 'Loading...',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.getFont('Libre Baskerville').copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 0),
                    Text(
                      (reference ?? 'Unknown'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.getFont('Libre Baskerville').copyWith(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color(0xFF333333),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.asset(
                        'image/bibleproject.png',
                        height: 300,
                        width: MediaQuery.of(context).size.width * 0.4,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Embrace the stories of faith, hope, and redemption to ignite a new passion within.',
                            style: GoogleFonts.getFont('Libre Baskerville').copyWith(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '— let the Bible speak to your heart today.',
                            style: GoogleFonts.getFont('Libre Baskerville').copyWith(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            'About:\nBible Project creates free resources to help you experience the Bible. You can see our entire library of videos, podcasts, and classes, and other resources at bibleproject.com.',
                            style: GoogleFonts.getFont('Libre Baskerville').copyWith(
                              fontSize: 13.3,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _launchBibleProject,
                            child: Text(
                              'EXPLORE MORE',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12 ),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.teal,
                              onPrimary: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
