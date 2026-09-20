import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../API/firebase_manager.dart';
import '../../Services/location_services.dart';

sealed class HomeEvent {}

final class HomeStarted extends HomeEvent {}

final class HomeDestinationSelected extends HomeEvent {
  HomeDestinationSelected(this.destination);

  final LatLng destination;
}

final class HomeDestinationSearched extends HomeEvent {
  HomeDestinationSearched(this.address);

  final String address;
}

enum HomeStatus {
  initial,
  loading,
  ready,
  routeLoading,
  routeReady,
  searchLoading,
  failure,
}

class HomeState {
  const HomeState({
    this.status = HomeStatus.initial,
    this.userName,
    this.currentLocation,
    this.destination,
    this.routePoints = const [],
    this.distance = 0,
    this.errorMessage,
    this.cameraTarget,
    this.cameraUpdateId = 0,
  });

  final HomeStatus status;
  final String? userName;
  final Position? currentLocation;
  final LatLng? destination;
  final List<LatLng> routePoints;
  final double distance;
  final String? errorMessage;
  final LatLng? cameraTarget;
  final int cameraUpdateId;

  HomeState copyWith({
    HomeStatus? status,
    String? userName,
    Position? currentLocation,
    LatLng? destination,
    List<LatLng>? routePoints,
    double? distance,
    String? errorMessage,
    LatLng? cameraTarget,
    int? cameraUpdateId,
    bool clearDestination = false,
    bool clearError = false,
    bool clearCameraTarget = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      userName: userName ?? this.userName,
      currentLocation: currentLocation ?? this.currentLocation,
      destination: clearDestination ? null : destination ?? this.destination,
      routePoints: routePoints ?? this.routePoints,
      distance: distance ?? this.distance,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      cameraTarget: clearCameraTarget
          ? null
          : cameraTarget ?? this.cameraTarget,
      cameraUpdateId: cameraUpdateId ?? this.cameraUpdateId,
    );
  }
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeDestinationSelected>(_onDestinationSelected);
    on<HomeDestinationSearched>(_onDestinationSearched);
  }

  Future<void> _onStarted(
    HomeStarted event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: HomeStatus.loading, clearError: true));
    try {
      final results = await Future.wait([
        FirebaseManager.getUserName(),
        LocationServices.getCurrentLocation(),
      ]);

      emit(
        state.copyWith(
          status: HomeStatus.ready,
          userName: results[0] as String?,
          currentLocation: results[1] as Position?,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDestinationSelected(
    HomeDestinationSelected event,
    Emitter<HomeState> emit,
  ) async {
    final currentLocation = state.currentLocation;
    if (currentLocation == null) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: 'Current location is not available',
        ),
      );
      return;
    }

    emit(state.copyWith(status: HomeStatus.routeLoading, clearError: true));
    try {
      final start = LatLng(
        currentLocation.latitude,
        currentLocation.longitude,
      );
      final route = await LocationServices.getRoute(start, event.destination);
      final distance = await LocationServices.getDistance(
        start,
        event.destination,
      );

      emit(
        state.copyWith(
          status: HomeStatus.routeReady,
          destination: event.destination,
          routePoints: route,
          distance: distance,
          clearError: true,
          clearCameraTarget: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDestinationSearched(
    HomeDestinationSearched event,
    Emitter<HomeState> emit,
  ) async {
    final address = event.address.trim();
    if (address.isEmpty) return;

    emit(state.copyWith(status: HomeStatus.searchLoading, clearError: true));
    try {
      final locations = await locationFromAddress(address);
      if (locations.isEmpty) {
        emit(
          state.copyWith(
            status: HomeStatus.failure,
            errorMessage: 'No location found',
          ),
        );
        return;
      }

      final location = locations.first;
      final destination = LatLng(location.latitude, location.longitude);

      await _loadRouteForDestination(destination, emit, moveCamera: true);
    } catch (e) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _loadRouteForDestination(
    LatLng destination,
    Emitter<HomeState> emit, {
    required bool moveCamera,
  }) async {
    final currentLocation = state.currentLocation;
    if (currentLocation == null) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: 'Current location is not available',
        ),
      );
      return;
    }

    final start = LatLng(currentLocation.latitude, currentLocation.longitude);
    final route = await LocationServices.getRoute(start, destination);
    final distance = await LocationServices.getDistance(start, destination);

    emit(
      state.copyWith(
        status: HomeStatus.routeReady,
        destination: destination,
        routePoints: route,
        distance: distance,
        cameraTarget: moveCamera ? destination : null,
        cameraUpdateId: moveCamera
            ? state.cameraUpdateId + 1
            : state.cameraUpdateId,
        clearError: true,
        clearCameraTarget: !moveCamera,
      ),
    );
  }
}
