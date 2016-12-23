/** Alias to `document.getElementById`. */
export function $id(id: string): HTMLElement | null {
  return document.getElementById(id)
}

/** Alias to `document.querySelectorAll`. */
export function $all(selector: string): HTMLElement[] {
  return [].slice.call(document.querySelectorAll(selector))
}

/**
 * Alias to `element.querySelector`, where `element` is the document itself
 * if left unspecified.
 */
export function $sel(element: Element, selector: string): Element | null
export function $sel(selector: string): HTMLElement | null
export function $sel(arg0: Element | string, arg1?: string): Element | HTMLElement | null {
  if (typeof arg0 === "string") {
    return document.querySelector(arg0)
  } else {
    return arg0.querySelector(arg1!)
  }
}

/* Polyfills for `element.classList`, which is missing in IE9. */
export function $addClass(elem: Element, ...classNames: string[]): Element {
  elem.className += ` ${classNames.join(" ")}`
  return elem
}
export function $removeClass(elem: Element, ...classNames: string[]): Element {
  elem.className = elem.className.replace(new RegExp(`\\b(${classNames.join("|")})\\b`, "g"), "")
  return elem
}
export function $toggleClass(elem: Element, ...classNames: string[]): Element {
  for (const className of classNames) {
    if (new RegExp(`\\b${className}\\b`).test(elem.className)) {
      $removeClass(elem, className)
    } else {
      $addClass(elem, className)
    }
  }
  return elem
}
