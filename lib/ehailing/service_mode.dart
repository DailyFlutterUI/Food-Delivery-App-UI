import 'package:flutter/material.dart';

/// The three services the app offers. Each owns a single accent colour so the
/// whole UI recolours when you switch — one accent at a time, never more.
enum ServiceMode { ride, delivery, intercity }

/// An option shown as a selectable card inside a mode (a vehicle, a parcel
/// size, a seat class…).
class ServiceOption {
  const ServiceOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.eta,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String price;
  final String eta;
}

/// Everything that makes a mode look and read differently, in one place.
class ModeConfig {
  const ModeConfig({
    required this.mode,
    required this.label,
    required this.icon,
    required this.accent,
    required this.accentSoft,
    required this.tagline,
    required this.priceHint,
    required this.headline,
    required this.originLabel,
    required this.originValue,
    required this.destLabel,
    required this.destHint,
    required this.options,
    required this.cta,
  });

  final ServiceMode mode;
  final String label;
  final IconData icon;

  /// The single accent for this mode and a soft tint of it for fills.
  final Color accent;
  final Color accentSoft;

  /// Shown on the landing card.
  final String tagline;
  final String priceHint;

  final String headline;
  final String originLabel;
  final String originValue;
  final String destLabel;
  final String destHint;
  final List<ServiceOption> options;
  final String cta;

  static const Map<ServiceMode, ModeConfig> all = {
    ServiceMode.ride: ModeConfig(
      mode: ServiceMode.ride,
      label: 'Ride',
      icon: Icons.directions_car_filled_rounded,
      accent: Color(0xFF1C6B5A), // deep teal-green
      accentSoft: Color(0xFFEAF1EE),
      tagline: 'Get there in comfort, any time',
      priceHint: 'From RM 12',
      headline: 'Where to?',
      originLabel: 'Pickup',
      originValue: 'Current location',
      destLabel: 'Destination',
      destHint: 'Search a place',
      cta: 'Confirm ride',
      options: [
        ServiceOption(
          icon: Icons.directions_car_rounded,
          title: 'Economy',
          subtitle: 'Affordable everyday rides',
          price: 'RM 12',
          eta: '3 min',
        ),
        ServiceOption(
          icon: Icons.local_taxi_rounded,
          title: 'Comfort',
          subtitle: 'Newer cars, extra legroom',
          price: 'RM 18',
          eta: '5 min',
        ),
        ServiceOption(
          icon: Icons.airport_shuttle_rounded,
          title: 'XL',
          subtitle: 'Up to 6 seats',
          price: 'RM 26',
          eta: '7 min',
        ),
      ],
    ),
    ServiceMode.delivery: ModeConfig(
      mode: ServiceMode.delivery,
      label: 'Delivery',
      icon: Icons.inventory_2_rounded,
      accent: Color(0xFFC8552B), // terracotta
      accentSoft: Color(0xFFF7ECE6),
      tagline: 'Send parcels across town fast',
      priceHint: 'From RM 8',
      headline: 'Send a package',
      originLabel: 'Pick up from',
      originValue: 'Current location',
      destLabel: 'Deliver to',
      destHint: 'Recipient address',
      cta: 'Find courier',
      options: [
        ServiceOption(
          icon: Icons.description_rounded,
          title: 'Document',
          subtitle: 'Envelopes & papers',
          price: 'RM 8',
          eta: '15 min',
        ),
        ServiceOption(
          icon: Icons.shopping_bag_rounded,
          title: 'Small',
          subtitle: 'Fits a backpack',
          price: 'RM 14',
          eta: '20 min',
        ),
        ServiceOption(
          icon: Icons.inventory_rounded,
          title: 'Large',
          subtitle: 'Boxes up to 20 kg',
          price: 'RM 22',
          eta: '30 min',
        ),
      ],
    ),
    ServiceMode.intercity: ModeConfig(
      mode: ServiceMode.intercity,
      label: 'Intercity',
      icon: Icons.alt_route_rounded,
      accent: Color(0xFF2F4A8C), // deep indigo-blue
      accentSoft: Color(0xFFEAEDF5),
      tagline: 'Travel between cities your way',
      priceHint: 'From RM 35',
      headline: 'Travel between cities',
      originLabel: 'From',
      originValue: 'Kuala Lumpur',
      destLabel: 'To',
      destHint: 'Choose a city',
      cta: 'Search trips',
      options: [
        ServiceOption(
          icon: Icons.event_seat_rounded,
          title: 'Shared',
          subtitle: 'One seat, depart when full',
          price: 'RM 35',
          eta: 'Today',
        ),
        ServiceOption(
          icon: Icons.directions_car_filled_rounded,
          title: 'Private',
          subtitle: 'Whole car, your schedule',
          price: 'RM 120',
          eta: 'Today',
        ),
        ServiceOption(
          icon: Icons.airport_shuttle_rounded,
          title: 'Van',
          subtitle: 'Groups up to 10',
          price: 'RM 180',
          eta: 'Tomorrow',
        ),
      ],
    ),
  };
}
