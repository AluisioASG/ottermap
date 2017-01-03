// Extra type definitions for Leaflet 1.0.2
// Project: https://github.com/Leaflet/Leaflet
// Definitions by: Aluísio Augusto Silva Gonçalves <https://github.com/AluisioASG/ottermap>

import L = require("leaflet")


declare module "leaflet" {
    export class Map {
        attributionControl: L.Control.Attribution
    }

    namespace Icon {
        namespace Default {
            let imagePath: string
        }
    }
}
