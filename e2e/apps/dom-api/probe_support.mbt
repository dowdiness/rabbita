///|
fn record(failures : Array[String], condition : Bool, label : String) -> Unit {
  if !condition {
    failures.push(label)
  }
}

///|
fn finish_probe(failures : Array[String]) -> String {
  if failures.is_empty() {
    "passed"
  } else {
    let joined = failures.join(", ")
    "failed: \{joined}"
  }
}

///|
fn set_result(id : String, value : String) -> Unit {
  if @dom.document().get_element_by_id(id).to_option() is Some(element) {
    @dom.IsElement::set_inner_html(element, value)
  }
}

///|
fn element_by_id(id : String) -> @dom.Element? {
  @dom.document().get_element_by_id(id).to_option()
}
