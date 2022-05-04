import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:task/data/models/place_details_model.dart';
import 'package:task/data/models/place_directions.dart';
import 'package:task/data/models/place_suggestion_model.dart';
import 'package:task/data/web_services/places_web_services.dart';

class MapsRepo {
  final PlacesWebServices _placesWebServices;

  MapsRepo(this._placesWebServices);

  Future<List<PlaceSuggestionModel>> fetchSuggestionPlaces(
      String place, String sessionToken) async {
    final suggestions =
        await _placesWebServices.fetchSuggestionPlaces(place, sessionToken);

    return suggestions
        .map((suggestion) => PlaceSuggestionModel.fromJson(suggestion))
        .toList();
  }

  Future<PlaceDetailsModel> getPlaceLocation(
      String placeId, String sessionToken) async {
    final place =
        await _placesWebServices.getPlaceLocation(placeId, sessionToken);

    return PlaceDetailsModel.fromJson(place);
  }

  Future<PlaceDirections> getDirections(
      LatLng origin, LatLng destination) async {
    final directions =
        await _placesWebServices.getDirections(origin, destination);

    return PlaceDirections.fromJson(directions);
  }
}
