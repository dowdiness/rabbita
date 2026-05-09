let modulesPromise
let view
let languageCompartment
let currentKey = ''
let currentLang = ''
let currentOnChange = () => {}
let suppressChange = false

const moonbitKeywords = new Set([
  'async',
  'break',
  'catch',
  'const',
  'continue',
  'derive',
  'else',
  'enum',
  'extern',
  'fn',
  'for',
  'guard',
  'if',
  'impl',
  'import',
  'in',
  'let',
  'loop',
  'match',
  'mut',
  'noraise',
  'priv',
  'pub',
  'raise',
  'return',
  'struct',
  'trait',
  'try',
  'type',
  'using',
  'while',
])

const moonbitAtoms = new Set(['true', 'false'])

function loadModules() {
  if (!modulesPromise) {
    modulesPromise = Promise.all([
      import('https://esm.sh/@codemirror/state'),
      import('https://esm.sh/@codemirror/view'),
      import('https://esm.sh/@codemirror/commands'),
      import('https://esm.sh/@codemirror/language'),
      import('https://esm.sh/@lezer/highlight'),
    ]).then(([state, viewModule, commands, language, highlight]) => ({
      ...state,
      ...viewModule,
      ...commands,
      ...language,
      ...highlight,
    }))
  }
  return modulesPromise
}

function playgroundHighlightStyle(cm) {
  const t = cm.tags
  return cm.HighlightStyle.define([
    { tag: t.comment, color: '#6a737d' },
    { tag: [t.keyword, t.modifier, t.operatorKeyword], color: '#005cc5' },
    { tag: [t.atom, t.bool, t.null], color: '#0550ae' },
    { tag: [t.number, t.integer, t.float], color: '#0550ae' },
    { tag: [t.string, t.character, t.regexp], color: '#d73a49' },
    { tag: [t.typeName, t.className, t.namespace], color: '#22863a' },
    { tag: [t.definition(t.variableName), t.function(t.variableName)], color: '#6f42c1' },
    { tag: [t.variableName, t.self], color: '#24292f' },
    { tag: [t.propertyName, t.attributeName], color: '#953800' },
    { tag: [t.tagName, t.heading], color: '#22863a' },
    { tag: [t.operator, t.compareOperator, t.logicOperator, t.arithmeticOperator], color: '#d73a49' },
    { tag: [t.punctuation, t.separator], color: '#24292f' },
    { tag: t.bracket, color: '#8c959f' },
    { tag: t.meta, color: '#8250df' },
    { tag: t.invalid, color: '#b31d28', textDecoration: 'underline' },
  ])
}

function blockComment(stream, state) {
  while (!stream.eol()) {
    if (stream.match('*/')) {
      state.blockComment = false
      break
    }
    stream.next()
  }
  return 'comment'
}

function moonbitLanguage(StreamLanguage) {
  return StreamLanguage.define({
    startState() {
      return { blockComment: false, expectDefinition: false }
    },
    token(stream, state) {
      if (stream.eatSpace()) return null
      if (state.blockComment) return blockComment(stream, state)
      if (stream.match('//')) {
        stream.skipToEnd()
        return 'comment'
      }
      if (stream.match('/*')) {
        state.blockComment = true
        return blockComment(stream, state)
      }
      if (stream.match(/"([^"\\]|\\.)*"?/) || stream.match(/'([^'\\]|\\.)*'?/)) {
        return 'string'
      }
      if (stream.match(/[0-9]+(?:\.[0-9]+)?/)) return 'number'
      if (stream.match(/@[A-Za-z_][\w/]*/)) return 'meta'
      if (stream.match(/\.[A-Za-z_][A-Za-z0-9_]*/)) return 'property'
      if (stream.match(/[A-Za-z_][A-Za-z0-9_]*(?=~?\s*=)/)) return 'attribute'
      if (stream.match(/[A-Z][A-Za-z0-9_]*/)) return 'type'
      const word = stream.match(/[A-Za-z_][A-Za-z0-9_]*/)
      if (word) {
        const value = word[0]
        if (state.expectDefinition) {
          state.expectDefinition = false
          return 'def'
        }
        if (moonbitKeywords.has(value)) {
          state.expectDefinition = value === 'fn' || value === 'struct' || value === 'enum' || value === 'trait' || value === 'type'
          return 'keyword'
        }
        if (moonbitAtoms.has(value)) return 'atom'
        if (stream.match(/(?=\s*\()/, false)) return 'def'
        return 'variable'
      }
      if (stream.match(/[{}\[\]()]/)) return 'bracket'
      if (stream.match(/[.,:;]/)) return 'punctuation'
      if (stream.match(/[=+\-*/<>|&!~?]+/)) return 'operator'
      stream.next()
      return null
    },
  })
}

function htmlLanguage(StreamLanguage) {
  return StreamLanguage.define({
    token(stream) {
      if (stream.eatSpace()) return null
      if (stream.match(/<!--/)) {
        while (!stream.eol()) {
          if (stream.match(/-->/)) return 'comment'
          stream.next()
        }
        return 'comment'
      }
      if (stream.match(/<\/?[A-Za-z][\w-]*/)) return 'tag'
      if (stream.match(/[A-Za-z_:][\w:.-]*(?=\s*=)/)) return 'attribute'
      if (stream.match(/"([^"\\]|\\.)*"?/) || stream.match(/'([^'\\]|\\.)*'?/)) {
        return 'string'
      }
      if (stream.match(/[{}]/)) return 'bracket'
      if (stream.match(/[<>/=]+/)) return 'operator'
      stream.next()
      return null
    },
  })
}

function cssLanguage(StreamLanguage) {
  return StreamLanguage.define({
    token(stream) {
      if (stream.eatSpace()) return null
      if (stream.match(/\/\*/)) {
        while (!stream.eol()) {
          if (stream.match(/\*\//)) return 'comment'
          stream.next()
        }
        return 'comment'
      }
      if (stream.match(/@[A-Za-z-]+/)) return 'keyword'
      if (stream.match(/#[0-9A-Fa-f]{3,8}/)) return 'number'
      if (stream.match(/[A-Za-z-]+(?=\s*:)/)) return 'property'
      if (stream.match(/"([^"\\]|\\.)*"?/) || stream.match(/'([^'\\]|\\.)*'?/)) {
        return 'string'
      }
      if (stream.match(/[0-9.]+(?:px|rem|em|%|vh|vw|s|ms)?/)) return 'number'
      if (stream.match(/[{}()]/)) return 'bracket'
      if (stream.match(/[:;,.#]/)) return 'punctuation'
      if (stream.match(/[>+~*=]+/)) return 'operator'
      if (stream.match(/[A-Za-z_-][\w-]*/)) return 'variable'
      stream.next()
      return null
    },
  })
}

function languageFor(lang, StreamLanguage) {
  if (lang === 'html') return htmlLanguage(StreamLanguage)
  if (lang === 'css') return cssLanguage(StreamLanguage)
  return moonbitLanguage(StreamLanguage)
}

function updateDoc(nextValue) {
  const oldValue = view.state.doc.toString()
  if (oldValue === nextValue) return
  const selection = view.state.selection
  suppressChange = true
  view.dispatch({
    changes: { from: 0, to: view.state.doc.length, insert: nextValue },
    selection,
  })
  suppressChange = false
}

function offsetAt(lineNumber, column) {
  const doc = view.state.doc
  const safeLine = Math.max(1, Math.min(lineNumber || 1, doc.lines))
  const line = doc.line(safeLine)
  return Math.max(line.from, Math.min(line.to, line.from + Math.max(0, (column || 1) - 1)))
}

export function selectEditorRange({ key, line, column, endLine, endColumn }) {
  if (!view || currentKey !== key || !line || !column) return
  const from = offsetAt(line, column)
  let to = offsetAt(endLine || line, endColumn || column + 1)
  if (to <= from) {
    to = Math.min(view.state.doc.length, from + 1)
  }
  view.dispatch({
    selection: { anchor: from, head: to },
    scrollIntoView: true,
  })
  view.focus()
}

export async function syncEditor({ hostId, key, value, lang, onChange }) {
  const host = document.getElementById(hostId)
  if (!host) return

  const cm = await loadModules()
  currentOnChange = onChange

  if (!view || currentKey !== key || view.dom.parentElement !== host) {
    if (view) view.destroy()
    host.textContent = ''
    languageCompartment = new cm.Compartment()
    view = new cm.EditorView({
      parent: host,
      state: cm.EditorState.create({
        doc: value,
        extensions: [
          cm.lineNumbers(),
          cm.history(),
          cm.drawSelection(),
          cm.highlightActiveLine(),
          cm.syntaxHighlighting(playgroundHighlightStyle(cm), { fallback: true }),
          languageCompartment.of(languageFor(lang, cm.StreamLanguage)),
          cm.keymap.of([cm.indentWithTab, ...cm.defaultKeymap, ...cm.historyKeymap]),
          cm.EditorView.contentAttributes.of({
            spellcheck: 'false',
            autocapitalize: 'off',
            autocorrect: 'off',
          }),
          cm.EditorView.updateListener.of(update => {
            if (update.docChanged && !suppressChange) {
              currentOnChange(update.state.doc.toString())
            }
          }),
        ],
      }),
    })
    currentKey = key
    currentLang = lang
    return
  }

  if (currentLang !== lang) {
    view.dispatch({
      effects: languageCompartment.reconfigure(languageFor(lang, cm.StreamLanguage)),
    })
    currentLang = lang
  }
  updateDoc(value)
}
