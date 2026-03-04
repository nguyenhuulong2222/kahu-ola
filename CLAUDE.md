# CLAUDE.md — Kahu Ola V4.3.1
# Claude Code will read this file automatically on project open.
# This file is the single source of truth for all implementation tasks.

---

## PROJECT IDENTITY

- **Name:** Kahu Ola ("Guardian of Life")
- **Version:** V4.3.1
- **Type:** Civic Hazard Intelligence Platform — Wildfire-first, Maui County, Hawaii
- **Domain:** kahuola.org (Cloudflare DNS + GitHub Pages + Cloudflare Worker)
- **Contact:** long@kahuola.org

## REPO STATE (as of 2026-03-02)

Already in repo:
- `index.html` — landing page
- `privacy.html` — privacy policy
- `support.html` — support page
- `styles.css` — shared stylesheet

**Does NOT exist yet (Claude Code must create):**
- `live-map.html`
- `layers.config.js`
- `worker/` (entire folder)

---

## ARCHITECTURE — READ BEFORE WRITING ANY CODE

### Deploy model
```
GitHub Pages  →  Cloudflare (DNS + Proxy)  →  kahuola.org
                      ↓
              Cloudflare Worker handles:
              kahuola.org/api/tiles/*
```

### The single most important rule
**The browser NEVER calls upstream APIs directly.**
All data calls go through `/api/tiles/*` only.
The Worker is the only code that knows about NASA/NOAA/EPA upstream URLs.

### Non-negotiable invariants (from V4.3.1 doctrine)
| # | Rule |
|---|------|
| I | Client has zero knowledge of upstream API URLs |
| II | UI renders correctly under ALL failure conditions |
| III | On any data error → return empty, never partial |
| IV | Zero PII — no GPS stored, no user ID, ever |
| V | Estimated perimeter ALWAYS shows amber "ESTIMATED" badge |

---

## TASK LIST — PRIORITY ORDER

Claude Code must complete these tasks in order. Do not skip ahead.

---

### TASK 1 (HIGHEST PRIORITY) — live-map.html + layers.config.js

**Goal:** Interactive hazard map live at kahuola.org/live-map.html

#### 1A. Create `layers.config.js` in repo root

This is the layer registry. All `endpointUrl` values are relative paths — they resolve to `kahuola.org/api/tiles/*`. Zero upstream domains. Zero API keys.

```javascript
// layers.config.js — Kahu Ola V4.3.1 Layer Library
window.KAHUOLA_LAYERS_CONFIG = {
  portal: {
    defaultMode: "lite",
    modes: {
      lite: { bounds: { sw: [18.0, -161.0], ne: [23.0, -154.0] }, initialZoom: 9, maxZoom: 14, label: "Maui Focus" },
      full: { bounds: null, initialZoom: 7, maxZoom: 18, label: "Hawaii Full" }
    }
  },
  layers: [
    // FIRE
    { id: "firms", tab: "Fire", label: "NASA Fire Hotspots", type: "wms",
      endpointUrl: "/api/tiles/wms/firms",
      wmsParams: { SERVICE: "WMS", VERSION: "1.1.1", REQUEST: "GetMap", LAYERS: "fires_viirs_24", FORMAT: "image/png", TRANSPARENT: true, CRS: "EPSG:3857" },
      source: { name: "NASA FIRMS", docsUrl: "https://firms.modaps.eosdis.nasa.gov/" },
      latencyHint: "~5–15 min", enabledByDefaultLite: true, enabledByDefaultFull: true,
      legend: { items: [{ color: "#FF4500", label: "VIIRS hotspot" }, { color: "#FF8C00", label: "MODIS hotspot" }] }
    },
    { id: "hms", tab: "Fire", label: "HMS Smoke Polygons", type: "wms",
      endpointUrl: "/api/tiles/wms/hms",
      wmsParams: { SERVICE: "WMS", VERSION: "1.1.1", REQUEST: "GetMap", LAYERS: "smoke_polygons", FORMAT: "image/png", TRANSPARENT: true, CRS: "EPSG:3857" },
      source: { name: "NOAA HMS", docsUrl: "https://www.ospo.noaa.gov/Products/land/hms.html" },
      latencyHint: "~1–3 hr", enabledByDefaultLite: true, enabledByDefaultFull: true,
      legend: { items: [{ color: "rgba(128,128,128,0.5)", label: "Light smoke" }, { color: "rgba(40,40,40,0.85)", label: "Heavy smoke" }] }
    },
    { id: "wfigs", tab: "Fire", label: "NIFC Fire Perimeters", type: "geojson",
      endpointUrl: "/api/tiles/geojson/wfigs",
      source: { name: "NIFC WFIGS", docsUrl: "https://data-nifc.opendata.arcgis.com/" },
      latencyHint: "~1 hr", enabledByDefaultLite: true, enabledByDefaultFull: true,
      style: { color: "#FF4500", fillColor: "#FF6347", fillOpacity: 0.2, weight: 2 },
      legend: { items: [{ color: "#FF4500", label: "Fire perimeter (NIFC)" }] }
    },
    // WEATHER
    { id: "raws", tab: "Weather", label: "RAWS Weather Stations", type: "geojson",
      endpointUrl: "/api/tiles/geojson/raws",
      source: { name: "MesoWest RAWS", docsUrl: "https://mesowest.utah.edu/" },
      latencyHint: "~1 hr", enabledByDefaultLite: false, enabledByDefaultFull: false,
      configured: false,
      legend: { items: [{ color: "#4A90E2", label: "RAWS station" }] }
    },
    // AIR
    { id: "airnow", tab: "Air", label: "EPA AirNow AQI", type: "xyz",
      endpointUrl: "/api/tiles/xyz/airnow/{z}/{x}/{y}.png",
      source: { name: "EPA AirNow", docsUrl: "https://docs.airnowapi.org/" },
      latencyHint: "~1 hr", enabledByDefaultLite: true, enabledByDefaultFull: true,
      legend: { items: [
        { color: "#00E400", label: "Good (0–50)" },
        { color: "#FFFF00", label: "Moderate (51–100)" },
        { color: "#FF7E00", label: "Unhealthy Sensitive (101–150)" },
        { color: "#FF0000", label: "Unhealthy (151–200)" },
        { color: "#8F3F97", label: "Very Unhealthy (201–300)" },
        { color: "#7E0023", label: "Hazardous (301+)" }
      ]}
    },
    // EARTH
    { id: "usgs_quakes", tab: "Earth", label: "USGS Earthquakes", type: "geojson",
      endpointUrl: "/api/tiles/geojson/usgs-quakes",
      source: { name: "USGS Earthquake Hazards", docsUrl: "https://earthquake.usgs.gov/" },
      latencyHint: "Real-time", enabledByDefaultLite: false, enabledByDefaultFull: false,
      configured: false,
      legend: { items: [{ color: "#FF4500", label: "M3+" }] }
    },
    // OCEAN
    { id: "pacioos", tab: "Ocean", label: "PacIOOS Sea Surface Temp", type: "wms",
      endpointUrl: "/api/tiles/wms/pacioos",
      wmsParams: { SERVICE: "WMS", VERSION: "1.1.1", REQUEST: "GetMap", LAYERS: "CRW_SST", FORMAT: "image/png", TRANSPARENT: true, CRS: "EPSG:3857" },
      source: { name: "PacIOOS", docsUrl: "https://www.pacioos.hawaii.edu/" },
      latencyHint: "~24 hr", enabledByDefaultLite: false, enabledByDefaultFull: false,
      legend: { items: [{ color: "#0000FF", label: "Cool" }, { color: "#FF0000", label: "Warm" }] }
    },
    // SATELLITE
    { id: "goes", tab: "Satellite", label: "NOAA GOES-West", type: "wms",
      endpointUrl: "/api/tiles/wms/goes",
      wmsParams: { SERVICE: "WMS", VERSION: "1.1.1", REQUEST: "GetMap", LAYERS: "Mesoscale-2_AirMass_RGB", FORMAT: "image/png", TRANSPARENT: true, CRS: "EPSG:3857" },
      source: { name: "NOAA GOES-West", docsUrl: "https://www.star.nesdis.noaa.gov/goes/" },
      latencyHint: "~10 min", enabledByDefaultLite: false, enabledByDefaultFull: false,
      legend: { items: [{ color: "#CCCCCC", label: "Cloud cover" }] }
    }
  ],
  legalNotices: [
    "Transparency Portal: raw upstream open data visualization only.",
    "Not an official directive. Always follow official emergency alerts.",
    "Kahu Ola is not affiliated with NASA, NOAA, EPA, NIFC, USGS, or any government agency."
  ]
};
```

#### 1B. Create `live-map.html` in repo root

Full requirements:

**Libraries (CDN only, no npm):**
```html
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.js"></script>
<script src="./layers.config.js"></script>
```

**Header:** Copy exact `<header>` markup from `index.html`. Add "Live Map" as first `<li>` in `.nav-links` with `aria-current="page"`.

**Footer:** Copy exact `<footer>` markup from `index.html`.

**Layout:**
- Full-viewport map: `height: calc(100vh - 64px)` (adjust for header)
- Leaflet map fills the map area
- Glass panel: `position: absolute; right: 16px; top: 16px; width: 360px; max-height: calc(100vh - 100px); overflow-y: auto; z-index: 1000; background: rgba(255,255,255,0.95); backdrop-filter: blur(12px); border-radius: 12px; box-shadow: 0 4px 24px rgba(0,0,0,0.15); padding: 16px;`

**Glass panel contents (top to bottom):**
1. Mode toggle: `[Maui Focus] [Hawaii Full]` — persisted to `localStorage('kahuola_map_mode')`
2. Tab bar: `Fire | Weather | Air | Earth | Ocean | Satellite` — ARIA tablist
3. Tab content: layer rows for current tab
4. Legend section: items for all active layers

**Each layer row:**
```html
<label class="layer-row">
  <input type="checkbox" id="toggle-{id}">
  <div class="layer-info">
    <span class="layer-label">{label}</span>
    <span class="layer-source">{source.name} · {latencyHint}</span>
  </div>
  <span class="status-chip" id="status-{id}" aria-label="Layer status">···</span>
</label>
```

**Status chip states:**
| State | Text | Color |
|-------|------|-------|
| configured: false | Not configured | gray |
| health = true | ● Live | green |
| health = false | Unavailable | red |
| fetch error | ⚠ Error | amber |
| unknown | ··· | gray |

**JavaScript — full implementation:**

```javascript
// 1. Init map
const map = L.map('map');
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
  attribution: '© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
  maxZoom: 19
}).addTo(map);

// 2. Load config
const config = window.KAHUOLA_LAYERS_CONFIG;

// 3. Mode management
let currentMode = localStorage.getItem('kahuola_map_mode') || config.portal.defaultMode;
function applyMode(mode) {
  currentMode = mode;
  localStorage.setItem('kahuola_map_mode', mode);
  const m = config.portal.modes[mode];
  if (m.bounds) {
    map.fitBounds([m.bounds.sw, m.bounds.ne]);
  } else {
    map.setView([20.8, -156.3], m.initialZoom);
  }
  map.options.maxZoom = m.maxZoom;
  updateModeButtons();
  refreshDefaultLayers(mode);
}

// 4. Layer management — track active Leaflet layers
const activeLeafletLayers = {};

function addLayer(layerDef) {
  if (activeLeafletLayers[layerDef.id]) return;
  try {
    let leafletLayer;
    if (layerDef.type === 'wms') {
      leafletLayer = L.tileLayer.wms(layerDef.endpointUrl, {
        ...layerDef.wmsParams,
        tileSize: 256,
        opacity: 0.8,
      });
    } else if (layerDef.type === 'xyz') {
      const url = layerDef.endpointUrl
        .replace('{z}', '{z}').replace('{x}', '{x}').replace('{y}', '{y}');
      leafletLayer = L.tileLayer(url, { tileSize: 256, opacity: 0.8 });
    } else if (layerDef.type === 'geojson') {
      fetch(layerDef.endpointUrl)
        .then(r => { if (!r.ok) throw new Error(r.status); return r.json(); })
        .then(data => {
          leafletLayer = L.geoJSON(data, { style: layerDef.style || {} });
          leafletLayer.addTo(map);
          activeLeafletLayers[layerDef.id] = leafletLayer;
          updateLegend();
        })
        .catch(() => setStatusChip(layerDef.id, 'error'));
      return;
    }
    if (leafletLayer) {
      leafletLayer.addTo(map);
      activeLeafletLayers[layerDef.id] = leafletLayer;
      updateLegend();
    }
  } catch (e) {
    setStatusChip(layerDef.id, 'error');
  }
}

function removeLayer(id) {
  if (activeLeafletLayers[id]) {
    map.removeLayer(activeLeafletLayers[id]);
    delete activeLeafletLayers[id];
    updateLegend();
  }
}

// 5. Health check — fail silently
async function checkHealth() {
  try {
    const res = await fetch('/api/tiles/health', { signal: AbortSignal.timeout(5000) });
    if (!res.ok) throw new Error('health check failed');
    const data = await res.json();
    config.layers.forEach(layer => {
      if (layer.configured === false) return; // skip — already "Not configured"
      const up = data.upstreams && data.upstreams[layer.id];
      setStatusChip(layer.id, up ? 'live' : 'unavailable');
    });
  } catch {
    config.layers.forEach(layer => {
      if (layer.configured !== false) setStatusChip(layer.id, 'unknown');
    });
  }
}

function setStatusChip(id, state) {
  const chip = document.getElementById('status-' + id);
  if (!chip) return;
  const states = {
    live:          { text: '● Live',          color: '#16a34a' },
    unavailable:   { text: '✕ Unavailable',   color: '#dc2626' },
    error:         { text: '⚠ Error',         color: '#d97706' },
    unknown:       { text: '···',             color: '#6b7280' },
    not_configured:{ text: 'Not configured',  color: '#9ca3af' },
  };
  const s = states[state] || states.unknown;
  chip.textContent = s.text;
  chip.style.color = s.color;
  chip.setAttribute('aria-label', 'Layer status: ' + s.text);
}

// 6. Default layers
function refreshDefaultLayers(mode) {
  config.layers.forEach(layer => {
    const checkbox = document.getElementById('toggle-' + layer.id);
    const shouldBeOn = mode === 'lite' ? layer.enabledByDefaultLite : layer.enabledByDefaultFull;
    if (checkbox) checkbox.checked = shouldBeOn;
    if (shouldBeOn) addLayer(layer);
    else removeLayer(layer.id);
  });
}

// 7. Legend
function updateLegend() {
  const legendEl = document.getElementById('map-legend');
  if (!legendEl) return;
  const activeItems = config.layers
    .filter(l => activeLeafletLayers[l.id])
    .flatMap(l => l.legend.items.map(item => ({ ...item, layerLabel: l.label })));
  if (activeItems.length === 0) {
    legendEl.innerHTML = '<p class="legend-empty">No layers active</p>';
    return;
  }
  legendEl.innerHTML = activeItems.map(item =>
    `<div class="legend-item">
      <span class="legend-swatch" style="background:${item.color}"></span>
      <span>${item.label}</span>
    </div>`
  ).join('');
}

// 8. Tab management
let currentTab = 'Fire';
function switchTab(tab) {
  currentTab = tab;
  document.querySelectorAll('[role="tab"]').forEach(t => {
    t.setAttribute('aria-selected', t.dataset.tab === tab ? 'true' : 'false');
  });
  document.querySelectorAll('[role="tabpanel"]').forEach(p => {
    p.hidden = p.dataset.tab !== tab;
  });
}

// 9. Init
document.addEventListener('DOMContentLoaded', () => {
  applyMode(currentMode);
  checkHealth();
  // Set not_configured chips immediately
  config.layers.forEach(layer => {
    if (layer.configured === false) setStatusChip(layer.id, 'not_configured');
  });
});
```

**Legal notice bar** below header (before map):
```html
<div class="legal-bar" role="note">
  ⚠ Not an official government service · Always follow official emergency alerts ·
  <a href="./privacy.html">Privacy</a>
</div>
```

**All errors must be caught** — no error ever breaks page or map rendering.

---

#### 1C. Update existing HTML files

**In `index.html`** — find `.nav-links` ul and add as first item:
```html
<li><a href="./live-map.html">Live Map</a></li>
```

Also add a "View Live Map" button in the hero `.button-row`:
```html
<a class="button button--primary" href="./live-map.html">View Live Map</a>
```
(move the existing primary button to secondary if needed to avoid two primaries)

**In `privacy.html`** — find `.nav-links` ul and add:
```html
<li><a href="./live-map.html">Live Map</a></li>
```

**In `support.html`** — same nav update as privacy.html.

Also update the status board in `index.html` section `id="status"` to reflect V4.3.1 canonical signals. Replace the three static status-items (NASA/NOAA/USGS) with:
```
FireSignal    — NASA FIRMS + NOAA HMS · ~5–15 min
SmokeSignal   — EPA AirNow · ~1 hr  
Perimeter     — NIFC WFIGS · ~1 hr
```

---

### TASK 2 — Cloudflare Worker `/worker/`

Create the full Worker project. This runs server-side on Cloudflare — NOT in the browser.

#### File: `worker/wrangler.toml`
```toml
name = "kahuola-tiles-broker"
main = "src/index.ts"
compatibility_date = "2026-03-02"

[[routes]]
pattern = "kahuola.org/api/tiles/*"
zone_name = "kahuola.org"

# Before deploying, set secrets:
# npx wrangler secret put NASA_FIRMS_MAP_KEY
# npx wrangler secret put AIRNOW_API_KEY
# npx wrangler deploy
```

#### File: `worker/src/index.ts`

Complete TypeScript Worker with:

```typescript
interface Env {
  NASA_FIRMS_MAP_KEY: string;
  AIRNOW_API_KEY: string;
}

// Upstream registry — hardcoded, NEVER from client input
const UPSTREAMS = {
  firms: {
    baseUrl: "https://firms.modaps.eosdis.nasa.gov/mapserver/wms/South_America/",
    cacheTtlSeconds: 300, requiresKey: true, keyParam: "MAP_KEY", keySecret: "NASA_FIRMS_MAP_KEY"
  },
  hms: {
    baseUrl: "https://satepsanone.nesdis.noaa.gov/pub/FIRE/web/HMS/Smoke_Polygons/",
    cacheTtlSeconds: 900, requiresKey: false
  },
  goes: {
    baseUrl: "https://opengeo.ncep.noaa.gov/geoserver/conus/conus_ctp/ows",
    cacheTtlSeconds: 600, requiresKey: false
  },
  pacioos: {
    baseUrl: "https://pae-paha.pacioos.hawaii.edu/thredds/wms/dhw_5km",
    cacheTtlSeconds: 3600, requiresKey: false
  },
  airnow: {
    baseUrl: "https://tiles.airnowtech.org/airnow/today/",
    cacheTtlSeconds: 600, requiresKey: true, keyParam: "api_key", keySecret: "AIRNOW_API_KEY"
  },
  wfigs: {
    baseUrl: "https://services3.arcgis.com/T4QMspbfLg3qTGWY/arcgis/rest/services/WFIGS_Incident_Locations_Current/FeatureServer/0/query",
    cacheTtlSeconds: 600, requiresKey: false
  },
} as const;

const ALLOWED_ORIGIN = "https://kahuola.org";
const UPSTREAM_TIMEOUT_MS = 8000;
```

**Implement these handlers:**

1. **`GET /api/tiles/health`** — returns `{ status: "ok", upstreams: { firms: bool, ... }, generated_at: ISO8601 }`. `true` = secret present (if needed) or no secret needed. Never expose URLs or key values.

2. **`GET /api/tiles/wms/{id}`** — WMS proxy with validation:
   - Validate: `SERVICE=WMS`, `REQUEST` in `{GetMap, GetCapabilities}`
   - If `GetMap`: `WIDTH`/`HEIGHT` ≤ 2048, `FORMAT` in `{image/png, image/jpeg}`, `BBOX` present, `CRS` or `SRS` present
   - Inject key if required. Return 503 if key missing.
   - Fetch upstream with 8s AbortController timeout
   - Cache 200 image/* responses with TTL from config
   - Response header: `X-Kahuola-Cache: HIT|MISS`

3. **`GET /api/tiles/xyz/airnow/{z}/{x}/{y}.png`** — XYZ proxy:
   - Validate z, x, y are integers, z ≤ 18
   - Inject key. 8s timeout. Cache image/*.

4. **`GET /api/tiles/geojson/wfigs`** — GeoJSON proxy:
   - Append: `?where=1%3D1&outFields=*&f=geojson&resultRecordCount=500`
   - 8s timeout. Cache JSON responses.

**CORS — strict:**
```typescript
// Allow ONLY https://kahuola.org
// OPTIONS → 204 with CORS headers
// Other origins → 403
// Always: Vary: Origin
```

**Security rules (never violate):**
- Never accept upstream URL from client
- Never expose secret values in any response
- Never proxy to any URL not in UPSTREAMS registry
- Always AbortController 8s timeout
- Cache keys must not contain secret values

#### Files: `worker/package.json` + `worker/tsconfig.json`

```json
// package.json
{
  "name": "kahuola-tiles-broker",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "wrangler dev",
    "deploy": "wrangler deploy",
    "type-check": "tsc --noEmit"
  },
  "devDependencies": {
    "@cloudflare/workers-types": "^4.20240208.0",
    "typescript": "^5.3.3",
    "wrangler": "^3.40.0"
  }
}
```

```json
// tsconfig.json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ES2022",
    "moduleResolution": "bundler",
    "lib": ["ES2022"],
    "types": ["@cloudflare/workers-types"],
    "strict": true
  },
  "include": ["src/**/*.ts"]
}
```

---

### TASK 3 (OPTIONAL) — Flutter Landing Page `/landing_flutter/`

Only start this after Tasks 1 and 2 are complete and verified.

Create a Flutter web project that is a rich M3 version of the landing page.

**pubspec.yaml dependencies:**
```yaml
dependencies:
  flutter: { sdk: flutter }
  url_launcher: ^6.2.6
  google_fonts: ^6.2.1
```

**Theme:** `useMaterial3: true`, seed color `Color(0xFF0EA5A4)` (Kahu Ola teal)

**Kupuna design rules (mandatory):**
- Minimum body font: 18sp
- Minimum touch target: 48×48dp
- Card padding: 24dp minimum
- Line height: 1.6
- Never color-only indicators — always text + icon + color

**Sections (single scroll page):**
1. AppBar: logo + "Live Map" button (opens `https://kahuola.org/live-map.html`) + "Get App" button
2. Hero: title "Kahu Ola" (44sp), subtitle, two CTA buttons (56dp height min)
3. Signal cards: FireSignal · SmokeSignal · Perimeter (horizontal, 3 cards)
4. Feature grid: 🔥 Fire & Smoke · 🌬 Weather · 💨 Air Quality · 🌊 Earth & Ocean
5. Trust strip: text chip badges only — "NASA FIRMS" "NOAA HMS" "EPA AirNow" etc. NO logos
6. Privacy card: bullets — Zero PII, Session-only, Aggregator pattern, Offline-ready, WCAG 2.1 AA
7. Compliance card: exact legal disclaimer (see below)
8. Footer

**Exact legal disclaimer text (§33):**
```
Kahu Ola is an independent civic technology platform that aggregates
publicly available government data sources. It does not represent or
replace official emergency services, evacuation orders, or governmental
directives. Always follow official county, state, and federal guidance.
```

**Run to verify:**
```bash
cd landing_flutter
flutter pub get
flutter analyze   # must return 0 errors
flutter run -d chrome
```

---

## VERIFICATION CHECKLIST

### After Task 1 (run in browser):
- [ ] `live-map.html` opens — shows Leaflet map centered on Maui
- [ ] Glass panel visible — tabs Fire/Weather/Air/Earth/Ocean/Satellite
- [ ] Mode toggle Lite/Full works, persists on reload
- [ ] Layer toggles add/remove from map
- [ ] Legend updates when layers toggled
- [ ] "Not configured" shown for raws + usgs_quakes
- [ ] Legal notice bar visible above map
- [ ] "Live Map" link in index.html navbar
- [ ] Console: no unhandled errors (Worker not deployed yet → graceful Unknown status is OK)

### After Task 2 (run in terminal):
```bash
cd worker
npm install
npx wrangler dev   # local dev — test endpoints at localhost:8787
```
- [ ] `GET /api/tiles/health` returns JSON with upstreams object
- [ ] `OPTIONS /api/tiles/wms/firms` returns 204 with CORS headers
- [ ] WMS request with FORMAT=image/gif returns 400
- [ ] XYZ request with z=99 returns 400
- [ ] Request from origin other than kahuola.org returns 403

### After Task 3:
- [ ] `flutter analyze` returns 0 errors
- [ ] All text ≥ 18sp in Flutter inspector
- [ ] No upstream URLs in Dart code

---

## DEPLOY INSTRUCTIONS (for Long Nguyen to run manually)

### Website (after Task 1):
```bash
git add live-map.html layers.config.js index.html privacy.html support.html
git commit -m "feat: V4.3.1 live map + layer library"
git push origin main
# Auto-deploys to kahuola.org via GitHub Pages + Cloudflare
```

### Worker (after Task 2):
```bash
cd worker
npm install
npx wrangler secret put NASA_FIRMS_MAP_KEY   # get free key at firms.modaps.eosdis.nasa.gov/api/area/
npx wrangler secret put AIRNOW_API_KEY       # get free key at docs.airnowapi.org
npx wrangler deploy
# Worker live at kahuola.org/api/tiles/*
```

---

## DO NOT

- Do NOT add any upstream API URL to any `.html`, `.js`, or `.css` file
- Do NOT add any API key to any file (use wrangler secrets only)
- Do NOT import npm packages into website HTML files (CDN only)
- Do NOT break existing styles.css — all new CSS goes in `<style>` tags in live-map.html
- Do NOT remove or modify the existing legal disclaimer text in privacy.html
- Do NOT add agency logos — text references only
- Do NOT call any API from index.html, privacy.html, or support.html
