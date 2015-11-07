# Not AnOTTer Map

This is an interactive map showing the members of the [discussion thread][OTT] for the xkcd comic [#1190: “Time”][OTC].

The official live instance runs at http://ottermap.chirpingmustard.com/.


## License

All source code available in this package is, unless otherwise noted below, subject to the terms of the Mozilla Public License, v. 2.0.  These terms are set forth in the `LICENSE` file.

The “[Otter Track]” graphic at `src/img/marker.svg` was designed by Katie M Westbrook from [The Noun Project] collection.

The “chirpingmustard.com logo” graphic at `src/img/logo.svg` was designed by Owen Evans and adapted by Aluísio Augusto Silva Gonçalves.

The files located under the `vendor` subdirectory are property of their respective owners.  The licensing terms of this project do not apply to these files.


## Contributing, or: Running Your Own Instance

So, you want to play around with the code, maybe submit some patches, or even just see how this works, uh?  Well, be welcome!  If don't intend to contribute anything, just clone this repository and follow the instructions below.  Otherwise, I hope you're familiar with [The GitHub Way].


### External dependencies

In order to build the map, you'll need [Git] (obviously), [Node.js] and the bundled `npm` package manager.  You'll also need a database server, as the official ones won't speak to any instance not hosted in the official domains.  Currently we support two backends: [Firebase] and [MongoDB] with the [DBAPI] REST interface.  You can have different servers for development and production.


### Building the map

Once the build dependencies are installed, we can now install the _code_ dependencies, a mostly automated process.

Inside your project's working directory, run the following commands to fetch and build all managed dependencies.  This will have to be done whenever dependencies are added or updated.

    git submodule update --init --recursive
    npm update
    (cd vendor/leaflet && npm update)
    (cd vendor/leaflet-markercluster && npm update)

By last, you'll need to specify your build variables.  Copy the file `build-config.example.ls` to `build-config.ls` and change it to suit your needs.

_Now_ we're ready.  The following are some of the available build targets:
- `npm run build -- target[dev] watch` will result in a non-optimized build tree suitable for live development, watching the source files for changes;
- `npm run build -- target[dev] watch serve` will, in addition to the above, start a HTTP server to serve the development build (defaulting to serve at `localhost:8080`);
- `npm run build -- target[release]` will build everything up to the optimized release files, but won't stay around and watch for changes;
- `npm run build -- clean[build,dist] target[release] publish` will remove the build directories, create the release files anew in the `dist` directory, commit these files to the upstream repository's `gh-pages` branch, and publish the result to GitHub Pages.  Here you can, for example, use the `NODE_ENV` environment variable to change the database URLs: `npm --production run build -- clean[build,dist] target[release] publish`.


[OTT]:               http://forums.xkcd.com/viewtopic.php?t=101043
[OTC]:               https://xkcd.com/1190/
[Otter Track]:       https://thenounproject.com/term/otter-track/3498/
[The Noun Project]:  https://thenounproject.com/
[The GitHub Way]:    https://help.github.com/articles/fork-a-repo
[Git]:               https://git-scm.com/
[Node.js]:           https://nodejs.org/
[MongoDB]:           https://www.mongodb.org/
[DBAPI]:             https://bitbucket.org/AluisioASG/dbapi/
[Firebase]:          https://www.firebase.com/
