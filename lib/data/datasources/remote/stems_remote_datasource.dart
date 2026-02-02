import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../models/category.dart';
import '../../models/stem.dart';

class StemsData {
  final String version;
  final List<Category> categories;
  final List<Stem> stems;

  const StemsData({
    required this.version,
    required this.categories,
    required this.stems,
  });

  factory StemsData.fromJson(Map<String, dynamic> json) {
    return StemsData(
      version: json['version'] as String,
      categories: (json['categories'] as List<dynamic>)
          .map((c) => Category.fromJson(c as Map<String, dynamic>))
          .toList(),
      stems: (json['stems'] as List<dynamic>)
          .map((s) => Stem.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

class StemsRemoteDatasource {
  final http.Client _client;
  final String? _remoteUrl;

  StemsRemoteDatasource({
    http.Client? client,
    String? remoteUrl,
  })  : _client = client ?? http.Client(),
        _remoteUrl = remoteUrl;

  Future<StemsData> fetchStems() async {
    // Try remote first if URL is configured
    if (_remoteUrl != null) {
      try {
        final response = await _client
            .get(Uri.parse(_remoteUrl))
            .timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          return StemsData.fromJson(json);
        }
      } catch (_) {
        // Fall through to local fallback
      }
    }

    // Fall back to bundled asset
    return _loadBundledStems();
  }

  Future<StemsData> _loadBundledStems() async {
    final jsonString =
        await rootBundle.loadString('assets/stems/default_stems.json');
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return StemsData.fromJson(json);
  }
}
