import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class NotionApi {
  final String apiToken;
  final String databaseId;

  NotionApi({required this.apiToken, required this.databaseId});

  Future<void> createPage(String number, String date, String option) async {
    final url = Uri.parse('https://api.notion.com/v1/pages');
    final headers = {
      'Authorization': 'Bearer $apiToken',
      'Content-Type': 'application/json',
      'Notion-Version': '2022-06-28',
    };

    final body = jsonEncode({
      "parent": {"database_id": databaseId},
      "properties": {
        "ID": {
          "title": [
            {
              "text": {"content": number}
            }
          ]
        },
        "Handover Date": {
          "date": {"start": date}
        },
        "Select": {
          "select": {"name": option}
        }
      }
    });

    // Log the equivalent cURL command.
    // final curlCommand = "curl -X POST '${url.toString()}' "
    //     "-H 'Authorization: Bearer $apiToken' "
    //     "-H 'Content-Type: application/json' "
    //     "-H 'Notion-Version: 2022-06-28' "
    //     "-d '${body.replaceAll("'", r"\'")}'";
    // print("cURL Command: $curlCommand");

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Page created successfully: ${response.body}");
    } else {
      print("Failed to create page: ${response.statusCode} ${response.body}");
    }
  }
}
