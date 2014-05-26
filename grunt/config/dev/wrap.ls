module.exports =
  'cssanimevent.js':
    options:
      wrapper: [
        'define(function () {\n'
        'return window.CSSAnimEvent;\n});'
      ]
    src: 'vendor/cssanimevent/cssanimevent.js'
    dest: 'build/js/cssanimevent.js'
  'firebase.js':
    options:
      wrapper: [
        'define(function () {\n'
        'return Firebase;\n});'
      ]
    src: 'vendor/firebase/firebase.js'
    dest: 'build/js/firebase.js'
