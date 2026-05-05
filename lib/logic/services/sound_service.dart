import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../cubit/settings/settings_cubit.dart';

class SoundService {
  final AudioPlayer _player = AudioPlayer();
  final SettingsCubit _settingsCubit;

  SoundService(this._settingsCubit,);

  Future<void> _playSound(String path) async {
    if (!_settingsCubit.state.soundEnabled) return;

    try {
      await _player.play(AssetSource(path));
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  void playSuccess() => _playSound('audio/success.mp3');
  void playError() => _playSound('audio/error.mp3');
  void playShutter() => _playSound('audio/shutter.mp3');
  void playTap() => _playSound('audio/tap.mp3');
}
