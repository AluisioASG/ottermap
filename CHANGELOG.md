# 0.7.0
* Warn about invalid tile providers retrieved from the settings
* Add modal dialogs from project information and settings
* Add support for specifying overlay layers in `localStorage`
* Extract JavaScript and CSS out of `index.html`
* Move to Firebase as the default database backend

# 0.6.0
* Dropped jQuery
* Redesigned the page so that the map occupies all available space except for a bar at the top of the page
* Replaced the search form with an in-map plugin

# 0.5.2
* Made pop-up behavior on Firefox match the expected behavior as in Chrome
* Added compatibility with Firefox 20
* Corrected paths to resources in the final HTML file

# 0.5.1
* Corrected URL of DBAPI server

# 0.5.0
* Changed application title from “OTTers' map”
* Changed the search function to look for partial case-insensitive matches
* Added a pop-up to the markers containing the user's nickname and avatar
* Added support for fetching CSS styles from `localStorage` and applying them to the markers
* Added memorization of the last selected map tile provider in `localStorage`
* Added the _chirpingmustard.com_ logo between the search and upload forms on wide displays
* Updated jQuery to 2.x and dropped support to Internet Explorer 8 and older
* Added CSS classes to the markers, which change based on the user's status
* Changed marker icon
* Integrated with the _Blitzer Tracker_ userscript for detection of users' statuses
