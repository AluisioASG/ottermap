// Type definitions for Leaflet.markercluster 1.0.0
// Project: https://github.com/Leaflet/Leaflet.markercluster
// Definitions by: Aluísio Augusto Silva Gonçalves <https://github.com/AluisioASG>
// FIXME: Leaflet/Leaflet.markercluster#725

import L = require("leaflet")


declare module "leaflet" {
    export class MarkerClusterGroup extends L.Layer implements L.FeatureGroup {
        constructor(options?: MarkerClusterGroupOptions)

        toGeoJSON(): GeoJSON.GeometryCollection
        addLayer(layer: L.Layer): this
        removeLayer(layer: L.Layer): this
        removeLayer(id: number): this
        hasLayer(layer: L.Layer): boolean
        clearLayers(): this
        invoke(methodName: string, ...params: any[]): this
        eachLayer(fn: (layer: L.Layer) => void, context?: any): this
        getLayer(id: number): L.Layer
        getLayers(): L.Layer[]
        setZIndex(zIndex: number): this
        getLayerId(layer: L.Layer): number

        setStyle(style: L.PathOptions): this
        bringToFront(): this
        bringToBack(): this
        getBounds(): L.LatLngBounds
    }

    export function markerClusterGroup(options?: MarkerClusterGroupOptions): MarkerClusterGroup

    interface MarkerClusterGroupOptions {
    }
}
