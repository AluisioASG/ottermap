module.exports =
  'leaflet.js':
    options:
      separator: ';'
    src: [
      'vendor/leaflet/dist/leaflet-src.js'
      'vendor/leaflet-geosearch/src/js/l.control.geosearch.js'
      'vendor/leaflet-geosearch/src/js/l.geosearch.provider.openstreetmap.js'
      'vendor/leaflet-providers/leaflet-providers.js'
      'vendor/leaflet-markercluster/dist/leaflet.markercluster-src.js'
      'vendor/leaflet-search/dist/leaflet-search.src.js'
    ]
    dest: 'build/js/leaflet.js'
  'leaflet.css':
    src: [
      'vendor/leaflet/dist/leaflet.css'
      'vendor/leaflet-geosearch/src/css/l.geosearch.css'
      'vendor/leaflet-markercluster/dist/MarkerCluster.css'
      'vendor/leaflet-markercluster/dist/MarkerCluster.Default.css'
      'vendor/leaflet-search/dist/leaflet-search.src.css'
    ]
    dest: 'build/css/leaflet.css'
  'bootstrap.css':
    src: [
      'vendor/bootstrap/css/bootstrap.css'
      'vendor/bootstrap/css/bootstrap-theme.css'
    ]
    dest: 'build/css/bootstrap.css'
