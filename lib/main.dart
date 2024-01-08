import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

void main() => runApp(BibleApp());

class BibleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bible App',
      theme: ThemeData(
        primaryColor: Colors.black,
        dialogTheme: DialogTheme(
          backgroundColor: Color(0xFF121212),
        ),
      ),
      home: BibleVerseScreen(),
    );
  }
}

class BibleVerseScreen extends StatefulWidget {
  @override
  _BibleVerseScreenState createState() => _BibleVerseScreenState();
}

const String bibleLogoImage = 'image/biblelogo.png';

class _BibleVerseScreenState extends State<BibleVerseScreen> {
  late Future<void> fetchVerse;
  String? verseText;
  String? reference;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchVerse = fetchRandomVerse();
  }

  Future<void> fetchRandomVerse() async {
    final response = await get(Uri.parse('https://bible-api.com/?random=verse'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        verseText = data['text'];
        reference = data['reference'];
      });
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('verseText', verseText!);
      prefs.setString('reference', reference!);
    } else {
      setState(() {
        verseText = 'Failed to fetch verse.';
        reference = 'Unknown';
      });
    }
  }

  _navigateToVerse() {
    if (_searchController.text.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BibleReadingScreen(verseReference: _searchController.text)),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Color(0xFF121212),
          title: Text('Empty Verse Reference', style: TextStyle(color: Colors.white)),
          content: Text('Please enter a valid Bible book abbreviation to search.', style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Noted', style: TextStyle(color: Colors.teal[400])),
            ),
          ],
        ),
      );
    }
  }

  void _navigateToAbbreviations() async {
    const abbreviationsUrl = 'https://www.logos.com/bible-book-abbreviations'; // Replace with your website URL
    if (await canLaunch(abbreviationsUrl)) {
      await launch(abbreviationsUrl);
    } else {
      throw 'Could not launch $abbreviationsUrl';
    }
  }

  _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: fetchVerse,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Heavenly Hues',
                style: GoogleFonts.getFont('Cookie').copyWith(fontSize: 30, color: Colors.white),
              ),
              backgroundColor: Color(0xFF121212),
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildVerseOfTheDay(),
                  SizedBox(height: 20),
                  _buildAboutBibleProject(),
                  SizedBox(height: 20),
                  _buildSearchBar(),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: _navigateToAbbreviations,
                    child: Hero(
                      tag: 'bookAbbreviations',
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(color: Colors.teal[400], borderRadius: BorderRadius.circular(12.0)),
                        child: Center(
                          child: Text(
                            'Tap for Bible book abbreviations',
                            style: GoogleFonts.getFont('Libre Baskerville').copyWith(fontSize: 14, color: Colors.white, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: Color(0xFF000000),
          );
        }
      },
    );
  }

  Widget _buildVerseOfTheDay() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: Color(0xFF333333), borderRadius: BorderRadius.circular(12.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Featured Verse', style: GoogleFonts.getFont('Libre Baskerville').copyWith(fontSize: 18, color: Colors.white)),
          SizedBox(height: 18),
          Text(verseText ?? 'Loading...', textAlign: TextAlign.center, style: GoogleFonts.getFont('Libre Baskerville').copyWith(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(reference ?? 'Unknown', textAlign: TextAlign.center, style: GoogleFonts.getFont('Libre Baskerville').copyWith(fontSize: 15, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildAboutBibleProject() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: Color(0xFF333333), borderRadius: BorderRadius.circular(12.0)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.asset('image/bibleproject.png', height: 300, width: MediaQuery.of(context).size.width * 0.4, fit: BoxFit.cover),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Embrace the stories of faith, hope, and redemption to ignite a new passion within.',
                  style: GoogleFonts.getFont('Libre Baskerville').copyWith(fontSize: 15, color: Colors.white),
                ),
                SizedBox(height: 5),
                Text(
                  '— let the Bible speak to your heart today.',
                  style: GoogleFonts.getFont('Libre Baskerville').copyWith(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.white),
                ),
                SizedBox(height: 15),
                Text(
                  'About:\nBible Project creates free resources to help you experience the Bible. You can see our entire library of videos, podcasts, and classes, and other resources at bibleproject.com.',
                  style: GoogleFonts.getFont('Libre Baskerville').copyWith(fontSize: 13.3, color: Colors.white70),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _launchUrl('https://bibleproject.com/'),
                  child: Text('EXPLORE MORE', style: TextStyle(color: Colors.white, fontSize: 12)),
                  style: ElevatedButton.styleFrom(primary: Colors.teal, onPrimary: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: Color(0xFF333333), borderRadius: BorderRadius.circular(12.0)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.white, fontFamily: 'Libre Baskerville'),
              decoration: InputDecoration(
                hintText: 'Verse: (e.g.,"1Cor 13:4-7")',
                hintStyle: GoogleFonts.libreBaskerville().copyWith(color: Colors.teal[400], fontSize: 12), // Updated hintStyle color
              ),
            ),
          ),
          SizedBox(width: 16),
          ElevatedButton(
            onPressed: _navigateToVerse,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.teal),
              padding: EdgeInsets.all(10),
              child: Icon(Icons.search, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(shape: CircleBorder(), padding: EdgeInsets.all(2)),
          ),
        ],
      ),
    );
  }
}

class BibleReadingScreen extends StatelessWidget {
  final String verseReference;

  BibleReadingScreen({required this.verseReference});

  Future<Map<String, dynamic>> _fetchBibleVerse(String verseReference) async {
    final response = await get(Uri.parse('https://bible-api.com/$verseReference'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load Bible verse');
    }
  }

  void _shareVerse(BuildContext context, String verseText, String reference) {
    final textToShare = 'Verse: $verseText\nReference: $reference';
    Share.share(textToShare);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Divine Dialogues',
          style: GoogleFonts.getFont('Cookie').copyWith(fontSize: 30, color: Colors.white),
        ),
        backgroundColor: Color(0xFF121212),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            color: Colors.white,
            icon: Icon(Icons.share),
            onPressed: () async {
              final verseData = await _fetchBibleVerse(verseReference);
              final verseText = verseData['text'] ?? 'Verse not found';
              final reference = verseData['reference'] ?? 'Reference not found';
              _shareVerse(context, verseText, reference);
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('image/biblereading.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 100.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: FutureBuilder<Map<String, dynamic>>(
                future: _fetchBibleVerse(verseReference),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'image/biblelogo.png',
                            height: 200,
                            width: MediaQuery.of(context).size.width * 1,
                            fit: BoxFit.cover,
                          ),
                          Text(
                            '\n${snapshot.error}. Input a valid one, refer to the suggested Bible book abbreviations.',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          snapshot.data?['text'] ?? 'Verse not found',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.libreBaskerville().copyWith(fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        Text(
                          snapshot.data?['reference'] ?? 'Reference not found',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.libreBaskerville().copyWith(fontSize: 14, fontStyle: FontStyle.italic),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
