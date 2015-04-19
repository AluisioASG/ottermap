require! '../../actions': TaskActions


file 'dist/fonts/glyphicons-halflings-regular.ttf' <[
  vendor/bootstrap/fonts/glyphicons-halflings-regular.ttf
]> TaskActions.copy

file 'dist/fonts/glyphicons-halflings-regular.woff' <[
  vendor/bootstrap/fonts/glyphicons-halflings-regular.woff
]> TaskActions.copy

file 'dist/img/layers.png' <[
  vendor/leaflet/dist/images/layers.png
]> TaskActions.copy

file 'dist/img/layers-2x.png' <[
  vendor/leaflet/dist/images/layers-2x.png
]> TaskActions.copy

file 'dist/img/marker-icon.png' <[
  vendor/leaflet/dist/images/marker-icon.png
]> TaskActions.copy

file 'dist/img/marker-icon-2x.png' <[
  vendor/leaflet/dist/images/marker-icon-2x.png
]> TaskActions.copy

file 'dist/img/marker-shadow.png' <[
  vendor/leaflet/dist/images/marker-shadow.png
]> TaskActions.copy

file 'dist/img/search-icon.png' <[
  vendor/leaflet-search/images/search-icon.png
]> TaskActions.copy
