import Queue from "./queue"


interface EventListener {
  (this: SimpleEventTarget, event: SimpleEvent): void
}


/**
 * A very simple implementation of DOM's Event and CustomEvent
 * interfaces.
 */
export class SimpleEvent {
  /** Event type identification. */
  readonly type: string
  /** Custom data attached to the event. */
  readonly detail: any
  /** Whether the operation which triggered the event can be cancelled
   *  by one of the event listeners. */
  readonly cancelable: boolean
  /** Event target from which the event was dispatched. */
  target: SimpleEventTarget
  /** Whether one of the event listeners has requested the operation
   * responsible for the event to be canceled. */
  defaultPrevented: boolean = false

  constructor(type: string, eventInitDict?: {cancelable?: boolean, detail?: any}) {
    this.type = type

    this.cancelable = eventInitDict && eventInitDict.cancelable || false
    this.detail = eventInitDict && eventInitDict.detail
  }

  preventDefault() {
    if (this.cancelable) {
      this.defaultPrevented = true
    }
  }
}


/**
 * A very simple implementation of the DOM's EventTarget interface.
 */
export class SimpleEventTarget {
  protected readonly eventListeners: {[type: string]: EventListener[]} = {}

  addEventListener(type: string, listener: EventListener) {
    if (this.eventListeners[type] === undefined) {
      this.eventListeners[type] = []
    }
    this.eventListeners[type].push(listener)
  }

  removeEventListener(type: string, listener: EventListener) {
    const listeners = this.eventListeners[type]
    if (listeners != null) {
      const listenerIdx = listeners.indexOf(listener)
      if (listenerIdx != -1) {
        delete listeners[listenerIdx]
      }
    }
  }

  /**
   * Dispatch the event to all listeners.
   * Returns `true` if the event was canceled, or `null` if the cancelation
   * status could not be determined.
   */
  dispatchEvent(event: SimpleEvent): boolean | null {
    event.target = this
    ;(this.eventListeners[event.type] || []).forEach(listener =>
      listener.call(this, event)
    )
    return !event.defaultPrevented
  }
}


export class PausableEventTarget extends SimpleEventTarget {
  protected eventBuffer: Queue = new Queue()
  protected eventDispatchPaused: boolean | null = null

  addEventListener(type: string, listener: EventListener) {
    super.addEventListener(type, listener)
    // If event dispatching wasn't explicitly configured and this is the first
    //event listener added to this event type, process the event buffer for
    // events of this type.
    if (this.eventDispatchPaused === null && this.eventListeners[type].length === 1) {
      const newBuffer = new Queue
      for (let event = this.eventBuffer.dequeue(); event != null; event = this.eventBuffer.dequeue()) {
        if (event.type === type) {
          super.dispatchEvent(event)
        } else {
          newBuffer.enqueue(event)
        }
      }
      this.eventBuffer = newBuffer
    }
  }

  dispatchEvent(event: SimpleEvent): boolean | null {
    // We consider the event stream to be paused if either event dispatching
    // was explicitly paused or if there are no listeners for the event's type.
    if (this.eventDispatchPaused === true ||
        !(event.type in this.eventListeners) || this.eventListeners[event.type].length === 0) {
      this.eventBuffer.enqueue(event)
      return null
    }
    // If we reached here, we are cleared to dispatch the event.
    return super.dispatchEvent(event)
  }

  /**
   * Pause the event stream.
   */
  pauseEventDispatch() {
    this.eventDispatchPaused = true
  }

  /**
   * Unpause the event stream.
   */
  resumeEventDispatch() {
    // Process the events on the queue before clearing the paused flag, so they
    // are dispatched in order.
    for (let event = this.eventBuffer.dequeue(); event != null; event = this.eventBuffer.dequeue()) {
      super.dispatchEvent(event)
    }
    this.eventDispatchPaused = false
  }
}

/**
 * Add an event handler that removes itself once called.
 */
export function listenOnce(
  target: EventTarget,
  eventType: string,
  listener: EventListenerOrEventListenerObject,
  useCapture?: boolean
): void
export function listenOnce(
  target: SimpleEventTarget,
  eventType: string,
  listener: EventListener
): void
export function listenOnce(
  target: EventTarget | SimpleEventTarget,
  eventType: string,
  listener: EventListener | EventListenerOrEventListenerObject,
  useCapture?: boolean
): void {
  let wrapper = function(this: typeof target) {
    if (target instanceof SimpleEventTarget) {
      target.removeEventListener(eventType, wrapper)
      ;(listener as EventListener).apply(this, arguments)
    } else {
      target.removeEventListener(eventType, wrapper)
      ;(listener as EventListenerOrEventListenerObject).apply(this, arguments)
    }
  }
  if (target instanceof SimpleEventTarget) {
    target.addEventListener(eventType, wrapper)
  } else {
    target.addEventListener(eventType, wrapper, useCapture)
  }
}
