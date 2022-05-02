import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:task/data/models/place_details_model.dart';
import 'package:task/data/models/place_suggestion_model.dart';
import 'package:task/data/repository/maps_repo.dart';

part 'maps_state.dart';

class MapsCubit extends Cubit<MapsState> {
  final MapsRepo _mapsRepo;
  MapsCubit(this._mapsRepo) : super(MapsInitial());

  void emitSuggestionsPlaces(String place, String sessionToken) {
    _mapsRepo
        .fetchSuggestionPlaces(place, sessionToken)
        .then((suggestions) => emit(PlacesLoaded(suggestions)));
  }

  void emitPlaceLocation(String placeId, String sessionToken) {
    _mapsRepo
        .getPlaceLocation(placeId, sessionToken)
        .then((place) => emit(PlaceDetailsLoaded(place)));
  }
}
