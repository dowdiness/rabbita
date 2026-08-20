///|
/// https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorker
#cfg(target="js")
#external
pub type ServiceWorker

///|
#cfg(target="js")
pub impl IsEventTarget for ServiceWorker

///|
#cfg(target="js")
pub impl @js.Cast for ServiceWorker with fn into(value) {
  value |> ffi_to_service_worker |> y => { y.to_option() }
}

///|
#cfg(target="js")
pub impl @js.Cast for ServiceWorker with fn from(value) {
  value |> js_identity
}

///|
#cfg(target="js")
extern "js" fn ffi_to_service_worker(
  x : @js.Value,
) -> @js.Nullable[ServiceWorker] =
  #| (x) => typeof ServiceWorker !== "undefined"
  #|   && x instanceof ServiceWorker
  #|   ? x
  #|   : null

///|
/// https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorker/scriptURL
#cfg(target="js")
pub extern "js" fn ServiceWorker::script_url(self : ServiceWorker) -> String =
  #| (self) => self.scriptURL

///|
/// https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorker/state
#cfg(target="js")
pub extern "js" fn ServiceWorker::state(self : ServiceWorker) -> String =
  #| (self) => self.state

///|
/// https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorker/postMessage
///
/// Sends a message — consisting of any structured-cloneable JavaScript object
/// — to the service worker. On the worker side the message is delivered as a
/// `MessageEvent` on `ServiceWorkerGlobalScope`. `transfer` is the optional
/// transfer list from the Web API overload.
#cfg(target="js")
pub extern "js" fn ServiceWorker::post_message(
  self : ServiceWorker,
  message : @js.Value,
  transfer? : @js.Optional[@js.Value] = @js.Optional::undefined(),
) -> Unit =
  #| (self, message, transfer) =>
  #|   transfer === undefined ? self.postMessage(message) : self.postMessage(message, transfer)
