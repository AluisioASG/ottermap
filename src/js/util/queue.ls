<- define


# Decide which method set to use.
if navigator.userAgent is /\bChrome\//
  # V8 engine?
  enqueue = Array::unshift
  dequeue = Array::pop
else
  enqueue = Array::push
  dequeue = Array::shift

class Queue
  ->
    @data = []
  enqueue: (e) !->
    enqueue.call @data, e
  dequeue: ->
    dequeue.call @data
