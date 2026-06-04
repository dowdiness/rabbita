///|

///|
pub struct ModConfigs {
  deps : Array[Dependency]
  preferred_target : String?
  name : String
  version : String
} derive(Debug)

///|
pub struct Dependency {
  path : String
  version : String?
} derive(Debug)

///|
pub fn read_mod(source : String) -> ModConfigs raise {
  let json = @json.parse(source)
  match json {
    {
      "deps"? : deps,
      "preferred-target"? : preferred_target,
      "name": String(name),
      "version": String(version),
      ..
    } => {
      let deps = if deps is Some(Object(mp)) {
        mp
        .to_array()
        .map(p => {
          path: p.0,
          version: if p.1 is String(s) {
            Some(s)
          } else {
            None
          },
        })
      } else {
        []
      }

      let preferred_target = if preferred_target is Some(String(s)) {
        Some(s)
      } else {
        None
      }

      { deps, preferred_target, name, version }
    }
    _ => fail("invalid module configuration: \n \{to_repr(json)}")
  }
}

///|
async test "read_mod" {
  let source =
    #|{
    #|  "name": "moonbit-community/rabbita",
    #|  "version": "0.11.8",
    #|  "deps": {
    #|    "path/to/mod": "0.5.1",
    #|    "path/to/another/mod": "0.5.2",
    #|    "path/to/another/mod2": {}
    #|  },
    #|  "readme": "README.md",
    #|  "repository": "https://github.com/moonbit-community/rabbita",
    #|  "license": "Apache-2.0",
    #|  "keywords": [
    #|    "functional",
    #|    "html",
    #|    "UI",
    #|    "web",
    #|    "TEA"
    #|  ],
    #|  "description": "functional Web UI framework for MoonBit",
    #|  "preferred-target": "js"
    #|}
  debug_inspect(
    read_mod(source),
    content=(
      #|{
      #|  deps: [
      #|    { path: "path/to/mod", version: Some("0.5.1") },
      #|    { path: "path/to/another/mod", version: Some("0.5.2") },
      #|    { path: "path/to/another/mod2", version: None },
      #|  ],
      #|  preferred_target: Some("js"),
      #|  name: "moonbit-community/rabbita",
      #|  version: "0.11.8",
      #|}
    ),
  )
}
