import '../models/user_profile.dart';
import '../models/trip.dart';
import '../models/booking.dart';

/// Global flag to check if we are in mock mode
bool isMockMode = true;

class MockData {
  static final UserProfile passengerProfile = UserProfile(
    id: 'mock-passenger-id',
    fullName: 'Alhassane Bangoura (Démo)',
    email: 'passager@demo.gn',
    phone: '620 00 00 01',
    role: 'passenger',
    createdAt: DateTime.now(),
  );

  static final UserProfile driverProfile = UserProfile(
    id: 'mock-driver-id',
    fullName: 'Mamadou Chauffeur (Démo)',
    email: 'chauffeur@demo.gn',
    phone: '620 00 00 02',
    role: 'driver',
    createdAt: DateTime.now(),
  );

  static final UserProfile syndicateProfile = UserProfile(
    id: 'mock-syndicate-id',
    fullName: 'Diallo Syndicat (Démo)',
    email: 'syndicat@demo.gn',
    phone: '620 00 00 03',
    role: 'syndicate',
    createdAt: DateTime.now(),
  );

  static final UserProfile stationAdminProfile = UserProfile(
    id: 'mock-gare-id',
    fullName: 'Barry Admin Gare (Démo)',
    email: 'gare@demo.gn',
    phone: '620 00 00 04',
    role: 'station_admin',
    createdAt: DateTime.now(),
  );

  static final List<Trip> trips = [
    Trip(
      id: 'trip-1',
      routeId: 'route-1',
      departureCityName: 'Conakry',
      arrivalCityName: 'Mamou',
      departureStationName: 'Gare de Bambéto',
      arrivalStationName: 'Gare de Mamou',
      departureTime: DateTime.now().add(const Duration(hours: 2)),
      price: 90000,
      availableSeats: 12,
      vehicleType: 'Minibus',
      status: 'scheduled',
      amenities: ['Clim', 'WiFi'],
    ),
    Trip(
      id: 'trip-2',
      routeId: 'route-2',
      departureCityName: 'Conakry',
      arrivalCityName: 'Labé',
      departureStationName: 'Gare de Madina',
      arrivalStationName: 'Gare de Labé',
      departureTime: DateTime.now().add(const Duration(hours: 5)),
      price: 150000,
      availableSeats: 5,
      vehicleType: 'Car',
      status: 'boarding',
      amenities: ['Clim', 'TV'],
    ),
    Trip(
      id: 'trip-3',
      routeId: 'route-3',
      departureCityName: 'Kindia',
      arrivalCityName: 'Conakry',
      departureStationName: 'Gare de Kindia',
      arrivalStationName: 'KM36',
      departureTime: DateTime.now().add(const Duration(days: 1)),
      price: 60000,
      availableSeats: 22,
      vehicleType: 'Bus',
      status: 'scheduled',
    ),
  ];

  static final List<Booking> bookings = [
    Booking(
      id: 'booking-1',
      tripId: 'trip-1',
      userId: 'mock-passenger-id',
      seats: 1,
      totalPrice: 90000,
      status: 'confirmed',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      departureCityName: 'Conakry',
      arrivalCityName: 'Mamou',
      departureStationName: 'Gare de Bambéto',
      arrivalStationName: 'Gare de Mamou',
      departureTime: DateTime.now().add(const Duration(hours: 2)),
      ticket: const Ticket(
        id: 'ticket-1',
        bookingId: 'booking-1',
        qrCode: 'GT-DEMO-001',
        status: 'valid',
      ),
    ),
  ];
}
