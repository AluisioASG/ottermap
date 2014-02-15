# Not AnOTTer Map

This is an interactive map showing the members of the [discussion thread][OTT] for the xkcd comic [#1190: “Time”][OTC].

The official live instance runs at http://ottermap.chirpingmustard.com/.


## License

All source code available in this package is, unless otherwise noted below, subject to the terms of the Mozilla Public License, v. 2.0.  These terms are set forth in the `LICENSE` file.

The “[Otter Track][]” graphic at `src/img/marker.svg` was designed by Katie M Westbrook from [The Noun Project][] collection.

The “chirpingmustard.com logo” graphic at `src/img/logo.svg` was designed by Owen Evans and adapted by Aluísio Augusto Silva Gonçalves.

The files located under the `vendor` subdirectory are property of their respective owners.  The licensing terms of this project do not apply to these files.


## Contributing, or: Running Your Own Instance

So, you want to play around with the code, maybe submit some patches, or even just see how this works, uh?  Well, be welcome!  If don't intend to contribute anything, just clone this repository and follow the instructions below.  Otherwise, I hope you're familiar with [The GitHub Way][].


### External dependencies

In order to build the map, you'll need [Git][] (obviously), [Node.js][] and the bundled `npm` package manager.  Once you have these, you can install the [Grunt][] task runner, if you don't already have it, by running `npm install -g grunt-cli` from a command shell.

The official database will only speak with the official map instance, therefore you'll need a local database to back the map if you want to run it.  For that you'll need a [MongoDB][] server and the [DBAPI][] REST interface, both of which can be left at the default settings.


### Building the map

Once the build dependencies are installed, we can proceed with… installing more dependencies :tired_face:  But don't worry, it's all automated (to some extent).

Inside your project's working directory, run the following commands to fetch and build all managed dependencies.  This will have to be done whenever dependencies are added or updated.

    git submodule update --init --recursive
    npm update
    npm --prefix=vendor/leaflet update
    grunt builddeps

_Now_ we're ready.  Run `grunt` to build everything including the final release files.  While you're developing, you can run `grunt dev` once and then `npm start` to launch a web server for the map.  This server will automatically recompile any LiveScript or Stylus files you change.  If you want to see if your changes work in release mode, run `grunt release` followed by `npm start --production`.


### Running Your Own _Public_ Instance

I don't know why you'd want to do such a thing, but here's how it's done.  First, you need to specify the address of your production DBAPI server.  For this, copy `grunt/config/dev/dbapi-root.ls` to `grunt/userconfig/dbapi-root.ls` and edit the URL under the `production` key.  Then you can run `grunt deploy` to build the release files in the `dist` directory.  If you're using GitHub Pages to host your map, you can instead issue the command `grunt deploy publish`, which will additionally commit the release files to your `gh-pages` branch and push it to GitHub.


[OTT]:               http://forums.xkcd.com/viewtopic.php?t=101043
[OTC]:               http://xkcd.com/1190/
[Otter Track]:       http://thenounproject.com/term/otter-track/3498/
[The Noun Project]:  http://thenounproject.com/
[The GitHub Way]:    https://help.github.com/articles/fork-a-repo
[Git]:               http://git-scm.com/
[Node.js]:           http://nodejs.org/
[Grunt]:             http://gruntjs.com/
[MongoDB]:           http://www.mongodb.org/
[DBAPI]:             https://bitbucket.org/AluisioASG/dbapi/
