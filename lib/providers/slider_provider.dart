// lib/providers/slider_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final sliderIdsProvider = FutureProvider<List<String>>((ref) async {
  try {
    final response = await http.get(
      Uri.parse('https://www.hva.gr/api/slider.php?apikey=dFk9p3zvHBGdrt7ghDw3wT2mC4sL'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((id) => id.toString()).toList();
    } else {
      ref.state = AsyncValue.error('HTTP ${response.statusCode}', StackTrace.current);
      return <String>[];
    }
  } catch (e, stack) {
    ref.state = AsyncValue.error(e, stack);
    return <String>[];
  }
});