module.exports =
  'cssanimevent.js':
    options:
      wrapper: [
        'define(function () {\n'
        'return window.CSSAnimEvent;\n});'
      ]
    src: 'vendor/cssanimevent/cssanimevent.js'
    dest: 'build/js/cssanimevent.js'
