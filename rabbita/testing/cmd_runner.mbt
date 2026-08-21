///|
/// A deterministic command host for browser-side binding tests.
priv struct TestCmdScheduler {
  commands : Array[@cmd.Cmd]
}

///|
impl @cmd.Scheduler for TestCmdScheduler with fn queue_command(self, cmd) {
  self.commands.push(cmd)
}

///|
impl @cmd.Scheduler for TestCmdScheduler with fn set_url_changed_injector(
  self,
  injector,
) {
  ignore((self, injector))
}

///|
impl @cmd.Scheduler for TestCmdScheduler with fn set_url_request_injector(
  self,
  injector,
) {
  ignore((self, injector))
}

///|
impl @cmd.Context for TestCmdScheduler with fn get_origin(_self) {
  ""
}

///|
impl @cmd.Context for TestCmdScheduler with fn inject_url_changed(_self, _url) {
  @cmd.none
}

///|
impl @cmd.Context for TestCmdScheduler with fn inject_url_request(_self, _url) {
  @cmd.none
}

///|
async fn TestCmdScheduler::run(self : TestCmdScheduler) -> Unit {
  for index = 0; index < self.commands.length(); index = index + 1 {
    let cmd = self.commands[index]
    for task in @cmd.flatten(@key.key, cmd) {
      let (op, extension) = task
      match @cmd.invoke(@key.key, op, extension, self) {
        None => ()
        Ready(cmd) => self.commands.push(cmd)
        Async(f) => self.commands.push(f())
        AfterLayout(f) => self.commands.push(f())
        LegacyEffect(_, f) => f(self)
      }
    }
  }
}

///|
/// Execute a command through a deterministic scheduler for browser-side tests.
///
/// Immediate and after-render effects run during the drain. Async commands are
/// awaited and their resulting commands are drained in FIFO order.
pub async fn run_cmd(cmd : @cmd.Cmd) -> Unit {
  let scheduler = TestCmdScheduler::{ commands: [cmd] }
  scheduler.run()
}
