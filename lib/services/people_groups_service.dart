import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/people_group.dart';
import '../models/people_group_detail.dart';

const _listFields = 'name,slug,image_url,country_code,religion,people_praying';

Future<List<PeopleGroup>> fetchPeopleGroups({String lang = 'en'}) async {
  final uri = Uri.https(
    'pray.doxa.life',
    '/api/people-groups/list',
    {'lang': lang, 'fields': _listFields},
  );
  final response = await http.get(
    uri,
    headers: const {'Accept': 'application/json'},
  );
  if (response.statusCode != 200) {
    throw Exception(
      'Failed to load people groups (${response.statusCode})',
    );
  }
  final body = jsonDecode(response.body) as Map<String, dynamic>;
  final posts = body['posts'] as List<dynamic>;
  return posts
      .map((e) => PeopleGroup.fromJson(e as Map<String, dynamic>))
      .toList(growable: false);
}

Future<PeopleGroupDetail> fetchPeopleGroupDetail(
  String slug, {
  String lang = 'en',
}) async {
  final uri = Uri.https(
    'pray.doxa.life',
    '/api/people-groups/detail/$slug',
    {'lang': lang},
  );
  final response = await http.get(
    uri,
    headers: const {'Accept': 'application/json'},
  );
  if (response.statusCode != 200) {
    throw Exception(
      'Failed to load people group detail (${response.statusCode})',
    );
  }
  final body = jsonDecode(response.body) as Map<String, dynamic>;
  return PeopleGroupDetail.fromJson(body);
}
