import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:task/business_logic/cubit/maps/maps_cubit.dart';
import 'package:task/constants/colors.dart';
import 'package:task/data/models/place_suggestion_model.dart';
import 'package:task/helper/location_helper.dart';
import 'package:task/persentation/widgets/my_drawer.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/place_details_model.dart';
import '../widgets/place_item.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationHelper _locationHelper = LocationHelper();

  final Completer<GoogleMapController> _mapController = Completer();

  final FloatingSearchBarController _floatingSearchBarController =
      FloatingSearchBarController();

  static Position? _position;

  List<PlaceSuggestionModel> suggestionsPlacesList = [];

  static final CameraPosition _myCurrentLocationCameraPosition = CameraPosition(
    target: LatLng(_position!.latitude, _position!.longitude),
    bearing: 0.0,
    zoom: 17,
    tilt: 0.0,
  );

  //Variables for getPlaceLocation

  //A collection of objects in which each object can occur only once.
  final Set<Marker> _markers = {};
  late PlaceSuggestionModel _placeSuggestionModel;
  late PlaceDetailsModel _selectedPlaceModel;
  late Marker _searchedMarker;
  late Marker _currentMarker;

  late CameraPosition _goToSearchedForPlaceCameraPosition;

  void _buildCameraNewPosition() {
    _goToSearchedForPlaceCameraPosition = CameraPosition(
      target: LatLng(
        _selectedPlaceModel.result.geometry.location.lat,
        _selectedPlaceModel.result.geometry.location.lat,
      ),
      zoom: 13,
      bearing: 0.0,
      tilt: 0.0,
    );
  }

  @override
  initState() {
    super.initState();
    _getMyCurrentLocation();
  }

  Future<void> _getMyCurrentLocation() async {
    _position = await _locationHelper.detectCurrentLocation().whenComplete((() {
      setState(() {});
    }));
  }

  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition: _myCurrentLocationCameraPosition,
      myLocationEnabled: true,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      onMapCreated: (GoogleMapController googleMapController) {
        _mapController.complete(googleMapController);
      },
      markers: _markers,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _position != null
              ? _buildMap()
              : const Center(child: CircularProgressIndicator()),
          _buildFloatingSearchBar(),
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 30, right: 8),
        child: FloatingActionButton(
          onPressed: _goToMyCurrentLocation,
          child: const Icon(Icons.place, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _goToMyCurrentLocation() async {
    //when camera completed
    final GoogleMapController _googleMapController =
        await _mapController.future;
    _googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(_myCurrentLocationCameraPosition));
  }

  Widget _buildFloatingSearchBar() {
    final _isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      builder: (BuildContext context, Animation<double> transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              buildSuggestionsBloc(),
              _buildSelectedPlaceLocationBloc(),
            ],
          ),
        );
      },
      controller: _floatingSearchBarController,
      elevation: 6,
      hintStyle: const TextStyle(fontSize: 16),
      hint: 'Find a place..',
      queryStyle: const TextStyle(fontSize: 16),
      margins: const EdgeInsets.fromLTRB(20, 70, 20, 0),
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      height: 52,
      iconColor: MyColors.blue,
      transitionDuration: const Duration(milliseconds: 600),
      debounceDelay: const Duration(milliseconds: 500),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: _isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: _isPortrait ? 600 : 500,

      //invoked when each char is changed in query
      onQueryChanged: (query) {
        _getPlaceSuggestions(query);
      },
      onFocusChanged: (_) {},
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.place, color: Colors.grey),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget buildSuggestionsBloc() {
    return BlocBuilder<MapsCubit, MapsState>(
      builder: (context, state) {
        if (state is PlacesLoaded) {
          suggestionsPlacesList = (state).places;
          if (suggestionsPlacesList.isNotEmpty) {
            return _buildPlacesList();
          } else {
            return Container();
          }
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildPlacesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: suggestionsPlacesList.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () async {
            //get placeId of the tapped item in the list
            _placeSuggestionModel = suggestionsPlacesList[index];
            _floatingSearchBarController.close();
            _getSelectedPlaceLocation();
          },
          child: BuildPlaceItem(suggestion: suggestionsPlacesList[index]),
        );
      },
    );
  }

  void _getPlaceSuggestions(String query) {
    //generate unique sessionToken
    final sessionToken = const Uuid().v4();

    BlocProvider.of<MapsCubit>(context)
        .emitSuggestionsPlaces(query, sessionToken);
  }

  void _getSelectedPlaceLocation() {
    final sessionToken = const Uuid().v4();
    BlocProvider.of<MapsCubit>(context)
        .emitPlaceLocation(_placeSuggestionModel.placeId, sessionToken);
  }

  Widget _buildSelectedPlaceLocationBloc() {
    return BlocListener<MapsCubit, MapsState>(
      listener: (context, state) {
        if (state is PlaceDetailsLoaded) {
          _selectedPlaceModel = (state).place;

          _goToMySearchedForLocation();
        }
      },
      child: Container(),
    );
  }

  Future<void> _goToMySearchedForLocation() async {
    _buildCameraNewPosition();
    //to controll map
    final GoogleMapController _googleMapController =
        await _mapController.future;
    _googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(_goToSearchedForPlaceCameraPosition));

    _buildSearchedPlaceMarker();
  }

  void _buildSearchedPlaceMarker() {
    _searchedMarker = Marker(
      markerId: const MarkerId('2'),
      infoWindow: InfoWindow(title: _placeSuggestionModel.description),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      position: _goToSearchedForPlaceCameraPosition.target,
      onTap: _buildCurrentLocationMarker,
    );

    _addMarkerToMarkersSetAndUpdateUI(_searchedMarker);
  }

  void _buildCurrentLocationMarker() {
    _currentMarker = Marker(
      markerId: const MarkerId('1'),
      infoWindow: const InfoWindow(title: 'My Current Location'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      position: LatLng(_position!.latitude, _position!.longitude),
      onTap: () {},
    );
    _addMarkerToMarkersSetAndUpdateUI(_currentMarker);
  }

  void _addMarkerToMarkersSetAndUpdateUI(Marker marker) {
    setState(() {
      _markers.add(marker);
    });
  }
}
