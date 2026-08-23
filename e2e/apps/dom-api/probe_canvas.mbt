///|
fn probe_canvas() -> String {
  let failures : Array[String] = []
  let document = @dom.document()
  let canvas_element = document.create_element("canvas")
  @dom.IsElement::set_attribute(canvas_element, "width", "96")
  @dom.IsElement::set_attribute(canvas_element, "height", "64")
  if document.get_body() is Some(body) {
    @dom.IsNode::append_child(body, @dom.IsNode::as_node(canvas_element))
    if @dom.IsEventTarget::to_html_canvas_element(canvas_element)
      is Some(canvas) {
      record(failures, canvas.get_width() == 96, "canvas_width")
      record(failures, canvas.get_height() == 64, "canvas_height")
      if canvas.get_context("2d").to0() is Some(context) {
        record(failures, !context.is_context_lost(), "context_lost")
        context.save()
        context.scale(1.0, 1.0)
        context.rotate(0.0)
        context.translate(1.0, 1.0)
        context.transform(1.0, 0.0, 0.0, 1.0, 0.0, 0.0)
        context.set_transform(1.0, 0.0, 0.0, 1.0, 0.0, 0.0)
        context.reset_transform()
        context.restore()

        context.set_image_smoothing_quality("high")
        record(
          failures,
          context.get_image_smoothing_quality() == "high",
          "smoothing_quality",
        )
        ignore(context.image_smoothing_enabled())
        let line_cap = context.get_line_cap()
        let line_join = context.get_line_join()
        context.set_line_cap(line_cap)
        context.set_line_join(line_join)
        context.set_line_width(3.0)
        record(failures, context.get_line_with() == 3.0, "line_width")
        record(
          failures,
          physical_equal(context.get_line_cap(), line_cap),
          "line_cap",
        )
        record(
          failures,
          physical_equal(context.get_line_join(), line_join),
          "line_join",
        )

        let fill : @js.Union3[String, @dom.CanvasGradient, @dom.CanvasPattern] = @js.Union3::from0(
          "rgb(255, 0, 0)",
        )
        let stroke : @js.Union3[String, @dom.CanvasGradient, @dom.CanvasPattern] = @js.Union3::from0(
          "rgb(0, 0, 255)",
        )
        context.set_fill_style(fill)
        context.set_stroke_style(stroke)
        record(
          failures,
          context.get_fill_style().to0() is Some(_),
          "fill_style",
        )
        record(
          failures,
          context.get_stroke_style().to0() is Some(_),
          "stroke_style",
        )
        context.set_font("12px sans-serif")
        record(failures, context.get_font().contains("12px"), "canvas_font")

        let linear = context.create_linear_gradient(0.0, 0.0, 20.0, 0.0)
        linear.add_color_stop(0.0, "red")
        linear.add_color_stop(1.0, "blue")
        context.set_fill_style(@js.Union3::from1(linear))
        record(
          failures,
          context.get_fill_style().to1() is Some(_),
          "linear_gradient",
        )
        let radial = context.create_radial_gradient(
          10.0, 10.0, 1.0, 10.0, 10.0, 10.0,
        )
        radial.add_color_stop(0.0, "white")
        radial.add_color_stop(1.0, "black")
        context.set_stroke_style(@js.Union3::from1(radial))
        record(
          failures,
          context.get_stroke_style().to1() is Some(_),
          "radial_gradient",
        )

        let image : @dom.ImageUnion = @js.Union7::from3(canvas)
        let pattern = context.create_pattern(image, "repeat")
        pattern.set_transform(@js.Optional::undefined())
        context.set_fill_style(@js.Union3::from2(pattern))
        record(
          failures,
          context.get_fill_style().to2() is Some(_),
          "canvas_pattern",
        )

        context.clear_rect(0.0, 0.0, 96.0, 64.0)
        context.fill_rect(0.0, 0.0, 20.0, 20.0)
        context.stroke_rect(0.0, 0.0, 20.0, 20.0)
        context.begin_path()
        context.move_to(2.0, 2.0)
        context.line_to(18.0, 2.0)
        context.arc(10.0, 10.0, 5.0, 0.0, 6.28)
        context.arc_to(2.0, 2.0, 8.0, 8.0, 2.0)
        context.bezier_curve_to(1.0, 1.0, 2.0, 2.0, 3.0, 3.0)
        context.quardratic_curve_to(3.0, 3.0, 4.0, 4.0)
        context.ellipse(10.0, 10.0, 4.0, 2.0, 0.0, 0.0, 6.28)
        context.rect(1.0, 1.0, 10.0, 10.0)
        context.round_rect(2.0, 2.0, 8.0, 8.0, 2.0)
        context.close_path()
        context.fill()
        context.stroke()
        context.clip()
        ignore(context.is_point_in_path(4.0, 4.0))
        ignore(context.is_point_in_stroke(4.0, 4.0))

        let path = @dom.Path2D::new()
        let path_text : @js.Union2[@dom.Path2D, String] = @js.Union2::from1(
          "M0 0 L12 0 L12 12 Z",
        )
        let path_from_text = @dom.Path2D::new(
          path=@js.Optional::from_option(Some(path_text)),
        )
        path.add_path(path_from_text)
        context.fill_path(path)
        context.stroke_with_path(path)
        context.clip_with_path(path)
        ignore(context.is_point_in_path_with_path(path, 2.0, 2.0))
        ignore(context.is_point_in_stroke_with_path(path, 2.0, 2.0))

        context.fill_text("rabbit", 2.0, 14.0)
        context.fill_text(
          "rabbit",
          2.0,
          28.0,
          max_width=@js.Optional::from_option(Some(50.0)),
        )
        context.stroke_text("rabbit", 2.0, 42.0)
        context.stroke_text(
          "rabbit",
          2.0,
          56.0,
          max_width=@js.Optional::from_option(Some(50.0)),
        )
        context.draw_image(image, 0.0, 0.0)
        context.draw_image_with_size(image, 0.0, 0.0, 20.0, 20.0)
        context.draw_image_with_src_and_dst_size(
          image, 0.0, 0.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0,
        )

        let settings = @dom.ImageDataSettings::new("srgb")
        let image_data = context.create_image_data(
          4.0,
          3.0,
          settings=@js.Optional::from_option(Some(settings)),
        )
        record(failures, image_data.get_width() == 4, "image_data_width")
        record(failures, image_data.get_height() == 3, "image_data_height")
        record(
          failures,
          image_data.get_color_space() == "srgb",
          "image_data_color_space",
        )
        let copied = @dom.ImageData::new_with_data(
          image_data.get_data(),
          4,
          3,
          settings=@js.Optional::from_option(Some(settings)),
        )
        let empty = @dom.ImageData::new(
          2,
          2,
          @js.Optional::from_option(Some(settings)),
        )
        record(failures, copied.get_width() == 4, "image_data_copy")
        record(failures, empty.get_height() == 2, "image_data_constructor")
        let derived = context.create_image_data_with_data(image_data)
        record(failures, derived.get_width() == 4, "create_image_data_copy")
        context.put_image_data(copied, 0, 0)
        context.put_image_data_with_dirty(copied, 0, 0, 0, 0, 2, 2)
        let readback = context.get_image_data(
          0.0,
          0.0,
          2.0,
          2.0,
          settings=@js.Optional::from_option(Some(settings)),
        )
        record(failures, readback.get_width() == 2, "get_image_data")
        context.reset()
      } else {
        failures.push("2d_context")
      }
      ignore(canvas.get_context("webgl"))
      ignore(canvas.get_context("webgl2"))
      ignore(canvas.get_context("webgpu"))
    } else {
      failures.push("canvas_conversion")
    }
    @dom.IsNode::remove_child(body, @dom.IsNode::as_node(canvas_element))
  } else {
    failures.push("missing_body")
  }
  finish_probe(failures)
}
