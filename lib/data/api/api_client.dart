import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../constants/app_contants.dart';

class ApiClient extends GetConnect implements GetxService {
  late String token;
  final String apiBaseUrl;
  late Map<String, String> _mainHeaders;

  ApiClient({required this.apiBaseUrl}) {
    baseUrl = apiBaseUrl;
    timeout = Duration(seconds: 10);
    token = AppConstants.TOKEN;
    _mainHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token'
    };
  }

  void updateHeaders(String token) {
    _mainHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token'
    };
  }

  Future<Response> getData(String uri) async {
    if (kDebugMode) {
      print(uri);
    }
    try {
      Response response = await get(uri, headers: _mainHeaders);
      return response;
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> getDataWithParam(String uri, String auth_token) async {
    try {
      String url = uri + '?result_as=JSON&auth_token=$token';

      Response response = await get(
        Uri.parse(url).toString(),
        headers: _mainHeaders,
      );

      return response;
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> postData(String uri, dynamic body) async {
    print(body.toString());
    try {
      Response response = await post(uri, body, headers: _mainHeaders);

      print(response);

      return response;
    } catch (e) {
      print(e.toString());
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> patchData(String uri, dynamic body) async {
    print(body.toString());
    try {
      Response response = await patch(uri, body, headers: _mainHeaders);
      return response;
    } catch (e) {
      print(e.toString());
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> deleteData(String uri, dynamic body) async {
    print('delete url ${uri} \n delete body string ${body.toString()}');
    try {
      Response response = await delete(uri, query: body, headers: _mainHeaders);
      return response;
    } catch (e) {
      print(e.toString());
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<String> deleteWithBody(String uri, dynamic body) async {
    final response = await http.Request(
      'DELETE',
      Uri.parse(uri),
    )
      ..headers.addAll({'Content-Type': 'application/json'})
      ..body = jsonEncode(body);

    final streamed = await response.send();
    final responseBody = await streamed.stream.bytesToString();

    print('Response: ${streamed.statusCode}, $responseBody');

    return responseBody;
  }

  Future<dynamic> addMyItemPrimaryImage(
    String uri,
    String auth_token,
    String name,
    String desc,
    File primary_img_file,
  ) async {
    var request = http.MultipartRequest('POST', Uri.parse(uri));
    request.fields['result_as'] = 'JSON';
    request.fields['auth_token'] = auth_token;
    request.fields['myitem[name]'] = name;
    request.fields['myitem[description]'] = desc;
    request.files.add(
      await http.MultipartFile.fromPath('att_file', primary_img_file.path),
    );
    try {
      final response = await request.send().timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException("API request timed out");
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = await http.Response.fromStream(response);
        return json.decode(res.body);
      }
    } catch (e) {
      print(e.toString());
      return Response(statusCode: 1, statusText: e.toString());
    }

    // print(request);

    // print(response.statusCode);

    // print(json.decode(res.body));
  }

  Future<dynamic> addAttachments(
    String uri,
    String auth_token,
    String item_id,
    int fileFormat,
    String contentType,
    String isHidden,
    File img_file,
  ) async {
    var request = http.MultipartRequest('POST', Uri.parse(uri));
    request.fields['result_as'] = 'JSON';
    request.fields['auth_token'] = auth_token;
    request.fields['attachment[myitem_id]'] = item_id;
    request.fields['attachment[format_id]'] = fileFormat.toString();
    request.fields['attachment[attachfile_content_type]'] = contentType;
    request.fields['attachment[is_hidden]'] = isHidden;
    request.files.add(
      await http.MultipartFile.fromPath('attachment[att_file]', img_file.path),
    );

    try {
      final response =
          await request.send().timeout(Duration(seconds: 30), onTimeout: () {
        throw TimeoutException("API request timed out");
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = await http.Response.fromStream(response);
        return json.decode(res.body);
      }
    } catch (e) {
      print(e.toString());
      return Response(statusCode: 1, statusText: e.toString());
    }
  }
}
