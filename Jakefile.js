const LeafletBuild = require('./vendor/leaflet/build/build')
const MarkerClusterBuild = require('./vendor/leaflet-markercluster/build/build')


function pushdAsync(wd) {
  const oldwd = process.cwd()
  process.chdir(wd)
  return () => {
    process.chdir(oldwd)
    complete()
  }
}

function installDepsCmd() {
  // https://github.com/ForbesLindesay/spawn-sync/blob/b0063ee33b17feaa905602f0b2ff72b4acd1bdbb/postinstall.js#L29
  const npm = process.env.npm_execpath ? `"${process.argv[0]}" "${process.env.npm_execpath}"` : 'npm'
  return `${npm} install`
}


desc('Build Leaflet')
task('build-leaflet', ['fetchdeps-leaflet'], {async: true}, () => {
  console.log('.. Building Leaflet ..')
  LeafletBuild.build(pushdAsync('vendor/leaflet'), '2us2ved')
})

desc('Build Leaflet.markercluster')
task('build-leaflet-markercluster', ['fetchdeps-leaflet-markercluster'], () => {
  console.log('.. Building Leaflet.markercluster ..')
  const oldwd = process.cwd()
  process.chdir('vendor/leaflet-markercluster')
  MarkerClusterBuild.build('7')
  process.chdir(oldwd)
})

desc('Build dependencies')
task('build-deps', ['build-leaflet', 'build-leaflet-markercluster'])


desc('Download Git submodules')
task('fetch-submodules', {async: true}, () => {
  console.log('.. Fetching submodules ..')
  jake.exec(
    'git submodule update --init --recursive',
    {printStdout: true, printStderr: true},
    complete
  )
})

desc('Download Leaflet dependencies')
task('fetchdeps-leaflet', {async: true}, () => {
  console.log('.. Fetching Leaflet dependencies ..')
  jake.exec(
    installDepsCmd(),
    {printStdout: true, printStderr: true},
    pushdAsync('vendor/leaflet')
  )
})

desc('Download Leaflet.markercluster dependencies')
task('fetchdeps-leaflet-markercluster', {async: true}, () => {
  console.log('.. Fetching leaflet-markercluster dependencies ..')
  jake.exec(
    installDepsCmd(),
    {printStdout: true, printStderr: true},
    pushdAsync('vendor/leaflet-markercluster')
  )
})

desc('Fetch submodule dependencies')
task(
  'fetch-submodule-deps',
  ['fetch-submodules', 'fetchdeps-leaflet', 'fetchdeps-leaflet-markercluster']
)


task('default', ['fetch-submodules', 'build-deps', 'fetch-submodule-deps'])
