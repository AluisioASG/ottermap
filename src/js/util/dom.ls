<- define


# Alias to `document.getElementById`.
$id: -> document.getElementById it

# Alias to `document.querySelectorAll`.
$all: -> document.querySelectorAll it

# Alias to `element.querySelector`, where element is
# the document itself if left unspecified.
$sel: ->
  if &.length is 2
    &0.querySelector &1
  else
    document.querySelector &0

# Polyfills for `element.classList`, which is missing in IE9.
$addClass: $addClass = (elem, ...classNames) ->
  elem.className += " #{classNames * ' '}"
  return elem
$removeClass: $removeClass = (elem, ...classNames) ->
  elem.className -= new RegExp "\\b(#{classNames * '|'})\\b" \g
  return elem
$toggleClass: (elem, ...classNames) ->
  for className in classNames
    if elem.className is new RegExp "\\b#{className}\\b"
      elem `$removeClass` className
    else
      elem `$addClass` className
  return elem
