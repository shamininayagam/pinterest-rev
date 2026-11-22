import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../model/author_model.dart';
import '../../model/pin_model.dart';

class ApiService {
  final http.Client _client;

  ApiService([http.Client? client]) : _client = client ?? http.Client();

  /// Queries live real-world images from Openverse API with Wikipedia API fallback.
  Future<List<Pin>> searchImages(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    try {
      // 1. Try Openverse CC Image Search API
      final openverseUrl = Uri.parse(
        'https://api.openverse.org/v1/images/?q=${Uri.encodeComponent(cleanQuery)}&page_size=24',
      );

      final response = await _client.get(openverseUrl).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>?;

        if (results != null && results.isNotEmpty) {
          final colors = ['#3B82F6', '#10B981', '#F59E0B', '#8B5CF6', '#EC4899', '#64748B'];

          return results.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value as Map<String, dynamic>;

            final width = (item['width'] as num?)?.toDouble() ?? 800;
            final height = (item['height'] as num?)?.toDouble() ?? 600;
            final aspect = (width > 0 && height > 0)
                ? (height / width).clamp(0.7, 1.8)
                : (1.2 + (idx % 3) * 0.2);

            final creator = item['creator'] as String? ?? 'Community Creator';
            final title = item['title'] as String? ??
                '${cleanQuery[0].toUpperCase()}${cleanQuery.substring(1)} Inspiration';

            final tagsList = (item['tags'] as List<dynamic>?)
                    ?.take(4)
                    .map((t) => (t as Map<String, dynamic>)['name']?.toString() ?? '')
                    .where((t) => t.isNotEmpty)
                    .toList() ??
                [cleanQuery];

            return Pin(
              id: 'live-${item['id'] ?? idx}',
              title: title,
              description: item['attribution'] as String? ?? 'Photograph by $creator via Openverse.',
              imageUrl: item['url'] as String? ?? '',
              aspectRatio: aspect,
              dominantColor: colors[idx % colors.length],
              author: Author(
                name: creator,
                handle: creator.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_'),
                avatar:
                    'https://images.unsplash.com/photo-${1534528741775 + (idx * 50) % 1000}?auto=format&fit=crop&w=150&q=80',
              ),
              link: item['foreign_landing_url'] as String? ?? item['url'] as String?,
              boardId: 'board-1',
              category: cleanQuery,
              likesCount: 150 + (idx * 37) % 2500,
              tags: tagsList,
              comments: const [],
              isLive: true,
            );
          }).where((p) => p.imageUrl.isNotEmpty).toList();
        }
      }
    } catch (_) {
      // Fallback to Wikipedia API
    }

    try {
      // 2. Fallback to Wikipedia Media API
      final wikiUrl = Uri.parse(
        'https://en.wikipedia.org/w/api.php?action=query&generator=search&gsrsearch=${Uri.encodeComponent(cleanQuery)}&gsrlimit=20&prop=pageimages|extracts&piprop=thumbnail&pithumbsize=800&exintro=1&explaintext=1&exchars=160&format=json&origin=*',
      );

      final wikiRes = await _client.get(wikiUrl).timeout(const Duration(seconds: 8));
      if (wikiRes.statusCode == 200) {
        final wikiData = jsonDecode(wikiRes.body) as Map<String, dynamic>;
        final queryObj = wikiData['query'] as Map<String, dynamic>?;
        final pagesMap = queryObj?['pages'] as Map<String, dynamic>?;

        if (pagesMap != null && pagesMap.isNotEmpty) {
          final pages = pagesMap.values.where((p) {
            final thumb = (p as Map<String, dynamic>)['thumbnail'];
            return thumb != null && thumb['source'] != null;
          }).toList();

          return pages.asMap().entries.map((entry) {
            final idx = entry.key;
            final page = entry.value as Map<String, dynamic>;
            final thumb = page['thumbnail'] as Map<String, dynamic>;
            final title = page['title'] as String? ?? cleanQuery;

            return Pin(
              id: 'wiki-${page['pageid'] ?? idx}',
              title: title,
              description: page['extract'] as String? ?? 'Visual media for $title.',
              imageUrl: thumb['source'] as String? ?? '',
              aspectRatio: 1.3 + (idx % 3) * 0.15,
              dominantColor: '#475569',
              author: const Author(
                name: 'Wikipedia Contributor',
                handle: 'wiki_media',
                avatar:
                    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
              ),
              link: 'https://en.wikipedia.org/wiki/${Uri.encodeComponent(title)}',
              boardId: 'board-1',
              category: cleanQuery,
              likesCount: 200 + (idx * 45) % 1800,
              tags: [cleanQuery, 'Reference'],
              comments: const [],
              isLive: true,
            );
          }).where((p) => p.imageUrl.isNotEmpty).toList();
        }
      }
    } catch (_) {
      // Empty fallback
    }

    return [];
  }
}
