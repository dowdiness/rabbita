///|
struct MooncakesPath(String) derive(Eq, Compare)

///|
pub fn MooncakesPath::new(s : String) -> Self {
  MooncakesPath(s)
}

///|
pub fn MooncakesPath::to_string(s : Self) -> String {
  s.0
}

///|
pub fn MooncakesPath::join(a : Self, b : String) -> Self {
  Path::join(a.0, b).0
}

///|
pub impl Debug for MooncakesPath with fn to_repr(self) {
  @debug.Repr::string(self.0)
}

///|
pub impl Show for MooncakesPath with fn output(self, buf) {
  buf.write_string(self.0)
}
