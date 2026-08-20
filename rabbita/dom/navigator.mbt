///|
#cfg(target="js")
#external
pub type Navigator

///|
#cfg(target="js")
pub extern "js" fn Navigator::clipboard(self : Navigator) -> Clipboard =
  #| (self) => self.clipboard

///|
#cfg(target="js")
pub extern "js" fn Navigator::service_worker(
  self : Navigator,
) -> ServiceWorkerContainer =
  #| (self) => self.serviceWorker
