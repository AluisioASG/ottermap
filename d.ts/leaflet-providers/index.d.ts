// Type definitions for leaflet-providers 1.1.16
// Project: https://github.com/leaflet-extras/leaflet-providers
// Definitions by: Aluísio Augusto Silva Gonçalves <https://github.com/AluisioASG>

import L = require("leaflet")


declare module "leaflet" {
    namespace tileLayer {
        export function provider(provider: string, options?: {}): L.TileLayer
    }
}
