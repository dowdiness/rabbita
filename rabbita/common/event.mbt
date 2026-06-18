///|
struct Mouse {
  screen : Pos
  offset : Pos
  client : Pos
} derive(Debug)

///|
pub fn Mouse::new(screen~ : Pos, offset~ : Pos, client~ : Pos) -> Self {
  { screen, offset, client }
}

///|
pub fn Mouse::screen_pos(self : Mouse) -> Pos {
  self.screen
}

///|
pub fn Mouse::offset_pos(self : Mouse) -> Pos {
  self.offset
}

///|
pub fn Mouse::client_pos(self : Mouse) -> Pos {
  self.client
}

///|
struct Pointer {
  mouse : Mouse
  pointer_id_value : Int
  width_value : Double
  height_value : Double
  pressure_value : Double
  tilt_x_value : Int
  tilt_y_value : Int
  pointer_type_value : String
  primary_value : Bool
} derive(Debug)

///|
pub fn Pointer::new(
  mouse~ : Mouse,
  pointer_id~ : Int,
  width~ : Double,
  height~ : Double,
  pressure~ : Double,
  tilt_x~ : Int,
  tilt_y~ : Int,
  pointer_type~ : String,
  is_primary~ : Bool,
) -> Self {
  {
    mouse,
    pointer_id_value: pointer_id,
    width_value: width,
    height_value: height,
    pressure_value: pressure,
    tilt_x_value: tilt_x,
    tilt_y_value: tilt_y,
    pointer_type_value: pointer_type,
    primary_value: is_primary,
  }
}

///|
pub fn Pointer::mouse(self : Pointer) -> Mouse {
  self.mouse
}

///|
pub fn Pointer::screen_pos(self : Pointer) -> Pos {
  self.mouse.screen_pos()
}

///|
pub fn Pointer::offset_pos(self : Pointer) -> Pos {
  self.mouse.offset_pos()
}

///|
pub fn Pointer::client_pos(self : Pointer) -> Pos {
  self.mouse.client_pos()
}

///|
pub fn Pointer::pointer_id(self : Pointer) -> Int {
  self.pointer_id_value
}

///|
pub fn Pointer::width(self : Pointer) -> Double {
  self.width_value
}

///|
pub fn Pointer::height(self : Pointer) -> Double {
  self.height_value
}

///|
pub fn Pointer::pressure(self : Pointer) -> Double {
  self.pressure_value
}

///|
pub fn Pointer::tilt_x(self : Pointer) -> Int {
  self.tilt_x_value
}

///|
pub fn Pointer::tilt_y(self : Pointer) -> Int {
  self.tilt_y_value
}

///|
pub fn Pointer::pointer_type(self : Pointer) -> String {
  self.pointer_type_value
}

///|
pub fn Pointer::is_primary(self : Pointer) -> Bool {
  self.primary_value
}

///|
pub(all) struct Pos {
  x : Int
  y : Int
} derive(Debug)

///|
pub impl Show for Pos with fn output(self, buf) {
  self.to_repr().output(buf)
}

///|
struct Keyboard {
  key_value : String
  code_value : String
  alt_pressed : Bool
  ctrl_pressed : Bool
  shift_pressed : Bool
  meta_pressed : Bool
  composing : Bool
  repeated : Bool
  location_value : Int
} derive(Debug)

///|
pub fn Keyboard::new(
  key~ : String,
  code~ : String,
  alt_key~ : Bool,
  ctrl_key~ : Bool,
  shift_key~ : Bool,
  meta_key~ : Bool,
  is_composing~ : Bool,
  repeat~ : Bool,
  location~ : Int,
) -> Self {
  {
    key_value: key,
    code_value: code,
    alt_pressed: alt_key,
    ctrl_pressed: ctrl_key,
    shift_pressed: shift_key,
    meta_pressed: meta_key,
    composing: is_composing,
    repeated: repeat,
    location_value: location,
  }
}

///|
pub fn Keyboard::key(self : Keyboard) -> String {
  self.key_value
}

///|
pub fn Keyboard::code(self : Keyboard) -> String {
  self.code_value
}

///|
pub fn Keyboard::alt_key(self : Keyboard) -> Bool {
  self.alt_pressed
}

///|
pub fn Keyboard::ctrl_key(self : Keyboard) -> Bool {
  self.ctrl_pressed
}

///|
pub fn Keyboard::shift_key(self : Keyboard) -> Bool {
  self.shift_pressed
}

///|
pub fn Keyboard::meta_key(self : Keyboard) -> Bool {
  self.meta_pressed
}

///|
pub fn Keyboard::is_composing(self : Keyboard) -> Bool {
  self.composing
}

///|
pub fn Keyboard::repeat(self : Keyboard) -> Bool {
  self.repeated
}

///|
pub fn Keyboard::location(self : Keyboard) -> Int {
  self.location_value
}

///|
struct Scroll {
  scroll_offset : Pos
  scroll_width : Int
  scroll_height : Int
} derive(Debug)

///|
pub fn Scroll::new(offset~ : Pos, width~ : Int, height~ : Int) -> Self {
  { scroll_offset: offset, scroll_width: width, scroll_height: height }
}

///|
pub fn Scroll::offset_pos(self : Self) -> Pos {
  self.scroll_offset
}

///|
pub fn Scroll::width(self : Self) -> Int {
  self.scroll_width
}

///|
pub fn Scroll::height(self : Self) -> Int {
  self.scroll_height
}

///|
pub(all) struct Viewport {
  width : Int
  height : Int
} derive(Debug)

///|
pub impl Show for Viewport with fn output(self, buf) {
  self.to_repr().output(buf)
}
