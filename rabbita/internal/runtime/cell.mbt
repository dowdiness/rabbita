///|
pub(open) trait IsCell {
  fn init(Self, &@cmd.Scheduler) -> Unit
  fn view(Self) -> VNode
  fn to_dyn(Self) -> @incremental.Dyn[VNode]
}
