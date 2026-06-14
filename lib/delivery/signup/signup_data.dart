import 'dart:ui';

/// A shipping country: its flag, dialing code, and a representative point on the
/// world map (used to aim the zoom animation). Coordinates are lon/lat of a
/// central city, projected on the fly by the map.
class Country {
  const Country({
    required this.flag,
    required this.name,
    required this.iso,
    required this.dial,
    required this.lon,
    required this.lat,
    required this.regions,
  });

  final String flag;
  final String name;
  final String iso;
  final String dial;
  final double lon;
  final double lat;
  final List<Region> regions;

  /// Equirectangular projection → 0..1 normalized position on the map.
  Offset get norm => Offset((lon + 180) / 360, (90 - lat) / 180);
}

/// A shipping zone inside a country: a hub city and a delivery estimate.
class Region {
  const Region({required this.name, required this.hub, required this.eta});
  final String name;
  final String hub; // primary sorting hub
  final String eta; // delivery estimate
}

/// A curated set of shipping countries, spread across the globe so the zoom
/// always travels a satisfying distance. Each carries three real shipping zones.
const List<Country> kCountries = [
  Country(
    flag: '🇺🇸',
    name: 'United States',
    iso: 'US',
    dial: '+1',
    lon: -98,
    lat: 39,
    regions: [
      Region(name: 'West Coast', hub: 'Los Angeles, CA', eta: '1–2 days'),
      Region(name: 'Midwest', hub: 'Chicago, IL', eta: '2–3 days'),
      Region(name: 'East Coast', hub: 'New York, NY', eta: '1–2 days'),
    ],
  ),
  Country(
    flag: '🇨🇦',
    name: 'Canada',
    iso: 'CA',
    dial: '+1',
    lon: -106,
    lat: 56,
    regions: [
      Region(name: 'Pacific', hub: 'Vancouver, BC', eta: '2–3 days'),
      Region(name: 'Central', hub: 'Toronto, ON', eta: '1–2 days'),
      Region(name: 'Atlantic', hub: 'Halifax, NS', eta: '3–4 days'),
    ],
  ),
  Country(
    flag: '🇧🇷',
    name: 'Brazil',
    iso: 'BR',
    dial: '+55',
    lon: -51,
    lat: -10,
    regions: [
      Region(name: 'Sudeste', hub: 'São Paulo', eta: '1–2 days'),
      Region(name: 'Nordeste', hub: 'Recife', eta: '3–4 days'),
      Region(name: 'Sul', hub: 'Porto Alegre', eta: '2–3 days'),
    ],
  ),
  Country(
    flag: '🇬🇧',
    name: 'United Kingdom',
    iso: 'GB',
    dial: '+44',
    lon: -1.5,
    lat: 53,
    regions: [
      Region(name: 'England', hub: 'London', eta: 'Next day'),
      Region(name: 'Scotland', hub: 'Glasgow', eta: '1–2 days'),
      Region(name: 'Wales', hub: 'Cardiff', eta: '1–2 days'),
    ],
  ),
  Country(
    flag: '🇫🇷',
    name: 'France',
    iso: 'FR',
    dial: '+33',
    lon: 2.3,
    lat: 46.5,
    regions: [
      Region(name: 'Île-de-France', hub: 'Paris', eta: 'Next day'),
      Region(name: 'Sud', hub: 'Marseille', eta: '1–2 days'),
      Region(name: 'Ouest', hub: 'Nantes', eta: '1–2 days'),
    ],
  ),
  Country(
    flag: '🇩🇪',
    name: 'Germany',
    iso: 'DE',
    dial: '+49',
    lon: 10,
    lat: 51,
    regions: [
      Region(name: 'Nord', hub: 'Hamburg', eta: 'Next day'),
      Region(name: 'West', hub: 'Cologne', eta: 'Next day'),
      Region(name: 'Süd', hub: 'Munich', eta: '1–2 days'),
    ],
  ),
  Country(
    flag: '🇦🇪',
    name: 'United Arab Emirates',
    iso: 'AE',
    dial: '+971',
    lon: 54,
    lat: 24,
    regions: [
      Region(name: 'Dubai', hub: 'Dubai', eta: 'Same day'),
      Region(name: 'Abu Dhabi', hub: 'Abu Dhabi', eta: 'Next day'),
      Region(name: 'Sharjah', hub: 'Sharjah', eta: 'Next day'),
    ],
  ),
  Country(
    flag: '🇸🇦',
    name: 'Saudi Arabia',
    iso: 'SA',
    dial: '+966',
    lon: 45,
    lat: 24,
    regions: [
      Region(name: 'Riyadh', hub: 'Riyadh', eta: 'Same day'),
      Region(name: 'Makkah', hub: 'Jeddah', eta: 'Next day'),
      Region(name: 'Eastern', hub: 'Dammam', eta: '1–2 days'),
    ],
  ),
  Country(
    flag: '🇳🇬',
    name: 'Nigeria',
    iso: 'NG',
    dial: '+234',
    lon: 8,
    lat: 9.5,
    regions: [
      Region(name: 'South West', hub: 'Lagos', eta: '1–2 days'),
      Region(name: 'Federal Capital', hub: 'Abuja', eta: '2–3 days'),
      Region(name: 'South East', hub: 'Port Harcourt', eta: '2–3 days'),
    ],
  ),
  Country(
    flag: '🇿🇦',
    name: 'South Africa',
    iso: 'ZA',
    dial: '+27',
    lon: 24,
    lat: -29,
    regions: [
      Region(name: 'Gauteng', hub: 'Johannesburg', eta: 'Next day'),
      Region(name: 'Western Cape', hub: 'Cape Town', eta: '1–2 days'),
      Region(name: 'KwaZulu-Natal', hub: 'Durban', eta: '1–2 days'),
    ],
  ),
  Country(
    flag: '🇮🇳',
    name: 'India',
    iso: 'IN',
    dial: '+91',
    lon: 78,
    lat: 22,
    regions: [
      Region(name: 'North', hub: 'Delhi', eta: '1–2 days'),
      Region(name: 'West', hub: 'Mumbai', eta: 'Next day'),
      Region(name: 'South', hub: 'Bengaluru', eta: '1–2 days'),
    ],
  ),
  Country(
    flag: '🇨🇳',
    name: 'China',
    iso: 'CN',
    dial: '+86',
    lon: 104,
    lat: 35,
    regions: [
      Region(name: 'East', hub: 'Shanghai', eta: 'Next day'),
      Region(name: 'South', hub: 'Shenzhen', eta: 'Next day'),
      Region(name: 'North', hub: 'Beijing', eta: '1–2 days'),
    ],
  ),
  Country(
    flag: '🇯🇵',
    name: 'Japan',
    iso: 'JP',
    dial: '+81',
    lon: 138,
    lat: 37,
    regions: [
      Region(name: 'Kantō', hub: 'Tokyo', eta: 'Same day'),
      Region(name: 'Kansai', hub: 'Osaka', eta: 'Next day'),
      Region(name: 'Kyūshū', hub: 'Fukuoka', eta: '1–2 days'),
    ],
  ),
  Country(
    flag: '🇸🇬',
    name: 'Singapore',
    iso: 'SG',
    dial: '+65',
    lon: 103.8,
    lat: 1.35,
    regions: [
      Region(name: 'Central', hub: 'Downtown Core', eta: 'Same day'),
      Region(name: 'East', hub: 'Changi', eta: 'Same day'),
      Region(name: 'West', hub: 'Jurong', eta: 'Same day'),
    ],
  ),
  Country(
    flag: '🇲🇾',
    name: 'Malaysia',
    iso: 'MY',
    dial: '+60',
    lon: 102,
    lat: 4,
    regions: [
      Region(name: 'Klang Valley', hub: 'Kuala Lumpur', eta: 'Next day'),
      Region(name: 'Northern', hub: 'Penang', eta: '1–2 days'),
      Region(name: 'Borneo', hub: 'Kota Kinabalu', eta: '2–3 days'),
    ],
  ),
  Country(
    flag: '🇮🇩',
    name: 'Indonesia',
    iso: 'ID',
    dial: '+62',
    lon: 113,
    lat: -2,
    regions: [
      Region(name: 'Jawa', hub: 'Jakarta', eta: 'Next day'),
      Region(name: 'Bali', hub: 'Denpasar', eta: '1–2 days'),
      Region(name: 'Sumatra', hub: 'Medan', eta: '2–3 days'),
    ],
  ),
  Country(
    flag: '🇦🇺',
    name: 'Australia',
    iso: 'AU',
    dial: '+61',
    lon: 134,
    lat: -25,
    regions: [
      Region(name: 'New South Wales', hub: 'Sydney', eta: 'Next day'),
      Region(name: 'Victoria', hub: 'Melbourne', eta: 'Next day'),
      Region(name: 'Queensland', hub: 'Brisbane', eta: '1–2 days'),
    ],
  ),
];
