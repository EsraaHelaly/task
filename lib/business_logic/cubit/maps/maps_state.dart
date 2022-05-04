part of 'maps_cubit.dart';

@immutable
abstract class MapsState {}

class MapsInitial extends MapsState {}

class PlacesLoaded extends MapsState {
  final List<PlaceSuggestionModel> places;

  PlacesLoaded(this.places);
}

class PlaceDetailsLoaded extends MapsState {
  final PlaceDetailsModel place;

  PlaceDetailsLoaded(this.place);
}

class DirectionsLoaded extends MapsState {
  final PlaceDirections placeDirections;

  DirectionsLoaded(this.placeDirections);
}
