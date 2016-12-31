import L = require("leaflet")
/// <reference type="leaflet-ottermap" />
import {User} from "../data/model"
import map from "../map"
import {trimIndent} from "../util/strings"
// https://github.com/TypeStrong/ts-loader#loading-other-resources-and-code-splitting
// tslint:disable-next-line:no-var-requires
const markerSvg: string = require("!!raw-loader!ottermap/img/marker.svg")


function mdLink(href: string, text: string): string {
  return `<a href="${href}" rel="nofollow">${text}</a>`
}

/**
 * Create a standard marker icon tagged with the given class.
 */
function buildIcon(markerClass: string): L.DivIcon {
  return new L.DivIcon({
    html: markerSvg,
    iconSize: [42, 44],
    className: markerClass,
  })
}

/** Escape HTML special characters. */
function htmlify(s: string): string {
  const entities = {
    [`&`]: "&amp;",
    [`<`]: "&lt;",
    [`>`]: "&gt;",
    [`"`]: "&quot;",
    [`'`]: "&apos;",
  }
  return s.replace(/[&<>"']/g, match => entities[match])
}

/**
 * Slugify the username (see Django's django/utils/text.py) to fetch
 * the user's avatar.
 */
function slugify(s: string): string {
  return s.trim().replace(/[-\s]+/g, "-").replace(/[^\w-]/g, "").toLowerCase()
}

/**
 * Build a pop-up for the given user, containing their username and avatar.
 */
function buildPopup(username: string): L.Popup {
  const htmlUsername = htmlify(username)
  const avatarUrl = `http://upperattic.at/Time/api/avatar/img/${slugify(username)}/`
  return L.popup({closeButton: false}).setContent(trimIndent(`
    <figure class="avatar">
      <img src="${avatarUrl}" alt="${htmlUsername}'s avatar">
      <figcaption class="text-center">${htmlUsername}</figcaption>
    </figure>
  `))
}

/**
 * Build a marker for a given user using the given icon.
 */
function buildMarker(user: User, icon: L.DivIcon): L.Marker {
  return new L.Marker(user.location!, {
    icon: icon,
    title: user.username,
  }).bindPopup(buildPopup(user.username))
}


/** Attribution notice for the marker icons. */
const MARKER_ICON_ATTRIBUTION = "Marker (“[Otter Track][1]”) © Katie M Westbrook, [The Noun Project][2]"
  .replace(/\[(.+?)\]\[1\]/, mdLink("http://thenounproject.com/term/otter-track/3498/", "$1"))
  .replace(/\[(.+?)\]\[2\]/, mdLink("http://thenounproject.com/", "$1"))

/** Icon used for members with no activity record. */
const DefaultIcon = buildIcon("marker-default")
/** Icon used for members considered active. */
const OnlineMemberIcon = buildIcon("marker-online")
/** Icon used for members considered inactive. */
const OfflineMemberIcon = buildIcon("marker-offline")


// Set the path to Leaflet's images, relative to the web page.
L.Icon.Default.imagePath = "img"
import "!!file-loader?name=img/[name].[ext]&publicPath=../!leaflet.style/images/marker-icon.png"
import "!!file-loader?name=img/[name].[ext]&publicPath=../!leaflet.style/images/marker-icon-2x.png"
import "!!file-loader?name=img/[name].[ext]&publicPath=../!leaflet.style/images/marker-shadow.png"

// Add the attribution of the marker icon to the map.
map.attributionControl.addAttribution(MARKER_ICON_ATTRIBUTION)


/**
 * Create a marker for a member.
 */
export function buildMemberMarker(user: User) {
  const marker = buildMarker(user, DefaultIcon)
  // tslint:disable-next-line:arrow-parens
  user.addEventListener("locationchange", ({detail}) => {
    marker.setLatLng(detail.newValue)
  })
  // tslint:disable-next-line:arrow-parens
  user.addEventListener("statuschange", ({detail}) => {
    switch (detail.newValue) {
      case "online":
        marker.setIcon(OnlineMemberIcon)
        break
      case "offline":
        marker.setIcon(OfflineMemberIcon)
        break
      default:
        marker.setIcon(DefaultIcon)
    }
  })
  return marker
}
