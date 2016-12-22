// Decide which method set to use.
let enqueue: (this: any[], e: any) => void
let dequeue: (this: any[]) => any
if (/\bChrome\//.test(navigator.userAgent)) {
  // V8 engine?
  enqueue = [].unshift
  dequeue = [].pop
} else {
  enqueue = [].push
  dequeue = [].shift
}


export default class Queue {
  readonly data: any[] = []

  enqueue(e: any): void {
    enqueue.call(this.data, e)
  }
  dequeue(): any {
    return dequeue.call(this.data)
  }
}
