import 'package:dio/dio.dart';

import '../../constants/strings.dart';

class PlacesWebServices {
  late Dio _dio; //declare Dio

//init Dio when this constructor called
  PlacesWebServices() {
    BaseOptions options = BaseOptions(
      connectTimeout: 20 * 1000,
      receiveTimeout: 20 * 1000,
      receiveDataWhenStatusError: true,
    );

    //init Dio
    _dio = Dio(options);
  }

//Every search Query will create new sessionToken
  Future<List<dynamic>> fetchSuggestionPlaces(
      String place, String sessionToken) async {
    try {
      Response response = await _dio.get(suggestionBaseURL, queryParameters: {
        'input': place,
        'types': 'address',
        'key': googleAPIKey,
        'sessiontoken': sessionToken,
        'components': 'country:eg',
      });
      print(response.statusCode);
      print('predictions${response.data['predictions']}');
      return response.data['predictions'];
    } catch (error) {
      print('fetchSuggestionPlaces $error');
      rethrow;
    }
  }
}