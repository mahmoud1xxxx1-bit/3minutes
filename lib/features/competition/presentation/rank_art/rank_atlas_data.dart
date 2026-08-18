import 'dart:convert';
import 'dart:typed_data';

import 'chunk_00.dart';
import 'chunk_01.dart';
import 'chunk_02.dart';
import 'chunk_03_04.dart';
import 'chunk_05_06.dart';
import 'chunk_07_08.dart';
import 'chunk_09_10.dart';
import 'chunk_11_12.dart';
import 'chunk_13_14.dart';
import 'chunk_15.dart';

class RankAtlasData {
  const RankAtlasData._();

  static Uint8List? _cachedBytes;

  static Uint8List get bytes => _cachedBytes ??= base64Decode(
        rankAtlasChunk00 +
            rankAtlasChunk01 +
            rankAtlasChunk02 +
            rankAtlasChunk0304 +
            rankAtlasChunk0506 +
            rankAtlasChunk0708 +
            rankAtlasChunk0910 +
            rankAtlasChunk1112 +
            rankAtlasChunk1314 +
            rankAtlasChunk15,
      );

  static const int columns = 4;
  static const int rows = 2;
  static const int cellSize = 96;
}
