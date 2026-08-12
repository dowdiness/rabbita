///|
using @cmd {trait Host}

///|
pub using @vdom {type Children, type Props, type VNode, type VDom}

///|
using @cmd {trait Context, trait Scheduler}

///|
using @queue {type Queue}

///|
const RABBITA_TRANSCRIPT_ID = "__rabbita_transcript"

///|
type GraphBuilder = () -> @duplix.Node[@vdom.VNode]

///|
pub let ambient_host : Ref[&Host?] = Ref(None)
