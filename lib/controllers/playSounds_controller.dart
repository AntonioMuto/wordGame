import 'package:audioplayers/audioplayers.dart';

class PlaysoundsController {
  
  final player = AudioPlayer();

  Future<void> playSoundCorrectWord() async {
    await player.play(AssetSource('audios/correct_word.mp3'));  
  }

  Future<void> playSoundCompletedLevel() async {
    await player.play(AssetSource('audios/completed_level.mp3'));  
  }
  
  Future<void> playSoundWrongWord() async {
    await player.play(AssetSource('audios/wrong_word.mp3'));
  }

  Future<void> playSoundFailedLevel() async {
    await player.play(AssetSource('audios/failed_level.mp3'));
  }
}