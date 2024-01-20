import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:math';


//file reading
Future<String> readFile(FilePickerResult result) async {

  File file = File(result.files.single.path!);

  String fileContent = await file.readAsString();

  return fileContent;
}


//file searching
class SearchResult {
  final int start;
  final int end;
  final int lineNumber;

  SearchResult(this.start, this.end, this.lineNumber);
}


//kmp
List<int> kmpSearch(String text, String pattern) {
  if (pattern.isEmpty) return [];
  List<int> lps = _computeLPSArray(pattern);
  int i = 0;
  int j = 0;
  List<int> result = [];

  while (i < text.length) {
    if (pattern[j] == text[i]) {
      j++;
      i++;
    }
    if (j == pattern.length) {
      result.add(i - j);
      j = lps[j - 1];
    } else if (i < text.length && pattern[j] != text[i]) {
      if (j != 0)
        j = lps[j - 1];
      else
        i = i + 1;
    }
  }
  return result;
}

List<int> _computeLPSArray(String pattern) {
  int length = 0;
  List<int> lps = List.filled(pattern.length, 0);
  int i = 1;

  while (i < pattern.length) {
    if (pattern[i] == pattern[length]) {
      length++;
      lps[i] = length;
      i++;
    } else {
      if (length != 0) {
        length = lps[length - 1];
      } else {
        lps[i] = 0;
        i++;
      }
    }
  }
  return lps;
}


//Rabin-karp
List<int> rabinKarpSearch(String text, String pattern) {
  const int prime = 101;
  List<int> result = [];
  int m = pattern.length;
  int n = text.length;
  int i, j;
  int patternHash = 0;
  int textHash = 0;
  int hash = 1;

  for (i = 0; i < m - 1; i++) {
    hash = (hash * 256) % prime;
  }

  for (i = 0; i < m; i++) {
    patternHash = (256 * patternHash + pattern.codeUnitAt(i)) % prime;
    textHash = (256 * textHash + text.codeUnitAt(i)) % prime;
  }

  for (i = 0; i <= n - m; i++) {
    if (patternHash == textHash) {
      for (j = 0; j < m; j++) {
        if (text[i + j] != pattern[j]) break;
      }
      if (j == m) {
        result.add(i);
      }
    }
    if (i < n - m) {
      textHash = (256 * (textHash - text.codeUnitAt(i) * hash) + text.codeUnitAt(i + m)) % prime;
      if (textHash < 0) textHash = (textHash + prime);
    }
  }
  return result;
}


//text analyzis
Map<String, int> countWordFrequency(String text) {
  Map<String, int> wordFreq = {};
  List<String> words = text.split(RegExp(r'\s+'));

  for (String word in words) {
    if (word.isNotEmpty) {
      wordFreq[word] = (wordFreq[word] ?? 0) + 1;
    }
  }

  return wordFreq;
}

Map<String, int> countCharacterFrequency(String text) {
  Map<String, int> charFreq = {};

  for (int i = 0; i < text.length; i++) {
    String char = text[i];
    charFreq[char] = (charFreq[char] ?? 0) + 1;
  }

  return charFreq;
}

String getMostFrequentWord(Map<String, int> wordFreq) {
  return wordFreq.keys.reduce((a, b) => wordFreq[a]! > wordFreq[b]! ? a : b);
}

String getLeastFrequentWord(Map<String, int> wordFreq) {
  return wordFreq.keys.reduce((a, b) => wordFreq[a]! < wordFreq[b]! ? a : b);
}

//levenstein
int levenshteinDistance(String s, String t) {
  if (s == t) return 0;
  if (s.isEmpty) return t.length;
  if (t.isEmpty) return s.length;

  List<int> v0 = List<int>.filled(t.length + 1, 0);
  List<int> v1 = List<int>.generate(t.length + 1, (i) => i);

  for (int i = 0; i < s.length; i++) {
    v0[0] = i + 1;
    for (int j = 0; j < t.length; j++) {
      int cost = (s[i] == t[j]) ? 0 : 1;
      v0[j + 1] = [
        v1[j + 1] + 1, // deletion
        v0[j] + 1,     // insertion
        v1[j] + cost   // substitution
      ].reduce(min);
    }
    List<int> temp = v0;
    v0 = v1;
    v1 = temp;
  }
  return v1[t.length];
}