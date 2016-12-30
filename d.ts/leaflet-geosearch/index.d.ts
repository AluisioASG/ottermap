// Type definitions for leaflet-geosearch 2.0.0
// Project: https://github.com/smeijer/leaflet-geosearch
// Definitions by: Aluísio Augusto Silva Gonçalves <https://github.com/AluisioASG>

import * as L from "leaflet"
export as namespace GeoSearch


export interface Provider {
    search: (params: SearchParameters) => Promise<Result>
}

export interface SearchParameters {
    query: string
}

export interface Result {
    /** Longitude. */
    x: number
    /** Latitude. */
    y: number
    /** Formatted address. */
    label: string
    bounds: [[number, number], [number, number]]
    /* Raw provider result. */
    raw: any
}


export class GeoSearchControl extends L.Control {
    constructor(options: GeoSearchControlOptions)
}

export interface GeoSearchControlOptions {
    provider: Provider
    style?: "bar" | "button"
    autoComplete?: boolean
    autoCompleteDelay?: number
    showPopup?: boolean
    showMarker?: boolean
    marker?: GeoSearchControlMarkerOptions
    maxMarkers?: number
    retainZoomLevel?: boolean
    animateZoom?: boolean
}

export interface GeoSearchControlMarkerOptions {
    icon?: L.Marker
    draggable?: boolean
}


export class BingProvider implements Provider {
    constructor(params: any)
    search: (params: SearchParameters) => Promise<Result>
}

export class EsriProvider implements Provider {
    constructor(params: any)
    search: (params: SearchParameters) => Promise<Result>
}

export class GoogleProvider implements Provider {
    constructor(params: any)
    search: (params: SearchParameters) => Promise<Result>
}

export class OpenStreetMapProvider implements Provider {
    constructor(params?: any)
    search: (params: SearchParameters) => Promise<Result>
}
