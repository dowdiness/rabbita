///|
/// Render a Rabbita HTML value through the current VDOM serializer.
///
/// This adapter is intended for deterministic component tests. It keeps the
/// internal VDOM package behind the Rabbita module boundary without restoring
/// the removed top-level `rabbita.render_to_string` API.
pub fn server_side_render(builder : () -> @html.Html) -> String {
  @vdom.server_side_render(() => builder().to_virtual_dom())
}
