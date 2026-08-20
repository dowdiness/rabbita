///|
/// https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorkerContainer
#cfg(target="js")
#external
pub type ServiceWorkerContainer

///|
#cfg(target="js")
pub impl IsEventTarget for ServiceWorkerContainer

///|
#cfg(target="js")
pub impl @js.Cast for ServiceWorkerContainer with fn into(value) {
  value |> ffi_to_service_worker_container |> y => { y.to_option() }
}

///|
#cfg(target="js")
pub impl @js.Cast for ServiceWorkerContainer with fn from(value) {
  value |> js_identity
}

///|
#cfg(target="js")
extern "js" fn ffi_to_service_worker_container(
  x : @js.Value,
) -> @js.Nullable[ServiceWorkerContainer] =
  #| (x) => typeof ServiceWorkerContainer !== "undefined"
  #|   && x instanceof ServiceWorkerContainer
  #|   ? x
  #|   : null

///|
/// https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorkerContainer/controller
///
/// Returns the `ServiceWorker` whose state is `activating` or `activated` and
/// that controls this page, or `null`.
#cfg(target="js")
pub extern "js" fn ServiceWorkerContainer::controller(
  self : ServiceWorkerContainer,
) -> @js.Nullable[ServiceWorker] =
  #| (self) => self.controller

///|
/// https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorkerContainer/ready
///
/// Returns a `Promise` that resolves to the `ServiceWorkerRegistration`
/// associated with the current page once a service worker is active.
/// Unlike `getRegistration`, this never rejects and never resolves to
/// `undefined`.
#cfg(target="js")
pub extern "js" fn ServiceWorkerContainer::ready(
  self : ServiceWorkerContainer,
) -> @js.Promise =
  #| (self) => self.ready

///|
/// https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorkerContainer/getRegistration
///
/// Returns a `Promise` that resolves to the `ServiceWorkerRegistration` whose
/// scope matches `client_url`, or `undefined` when no registration matches.
///
/// When `client_url` is omitted, this calls `getRegistration()` without
/// arguments.
#cfg(target="js")
pub extern "js" fn ServiceWorkerContainer::get_registration(
  self : ServiceWorkerContainer,
  client_url? : @js.Optional[String] = @js.Optional::undefined(),
) -> @js.Promise =
  #| (self, clientUrl) =>
  #|   clientUrl === undefined ? self.getRegistration() : self.getRegistration(clientUrl)

///|
/// https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorkerContainer/getRegistrations
///
/// Returns a `Promise` that resolves to an array of all
/// `ServiceWorkerRegistration` objects for this origin.
#cfg(target="js")
pub extern "js" fn ServiceWorkerContainer::get_registrations(
  self : ServiceWorkerContainer,
) -> @js.Promise =
  #| (self) => self.getRegistrations()

///|
/// https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorkerContainer/register
///
/// Creates or updates a `ServiceWorkerRegistration` for the given `script_url`.
/// Returns a `Promise` that resolves to the `ServiceWorkerRegistration`.
/// `options` is the Web API options bag (`scope`, `type`, `updateViaCache`).
#cfg(target="js")
pub extern "js" fn ServiceWorkerContainer::register(
  self : ServiceWorkerContainer,
  script_url : String,
  options? : @js.Optional[@js.Value] = @js.Optional::undefined(),
) -> @js.Promise =
  #| (self, scriptUrl, options) =>
  #|   options === undefined ? self.register(scriptUrl) : self.register(scriptUrl, options)

///|
/// https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorkerContainer/startMessages
///
/// Explicitly starts the flow of messages from a controlling service worker
/// to pages it controls, so they can react before the page finishes loading.
#cfg(target="js")
pub extern "js" fn ServiceWorkerContainer::start_messages(
  self : ServiceWorkerContainer,
) -> Unit =
  #| (self) => self.startMessages()
