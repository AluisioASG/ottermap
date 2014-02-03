Queue <- define <[util/queue]>


# A very simple implementation of DOM's Event and CustomEvent
# interfaces.
class SimpleEvent
  (@type, eventInitDict={}) ->
    @target = null
    @defaultPrevented = false

    @cancelable = !!eventInitDict.cancelable
    @detail = eventInitDict.detail ? null
  preventDefault: !->
    if @cancelable
      @defaultPrevented = true

# A very simple implementation of the DOM's EventTarget interface.
class SimpleEventTarget
  ->
    @__eventListeners = {}
  addEventListener: (type, listener) !->
    @__eventListeners.[][type].push listener
  removeEventListener: (type, listener) !->
    listeners = @__eventListeners[type]
    return if not listeners?
    if ~(listeners.indexOf listener)
      delete listeners[~that]
  dispatchEvent: (event) ->
    event.target = this
    for listener in @__eventListeners[event.type]
      listener.call this, event
    return not event.defaultPrevented

class PausableEventTarget extends SimpleEventTarget
  ->
    super!
    @__eventBuffer = new Queue
    @__eventDispatchPaused = void
  addEventListener: (type, listener) !->
    super ...
    # If event dispatching wasn't explicitly configured and this is
    # the first event listener added to this event type, process the
    # event buffer for events of this type.
    if @__eventDispatchPaused is void and
       @__eventListeners[type].length is 1
      newBuffer = new Queue
      while event = @__eventBuffer.dequeue! then switch
      | event.type is type => super::dispatchEvent event
      | otherwise          => newBuffer.enqueue event
      @__eventBuffer = newBuffer
  dispatchEvent: (event) ->
    # We consider the event stream to be paused if either
    # event dispatching was explicitly paused or if there
    # are no listeners for the event's type.
    if @__eventDispatchPaused is true or
       event.type not of @__eventListeners or
       @__eventListeners[event.type].length is 0
      @__eventBuffer.enqueue event
      return
    # If we reached here, we are cleared to dispatch the event.
    super ...
  # Pause the event stream.
  pauseEventDispatch: !->
    @__eventDispatchPaused = true
  # Unpause the event stream.
  resumeEventDispatch: !->
    # Process the events on the queue before clearing the paused flag,
    # so they are dispatched in order.
    while @__eventBuffer.dequeue!?
      super.dispatchEvent that
    @__eventDispatchPaused = false

# Add an event handler that removes itself once called.
listenOnce = (target, eventType, listener, useCapture) !->
  wrapper = ->
    target.removeEventListener eventType, wrapper
    listener.apply this, arguments
  target.addEventListener eventType, wrapper, useCapture


# Define the module's API.
return {
  SimpleEvent
  SimpleEventTarget
  PausableEventTarget
  listenOnce
}

