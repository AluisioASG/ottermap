require! '../../actions': TaskActions


file 'build/css/leaflet.css' <[
  vendor/leaflet/dist/leaflet.css
  vendor/leaflet-geosearch/src/css/l.geosearch.css
  vendor/leaflet-markercluster/dist/MarkerCluster.css
  vendor/leaflet-markercluster/dist/MarkerCluster.Default.css
  vendor/leaflet-search/dist/leaflet-search.src.css
]> TaskActions.concat '\n'

file 'build/css/bootstrap.css' <[
  vendor/bootstrap/css/bootstrap.css
  vendor/bootstrap/css/bootstrap-theme.css
]> TaskActions.concat '\n'
