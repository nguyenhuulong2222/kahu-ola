import 'app_constants.dart';

/// All 12 API endpoint constants — "Space to Abyss" data matrix
class ApiEndpoints {
  ApiEndpoints._();

  static const String _base = '${AppConstants.baseUrl}/${AppConstants.apiVersion}';

  // ── SPACE ────────────────────────────────────────────────────────────────
  /// GOES-West / Sentinel-2: Wildfire detection from geostationary orbit
  static const String goesWest = '$_base/space/goes-west';
  static const String sentinel2 = '$_base/space/sentinel2';

  // ── SUMMIT ───────────────────────────────────────────────────────────────
  /// MesoWest / RAWS: Haleakalā wind gusts & fuel moisture
  static const String mesoWest = '$_base/summit/mesowest';
  static const String raws = '$_base/summit/raws';

  // ── LAND ─────────────────────────────────────────────────────────────────
  /// NASA FIRMS: Real-time fire hotspots
  static const String nasaFirms = '$_base/land/nasa-firms';
  /// AirNow: Air quality index / Vog
  static const String airNow = '$_base/land/airnow';

  // ── COAST ────────────────────────────────────────────────────────────────
  /// USGS: Flash flood warnings from upstream
  static const String usgsFlood = '$_base/coast/usgs-flood';
  /// PacIOOS (Coast): Harbor inundation
  static const String pacioosCoast = '$_base/coast/pacioos-harbor';

  // ── ABYSS ────────────────────────────────────────────────────────────────
  /// ALOHA: Deep-sea pressure (4,800 m) for tsunami early-warning
  static const String alohaDeep = '$_base/abyss/aloha';
  /// PacIOOS (Abyss): Offshore currents & tidal surge
  static const String pacioosAbyss = '$_base/abyss/pacioos-ocean';

  // ── ALERT / AI ───────────────────────────────────────────────────────────
  /// NWS api.weather.gov — Alert Buddy
  static const String nwsAlerts = '$_base/alerts/nws';
  /// AI Translation endpoint — Translate Alerts (T1)
  static const String translateAlerts = '$_base/alerts/translate';
}
