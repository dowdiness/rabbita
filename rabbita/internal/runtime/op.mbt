///|
extenum @cmd.Extension += {
  Message(@slotmap.Id, @any.Any)
}

///|
let op : @cmd.Op = @cmd.Op()..on_invoke((extension, _context) => {
  match extension {
    Message(id, erased_msg) => {
      guard global_stores.get(id) is Some(store) else { None }
      LegacyEffect(Immediately, scheduler => {
        let cmd = (store.on_update)(scheduler, erased_msg)
        scheduler.queue_command(cmd)
      })
    }
    _ => raise Unhandled
  }
})
