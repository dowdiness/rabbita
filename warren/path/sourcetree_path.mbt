///|
pub type Path = @p.Path

///|
struct SourcePath(String) derive(Eq, Compare, Hash)

///|
pub impl Debug for SourcePath with fn to_repr(self) {
  @debug.Repr::string(self.0)
}

///|
pub fn SourcePath::new(s : String) -> Self {
  Path::resolve(s).0
}

///|
pub impl Show for SourcePath with fn output(self, buf) {
  buf.write_string(self.0)
}

///|
pub fn SourcePath::join(a : Self, b : String) -> Self {
  Path::join(a.0, b).normalize().0
}

///|
pub fn SourcePath::relative(a : Self, base : SourcePath) -> String {
  Path::relative(a.0, base=base.0).0
}
