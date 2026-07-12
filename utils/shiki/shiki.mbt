///|
extern "js" fn load_shiki() -> @js.Promise =
  #| (async () => {
  #|   const [
  #|     { createHighlighterCore },
  #|     { createJavaScriptRegexEngine },
  #|   ] = await Promise.all([
  #|     import('https://esm.sh/shiki@3.23.0/core'),
  #|     import('https://esm.sh/shiki@3.23.0/engine/javascript'),
  #|   ])
  #|
  #|   return createHighlighterCore({
  #|     langs: [],
  #|     themes: [],
  #|     engine: createJavaScriptRegexEngine(),
  #|   })
  #| })

///|
extern "js" fn load_langs(
  highlighter : @js.Value,
  langs : Array[String],
) -> @js.Promise =
  #| (hl, langs) =>
  #|   hl.loadLanguage(
  #|     ...langs.map(lang =>
  #|       import(/* @vite-ignore */ ('https://esm.sh/shiki@3.23.0/langs/' + lang))
  #|     )
  #|   )

///|
extern "js" fn load_themes(
  highlighter : @js.Value,
  themes : Array[String],
) -> @js.Promise =
  #| (hl, themes) =>
  #|   hl.loadTheme(
  #|     ...themes.map(theme =>
  #|       import(/* @vite-ignore */ ('https://esm.sh/shiki@3.23.0/themes/' + theme))
  #|     )
  #|   )

///|
extern "js" fn code_to_html(
  highlighter : @js.Value,
  code : String,
  lang : String,
  theme : String,
) -> String =
  #| (hl, code, lang, theme) => {
  #|   try {
  #|     return hl.codeToHtml(code, { lang, theme })
  #|   } catch (e) {
  #|     console.warn(`[shiki] highlight failed: lang=${lang}, theme=${theme}`, e)
  #|     return ""
  #|   }
  #| }

///|
using @rabbita {type Cmd}

///|
extern "js" fn is_highlighter(x : @js.Value) -> Bool =
  #| (x) => !!x
  #|   && typeof x.codeToHtml === 'function'
  #|   && typeof x.loadLanguage === 'function'
  #|   && typeof x.loadTheme === 'function'

///|
priv struct Singleton {
  highlighter : @js.Value
  loaded_langs : Set[String]
  loaded_themes : Set[String]
  config : Config?
}

///|
impl Eq for Singleton with fn equal(a, b) {
  a.loaded_langs == b.loaded_langs &&
  a.loaded_themes == b.loaded_themes &&
  a.config == b.config
}

///|
let global_shiki_hl : Ref[Singleton?] = Ref(None)

///|
#cfg(target="js")
fn async_run(f : async () -> Unit noraise) -> Unit = "%async.run"

///|
pub fn initialize(langs~ : Array[String], themes~ : Array[String]) -> Unit {
  async_run(() => {
    try {
      let singleton = match global_shiki_hl.val {
        Some(s) => s
        None => {
          let highlighter = load_shiki().wait()
          guard is_highlighter(highlighter) else {
            fail("shiki highlighter init failed: invalid object")
          }
          let singleton = {
            highlighter,
            loaded_langs: Set([]),
            loaded_themes: Set([]),
            config: None,
          }
          global_shiki_hl.val = Some(singleton)
          singleton
        }
      }
      try load_langs(singleton.highlighter, langs).wait() |> ignore catch {
        e => fail("shiki load langs failed: \{e}")
      }
      for lang in langs {
        singleton.loaded_langs.add(lang)
      }

      try load_themes(singleton.highlighter, themes).wait() |> ignore catch {
        e => fail("shiki load themes failed: \{e}")
      }
      for theme in themes {
        singleton.loaded_themes.add(theme)
      }
    } catch {
      e => println(e)
    }
  })
}

///|
fn load_shiki_highlight(
  lang : String,
  theme : String,
  inject : @rabbita.Emit[Result[Singleton, Error]],
) -> Cmd {
  @rabbita.attempt(inject.0, async fn() {
    let singleton = match global_shiki_hl.val {
      Some(s) => s
      None => {
        let highlighter = load_shiki().wait()
        guard is_highlighter(highlighter) else {
          fail("shiki highlighter init failed: invalid object")
        }
        let singleton = {
          highlighter,
          loaded_langs: Set([]),
          loaded_themes: Set([]),
          config: Some({ lang, theme }),
        }
        global_shiki_hl.val = Some(singleton)
        singleton
      }
    }
    if !singleton.loaded_langs.contains(lang) {
      try load_langs(singleton.highlighter, [lang]).wait() |> ignore catch {
        e => fail("shiki load langs failed: \{e}")
      }
    }
    if !singleton.loaded_themes.contains(theme) {
      try load_themes(singleton.highlighter, [theme]).wait() |> ignore catch {
        e => fail("shiki load themes failed: \{e}")
      }
    }
    singleton
    // code_to_html(singleton.highlighter, code, lang, theme)
  })
}

///|
struct Config {
  lang : String
  theme : String
} derive(Eq)

///|
impl @rabbita.Enumerate for Config with fn tag(self : Config) {
  "\{self.lang}, \{self.theme}"
}

///|
#warnings("-alert_xss_vulnerable")
pub fn shiki_code(
  code : Val[String],
  lang~ : Val[String],
  theme~ : Val[String],
) -> Val[Html] {
  let config = lang.map2(theme, (lang, theme) => { lang, theme })
  let hl = config.switch(config => {
    @rabbita.create_resource(inject => {
      load_shiki_highlight(config.lang, config.theme, inject)
    })
  })

  code.map3(config, hl, (code, config, x) => {
    match x {
      Loaded(hl) => {
        let str = code_to_html(hl.highlighter, code, config.lang, config.theme)
        @html.code(attrs=@html.Attrs::build().inner_html(str), @html.nothing)
      }
      Pending => @html.div(@html.pre(code))
      Failed(_) => @html.div(@html.pre(code))
    }
  })
}

///|
using @rabbita {type Html, type Val}
