///|
using @rabbita {type Cmd, type Emit, type Html, type Val}

///|
using @html {button, div, h1, p}

///|
priv struct Model {
  url : String
  generation : Int
  connected : @worker.Connection?
  next_id : Int
  status : String
  results : String
  tagger : Bool
  old_count : Int
  new_count : Int
  mounted : Bool
  pending_ids : Array[String]
  settlements : Int
} derive(Eq)

///|
priv enum Msg {
  WorkerEvent(@worker.Event, Bool)
  Reply(@worker.Connection, String, Result[Json, @worker.Failure])
  QueueDelayedReply(@worker.Connection, String, Result[Json, @worker.Failure])
  SendOne
  SendDelayed
  SendDuplicate
  SendHold
  SendConcurrent
  ReplaceUrl
  ReplaceGeneration
  Retag
  ToggleOwner
  QueueOldThenReplace
  SendInvalidTimeout
  SetMode(String)
}

///|
fn failure_name(failure : @worker.Failure) -> String {
  match failure {
    Unavailable => "Unavailable"
    ConstructionFailed => "ConstructionFailed"
    ConnectionClosed => "ConnectionClosed"
    PostFailed => "PostFailed"
    WorkerFailed => "WorkerFailed"
    MessageError => "MessageError"
    InvalidMessage => "InvalidMessage"
    Timeout => "Timeout"
    InvalidTimeout => "InvalidTimeout"
  }
}

///|
fn update(model : Model, message : Msg, emit : Emit[Msg]) -> (Model, Cmd) {
  match message {
    WorkerEvent(event, used_new_tagger) =>
      match event {
        Connected(connection) =>
          (
            {
              ..model,
              connected: Some(connection),
              status: if used_new_tagger {
                "connected via new tagger"
              } else {
                "connected via old tagger"
              },
              old_count: if used_new_tagger {
                model.old_count
              } else {
                model.old_count + 1
              },
              new_count: if used_new_tagger {
                model.new_count + 1
              } else {
                model.new_count
              },
            },
            @rabbita.none,
          )
        Failed(connection, failure) =>
          (
            {
              ..model,
              connected: match connection {
                Some(value) =>
                  if model.connected is Some(current) && current == value {
                    None
                  } else {
                    model.connected
                  }
                None => model.connected
              },
              status: "failed: \{failure_name(failure)}",
              old_count: if used_new_tagger {
                model.old_count
              } else {
                model.old_count + 1
              },
              new_count: if used_new_tagger {
                model.new_count + 1
              } else {
                model.new_count
              },
            },
            @rabbita.none,
          )
      }
    Reply(connection, id, result) => {
      // Count delivery before domain deduplication so tests detect double
      // settlement in the binding rather than hiding it behind this guard.
      let model = { ..model, settlements: model.settlements + 1, }
      if model.connected != Some(connection) || !model.pending_ids.contains(id) {
        (model, @rabbita.none)
      } else if !model.mounted && result is Ok(_) {
        (model, @rabbita.none)
      } else {
        let rendered = match result {
          Ok(Json::String(value)) => "\{id}=\{value}"
          Ok(_) => "\{id}=unexpected-json"
          Err(failure) => "\{id}=\{failure_name(failure)}"
        }
        let pending_ids = model.pending_ids.filter(request_id => {
          request_id != id
        })
        (
          {
            ..model,
            pending_ids,
            results: if model.results == "" {
              rendered
            } else {
              "\{model.results};\{rendered}"
            },
          },
          @rabbita.none,
        )
      }
    }
    QueueDelayedReply(connection, id, result) =>
      (
        { ..model, status: "reply queued for domain admission", },
        @rabbita.delay(emit(Reply(connection, id, result)), 100),
      )
    SendOne => send_request(model, emit, "work:one", 15000)
    SendDelayed => send_delayed_request(model, emit)
    SendDuplicate => send_request(model, emit, "work:duplicate", 15000)
    SendHold => send_request(model, emit, "work:hold", 100)
    SendConcurrent => {
      let (after_a, command_a) = send_request(model, emit, "work:slow", 15000)
      let (after_b, command_b) = send_request(after_a, emit, "work:fast", 15000)
      (after_b, @rabbita.batch([command_a, command_b]))
    }
    ReplaceUrl =>
      (
        {
          ..model,
          url: "/worker.js?mode=normal&url-replacement=1",
          status: "replacing url",
        },
        @rabbita.none,
      )
    ReplaceGeneration =>
      (
        {
          ..model,
          generation: model.generation + 1,
          status: "replacing generation",
        },
        @rabbita.none,
      )
    Retag =>
      ({ ..model, tagger: !model.tagger, status: "retagged", }, @rabbita.none)
    ToggleOwner =>
      (
        {
          ..model,
          mounted: !model.mounted,
          status: if model.mounted {
            "owner disabled"
          } else {
            "owner enabled"
          },
        },
        @rabbita.none,
      )
    QueueOldThenReplace => {
      let (after_request, command) = send_request(
        model, emit, "work:queued-old", 15000,
      )
      (
        {
          ..after_request,
          url: "/worker.js?mode=normal&queued-replacement=1",
          status: "queued old request; replacing",
        },
        command,
      )
    }
    SendInvalidTimeout => send_request(model, emit, "work:invalid-timeout", 0)
    SetMode(mode) =>
      (
        {
          ..model,
          url: "/worker.js?mode=\{mode}",
          status: "replacing with \{mode}",
        },
        @rabbita.none,
      )
  }
}

///|
fn send_request(
  model : Model,
  emit : Emit[Msg],
  value : String,
  timeout_ms : Int,
) -> (Model, Cmd) {
  let id = "r\{model.next_id}"
  match model.connected {
    None => ({ ..model, status: "not connected", }, @rabbita.none)
    Some(connection) => {
      let pending_ids = model.pending_ids.copy()
      pending_ids.push(id)
      (
        {
          ..model,
          next_id: model.next_id + 1,
          pending_ids,
          status: "requesting \{id}",
        },
        @worker.request(
          connection,
          Json::string(value),
          reply=fn(result) { emit(Reply(connection, id, result)) },
          timeout_ms~,
        ),
      )
    }
  }
}

///|
fn send_delayed_request(model : Model, emit : Emit[Msg]) -> (Model, Cmd) {
  let id = "r\{model.next_id}"
  match model.connected {
    None => ({ ..model, status: "not connected", }, @rabbita.none)
    Some(connection) => {
      let pending_ids = model.pending_ids.copy()
      pending_ids.push(id)
      (
        {
          ..model,
          next_id: model.next_id + 1,
          pending_ids,
          status: "requesting delayed \{id}",
        },
        @worker.request(connection, Json::string("work:one"), reply=fn(result) {
          emit(QueueDelayedReply(connection, id, result))
        }),
      )
    }
  }
}

///|
fn subscriptions(model : Model, emit : Emit[Msg]) -> @sub.Sub {
  if model.mounted {
    @worker.listen("worker-fixture", model.url, generation=model.generation, on_event=fn(
      event,
    ) {
      emit(WorkerEvent(event, model.tagger))
    })
  } else {
    @sub.none
  }
}

///|
fn worker_panel() -> Val[Html] {
  let initial : Model = {
    url: "/worker.js?mode=normal",
    generation: 0,
    connected: None,
    next_id: 1,
    status: "starting",
    results: "",
    tagger: false,
    old_count: 0,
    new_count: 0,
    mounted: true,
    pending_ids: [],
    settlements: 0,
  }
  let (model, emit) = @rabbita.create_state(initial, update~, subscriptions~)
  model.view(model => {
    div <| [
      h1("Worker binding fixture"),
      p(id="worker-status", "status: \{model.status}"),
      p(id="worker-results", "results: \{model.results}"),
      p(id="worker-settlements", "settlements: \{model.settlements}"),
      p(id="worker-generation", "generation: \{model.generation}"),
      p(
        id="worker-tagger",
        if model.tagger {
          "tagger: new"
        } else {
          "tagger: old"
        },
      ),
      p(id="old-events", "old events: \{model.old_count}"),
      p(id="new-events", "new events: \{model.new_count}"),
      button(on_click=emit(SendOne), "Send request"),
      button(on_click=emit(SendDelayed), "Send delayed-response request"),
      button(on_click=emit(SendConcurrent), "Send concurrent requests"),
      button(on_click=emit(SendDuplicate), "Send duplicate-reply request"),
      button(on_click=emit(SendHold), "Send held request"),
      button(on_click=emit(Retag), "Retag callbacks"),
      button(on_click=emit(ReplaceUrl), "Replace Worker URL"),
      button(on_click=emit(ReplaceGeneration), "Replace Worker generation"),
      button(
        on_click=emit(QueueOldThenReplace),
        "Queue old request and replace",
      ),
      button(on_click=emit(SendInvalidTimeout), "Send invalid-timeout request"),
      button(on_click=emit(ToggleOwner), "Toggle Worker owner"),
      button(
        on_click=emit(SetMode("constructor")),
        "Use constructor-failing Worker",
      ),
      button(on_click=emit(SetMode("runtime")), "Use runtime-failing Worker"),
      button(on_click=emit(SetMode("malformed")), "Use malformed-reply Worker"),
      button(on_click=emit(SetMode("hold")), "Use holding Worker"),
    ]
  })
}

///|
fn app() -> Val[Html] {
  let (shown, set_shown) = @rabbita.create_variable(true)
  let (second_shown, set_second_shown) = @rabbita.create_variable(false)
  let panel = shown.switch_by(
    visible => {
      if visible {
        worker_panel()
      } else {
        Val::constant(
          div(id="worker-panel-unmounted", "Worker panel is unmounted"),
        )
      }
    },
    by=visible => visible.to_string(),
  )
  let second_panel = second_shown.switch_by(
    visible => {
      if visible {
        worker_panel()
      } else {
        Val::constant(div("Second Worker owner is not mounted"))
      }
    },
    by=visible => visible.to_string(),
  )
  shown.view4(panel, second_shown, second_panel, (
    visible,
    panel,
    second_visible,
    second_panel,
  ) => {
    div([
      button(
        on_click=set_shown(old => !old),
        if visible {
          "Unmount Worker panel"
        } else {
          "Mount Worker panel"
        },
      ),
      button(
        on_click=set_second_shown(old => !old),
        if second_visible {
          "Unmount second Worker owner"
        } else {
          "Mount second Worker owner"
        },
      ),
      panel,
      second_panel,
    ])
  })
}
