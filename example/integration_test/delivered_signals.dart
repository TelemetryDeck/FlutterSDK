import 'dart:convert';
import 'dart:io';

final _queryEndpoint =
    Uri.parse("https://api.telemetrydeckapi.com/api/v4/query/tql");

/// Returns the types of the test mode signals of the last two days whose
/// `runId` default parameter equals [runId], as reported by the TelemetryDeck
/// query API.
Future<Set<String>> deliveredSignalTypes({
  required String personalAccessToken,
  required String namespace,
  required String appID,
  required String runId,
}) async {
  assert(personalAccessToken.isNotEmpty);
  assert(runId.isNotEmpty);

  final query = {
    "queryType": "scan",
    "dataSource": namespace,
    "granularity": "all",
    "appID": appID,
    "baseFilters": "thisApp",
    "testMode": true,
    "filter": {"type": "selector", "dimension": "runId", "value": runId},
    "relativeIntervals": [
      {
        "beginningDate": {
          "component": "day",
          "offset": -2,
          "position": "beginning",
        },
        "endDate": {"component": "day", "offset": 0, "position": "end"},
      },
    ],
  };

  final client = HttpClient();
  try {
    final request = await client.postUrl(_queryEndpoint);
    request.headers
      ..set(HttpHeaders.authorizationHeader, "Bearer $personalAccessToken")
      ..contentType = ContentType.json;
    request.write(jsonEncode(query));
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException("HTTP ${response.statusCode}: $body",
          uri: _queryEndpoint);
    }
    return {
      for (final segment in jsonDecode(body) as List)
        for (final event in (segment["events"] as List?) ?? const [])
          event["type"] as String,
    };
  } finally {
    client.close();
  }
}
