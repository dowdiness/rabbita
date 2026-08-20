///|
/// https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorkerRegistration
#cfg(target="js")
#external
pub type ServiceWorkerRegistration

///|
#cfg(target="js")
pub impl IsEventTarget for ServiceWorkerRegistration

///|
#cfg(target="js")
pub impl @js.Cast for ServiceWorkerRegistration with fn into(value) {
  value |> ffi_to_service_worker_registration |> y => { y.to_option() }
}

///|
#cfg(target="js")
pub impl @js.Cast for ServiceWorkerRegistration with fn from(value) {
  value |> js_identity
}

///|
#cfg(target="js")
extern "js" fn ffi_to_service_worker_registration(
  x : @js.Value,
) -> @js.Nullable[ServiceWorkerRegistration] =
  #| (x) => (x instanceof ServiceWorkerRegistration) ? x : null

///|
/// https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorkerRegistration/active
///
/// Returns the service worker whose state is `activating` or `activated`,
/// or `null`.
#cfg(target="js")
pub extern "js" fn ServiceWorkerRegistration::active(
  self : ServiceWorkerRegistration,
) -> @js.Nullable[ServiceWorker] =
  #| (self) => self.active

///|
/// https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorkerRegistration/installing
///
/// Returns the service worker whose state is `installing`, or `null`.
#cfg(target="js")
pub extern "js" fn ServiceWorkerRegistration::installing(
  self : ServiceWorkerRegistration,
) -> @js.Nullable[ServiceWorker] =
  #| (self) => self.installing

///|
/// https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorkerRegistration/scope
#cfg(target="js")
pub extern "js" fn ServiceWorkerRegistration::scope(
  self : ServiceWorkerRegistration,
) -> String =
  #| (self) => self.scope

///|
/// https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorkerRegistration/updateViaCache
///
/// Returns one of `"imports"`, `"all"`, or `"none"`, describing when the
/// browser consults the HTTP cache when updating the service worker script.
#cfg(target="js")
pub extern "js" fn ServiceWorkerRegistration::update_via_cache(
  self : ServiceWorkerRegistration,
) -> String =
  #| (self) => self.updateViaCache

///|
/// https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorkerRegistration/waiting
///
/// Returns the service worker whose state is `installed`, or `null`.
#cfg(target="js")
pub extern "js" fn ServiceWorkerRegistration::waiting(
  self : ServiceWorkerRegistration,
) -> @js.Nullable[ServiceWorker] =
  #| (self) => self.waiting

///|
/// https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorkerRegistration/unregister
///
/// Unregisters this registration. Returns a `Promise` that resolves to `true`
/// if the unregistration succeeded, `false` otherwise.
#cfg(target="js")
pub extern "js" fn ServiceWorkerRegistration::unregister(
  self : ServiceWorkerRegistration,
) -> @js.Promise =
  #| (self) => self.unregister()

///|
/// https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorkerRegistration/update
///
/// Checks the server for an updated version of the service worker script
/// without consulting caches.  Returns a `Promise` that resolves to the
/// updated `ServiceWorkerRegistration`.
#cfg(target="js")
pub extern "js" fn ServiceWorkerRegistration::update(
  self : ServiceWorkerRegistration,
) -> @js.Promise =
  #| (self) => self.update()
