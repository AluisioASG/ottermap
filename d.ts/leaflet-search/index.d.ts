// Type definitions for leaflet-search 2.7.0
// Project: https://github.com/stefanocudini/leaflet-search
// Definitions by: Aluísio Augusto Silva Gonçalves <https://github.com/AluisioASG>

import L = require("leaflet")


declare module "leaflet" {
    namespace Control {
        export class Search implements L.Control {
            constructor(options: SearchOptions)

            /**
             * Set search layer.
             */
            setLayer(layer: L.LayerGroup): this

            /**
             * Show an alert message.
             */
            showAlert(message: string): this

            /**
             * Hide the alert message.
             */
            hideAlert(): this

            /**
             * Search.
             */
            searchText(query: string): void

            getPosition(): L.ControlPosition
            setPosition(position: L.ControlPosition): this
            getContainer(): HTMLElement
            addTo(map: L.Map): this
            remove(): this
            onAdd(map: L.Map): HTMLElement
            onRemove(map: L.Map): void
        }
    }

    interface SearchOptions {
        position?: L.ControlPosition
        /** URL for search by AJAX request, ex: `search.php?q={s}`.  Can be a
         *  function that returns string for dynamic parameter setting. */
        url?: string | (() => string)
        /** Layer where search markers. */
        layer?: L.LayerGroup
        /** Function that fill `_recordsCache`. */
        sourceData?: (this: this, query: string, callback: (data: any) => void) => SearchRequest
        /** JSONP param name for search by JSONP service, ex: `callback`. */
        jsonpParam?: string
        /** Field for remapping location, using array: `['latname','lonname']` for
         *  select double fields(ex. `['lat','lon']`) support dotted format:
         * `prop.subprop.title`. */
        propertyLoc?: string
        /** Property in `marker.options` (or `feature.properties` for vector layer) trough which filter elements in layer. */
        propertyName?: string
        /** Callback to reformat all data from source to indexed data object. */
        formatData?: (data: any) => SearchRecord[]
        /** Callback for filtering data from text searched. */
        filterData?: (query: string, allRecords: SearchRecord[]) => SearchRecord[]
        /** Callback run on location found. */
        moveToLocation?: (latlng: L.LatLng, title: string, map: L.Map) => void
        /** Function that returns tooltip HTML node or string. */
        buildTip?: (tooltip: string) => HTMLElement | string
        /** Container id to insert Search Control. */
        container?: string
        /** Default zoom level for move to location. */
        zoom?: number
        /** Minimal text length for autocomplete. */
        minLength?: number
        /** Match text from the beginning. */
        initial?: boolean
        /** Perform a case-sensitive search. */
        casesensitive?: boolean
        /** Complete the input with the first suggested result and select the
         *  filled-in text. */
        autoType?: boolean
        /** Delay while typing before showing a tooltip. */
        delayType?: number
        /** Limit results shown in the tooltip.  `-1` for no limit. */
        tooltipLimit?: number
        /** Pan to result on tooltip click. */
        tipAutoSubmit?: boolean
        /** Select first result on tooltip click. */
        firstTipSubmit?: boolean
        /** Resize on input change. */
        autoResize?: boolean
        /** Collapse search control at startup. */
        collapsed?: boolean
        /** Collapse search control after submit. */
        autoCollapse?: boolean
        /** Delay for autoclosing alert and collapse after blur. */
        autoCollapseTime?: number
        /** Error message. */
        textErr?: string
        /** Title of cancel button. */
        textCancel?: string
        /** Search field placeholder text. */
        textPlaceholder?: string
        /** Remove circle and marker on search control collapse. */
        hideMarkerOnCollapse?: boolean
        /** Custom result marker, or `false` for no marker. */
        marker?: L.Marker | false
    }

    interface SearchRecord {

    }

    interface SearchRequest {
        abort?: () => void
    }
}
