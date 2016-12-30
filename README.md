# Not AnOTTer Map

This is an interactive map showing the members of the [discussion thread][OTT] for the xkcd comic [#1190: “Time”][OTC].

The official live instance runs at http://ottermap.chirpingmustard.com/.


## License

All source code available in this package is, unless otherwise noted below, subject to the terms of the Mozilla Public License, v. 2.0.  These terms are set forth in the `LICENSE` file.

The “[Otter Track]” graphic at `src/js/map/marker.svg` was designed by Katie M Westbrook from [The Noun Project] collection.

The “chirpingmustard.com logo” graphic at `src/img/logo.svg` was designed by Owen Evans and adapted by Aluísio Augusto Silva Gonçalves.

The files located under the `vendor` subdirectory are property of their respective owners.  The licensing terms of this project do not apply to these files.


## Contributing, or: Running Your Own Instance

So, you want to play around with the code, maybe submit some patches, or even just see how this works, uh?  Well, be welcome!  If don't intend to contribute anything, just clone this repository and follow the instructions below.  Otherwise, I hope you're familiar with [The GitHub Way].

### Prerequisites

To build the map, you'll need [Git] (obviously), [Node.js] and the bundled `npm` package manager (you can also use [Yarn]).

After cloning this repository, run `npm install` and then `npm run deps` to fetch and build all dependencies.

### Configuring

There are a few choices for where user data is stored.  These are set through the `src/js/data/backend.ts`, which looks like this:

    export const dbUrl = "https://example.com/db"
    export {default} from "./backend-module"

The first line sets the address of a remote database, which depends on the backend you choose; we'll refer to that as the _database URL_.  The second line re-exports the API of a _data backend_, in this case named `backend-module`.

- To use a local, in-browser database only, use the `pouchdb` backend and set the database URL to `null`.
- On top of that, you can instead set the database URL to a [CouchDB-compatible][PouchDB/HTTP] database and sync with it.
- The `firebase` backend, last updated back when it was not a Google product, allowed one to view changes in real time from a [Firebase] database.
- The old `dbapi` backend is… well, we'll rather not talk about it.

#### Building and running

Now that we're all set, let's build the map proper.  Run

    npm run build

and once it finishes, fire up a web server into the `build` directory.  Alternatively, `npm start` will start a server at port 8080 with live-reloading enabled.

You can also pass options to Webpack separating them with a `--`, for example:

    npm build -- --watch  # watch for and rebuild on changes
    npm build -- -p  # production/optimization mode


[OTT]:               http://forums.xkcd.com/viewtopic.php?t=101043
[OTC]:               https://xkcd.com/1190/
[Otter Track]:       https://thenounproject.com/term/otter-track/3498/
[The Noun Project]:  https://thenounproject.com/
[The GitHub Way]:    https://help.github.com/articles/fork-a-repo
[Git]:               https://git-scm.com/
[Node.js]:           https://nodejs.org/
[Yarn]:              https://yarnpkg.com/
[PouchDB/HTTP]:      https://pouchdb.com/adapters.html#pouchdb_over_http
[Firebase]:          https://www.firebase.com/
