import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const HangmanApp());
}

class HangmanApp extends StatelessWidget {
  const HangmanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Adam Asmaca',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.blueGrey, fontSize: 20),
          bodyMedium: TextStyle(color: Colors.blueGrey, fontSize: 18),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlueAccent,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const StartScreen(),
    );
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/hangman_logo.png', width: 200),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const GameScreen()),
              ),
              child: const Text('Başla'),
            ),
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<String> words = [];
  String selectedWord = "";
  List<String> visibleWord = [];
  List<String> guessedLetters = [];
  int remainingAttempts = 6;
  bool isLoading = true;

  // Türk alfabesi, harfler arasında Türkçe karakterler de yer alıyor
  List<String> turkishAlphabet = [
    'A', 'B', 'C', 'Ç', 'D', 'E', 'F', 'G', 'Ğ', 'H', 'I', 'İ', 'J', 'K', 'L', 'M', 'N', 'O', 'Ö', 'P', 'R', 'S', 'Ş', 'T', 'U', 'Ü', 'V', 'Y', 'Z'
  ];

  @override
  void initState() {
    super.initState();
    loadWords();
  }

  Future<void> loadWords() async {
    final String response = await DefaultAssetBundle.of(context).loadString('assets/words.json');
    final List<dynamic> data = jsonDecode(response);
    words = List<String>.from(data);
    newGame();
    setState(() {
      isLoading = false;
    });
  }

  void newGame() {
    if (words.isEmpty) return;
    final random = Random();
    selectedWord = words[random.nextInt(words.length)].toUpperCase();

    // Boşluklar otomatik olarak görünmeli
    visibleWord = selectedWord.split('').map((char) => char == ' ' ? ' ' : '_').toList();
    guessedLetters.clear();
    remainingAttempts = 6;
    setState(() {});
  }

  void guessLetter(String letter) {
  if (guessedLetters.contains(letter)) return; // Aynı harfi tekrar tahmin etmeyi engelle
  guessedLetters.add(letter);

  bool letterFound = false;
  for (int i = 0; i < selectedWord.length; i++) {
    if (selectedWord[i] == letter) {
      visibleWord[i] = letter;
      letterFound = true;
    }
  }

  if (!letterFound) {
    remainingAttempts--;
  }

  // **Kazananı Kontrol Et**
  if (!visibleWord.contains('_')) {
    showResultDialog(true); // Oyuncu kazandı!
    return;
  }

  // **Kaybedeni Kontrol Et**
  if (remainingAttempts == 0) {
    showResultDialog(false); // Oyuncu kaybetti!
    return;
  }

  setState(() {}); // UI'yi güncelle
}

// **Kazandı/Kaybetti Penceresi**
void showResultDialog(bool isWinner) {
  String title = isWinner ? "Tebrikler!" : "Oyun Bitti!";
  String message = isWinner ? "Kelimeyi doğru bildiniz: $selectedWord" : "Doğru kelime: $selectedWord";

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      content: Text(message, style: const TextStyle(fontSize: 20)),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            newGame(); // Yeni oyuna başla
          },
          child: const Text("Tekrar Oyna"),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adam Asmaca'),
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Kalan Hak: $remainingAttempts', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 20),
          Text(visibleWord.join(' '), style: const TextStyle(fontSize: 30, color: Colors.blueAccent)),
          const SizedBox(height: 20),

          // Harf butonlarını Türk alfabesiyle oluşturuyoruz
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: turkishAlphabet.map((letter) {
              return ElevatedButton(
                onPressed: remainingAttempts > 0 && !guessedLetters.contains(letter)
                    ? () => guessLetter(letter)
                    : null, // Buton sadece geçerli bir harf için aktif
                child: Text(letter),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
