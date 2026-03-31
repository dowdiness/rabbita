///|
using @interface {trait Scheduler}

///|
using @cmd {type Cmd}

///|
struct Sub(Map[String, @interface.CustomSubscription])

///|
fn custom_subscription(
  key : String,
  load : (&Scheduler) -> () -> Unit,
) -> Sub {
  Map::from_array([(key, load)])
}

///|
pub impl @interface.Subscription for Sub with to_map(self) {
  self.0
}

///|
pub fn every(ms : Int, cmd : @cmd.Cmd) -> Sub {
  custom_subscription("every(\{ms})", scheduler => {
    let id : Int = @dom.window().set_interval(
      () => scheduler.add_cmds(cmd.to_array()),
      ms,
    )
    fn() { @dom.window().clear_interval(id) }
  })
}

///|
pub fn on_resize(cmd : Cmd) -> Sub {
  custom_subscription("on_resize", scheduler => {
    let listener : @dom.Listener = _ => scheduler.add_cmds(cmd.to_array())
    @dom.window().add_event_listener("resize", listener)
    fn() { @dom.window().remove_event_listener("resize", listener) }
  })
}

///|
pub let none : Sub = {}

///|
pub fn batch(xs : Array[Sub]) -> Sub {
  let r = {}
  for x in xs {
    for k, v in x.0 {
      r[k] = v
    }
  }
  r
}
