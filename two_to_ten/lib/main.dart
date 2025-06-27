import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/game_state.dart';
import 'screens/game_screen.dart';
import 'constants/game_constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameState(),
      child: MaterialApp(
        title: '2 to 10 Card Game',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color(GameConstants.greenFeltColor),
          ),
          textTheme: GoogleFonts.interTextTheme(),
          useMaterial3: true,
        ),
        home: const GameScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
