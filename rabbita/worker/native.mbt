///|
#external
priv type NativeWorker

///|
extern "js" fn browser_available() -> Bool =
  #| () => typeof window !== "undefined" && typeof document !== "undefined" && typeof Worker === "function"

///|
// Native throws are caught here, not by MoonBit's checked-error channel.
extern "js" fn native_create(
  url : String,
  message : (String) -> Unit,
  error : () -> Unit,
  message_error : () -> Unit,
) -> @js.Nullable[NativeWorker] =
  #| (url, message, error, messageError) => {
  #|   let worker;
  #|   const onMessage = event => message(typeof event.data === "string" ? event.data : "");
  #|   const onError = event => { event.preventDefault(); error(); };
  #|   const onMessageError = () => messageError();
  #|   try {
  #|     worker = new Worker(url, {type: "module"});
  #|     worker.addEventListener("message", onMessage);
  #|     worker.addEventListener("error", onError);
  #|     worker.addEventListener("messageerror", onMessageError);
  #|     return {worker, onMessage, onError, onMessageError};
  #|   } catch (_) {
  #|     if (worker) {
  #|       worker.removeEventListener("message", onMessage);
  #|       worker.removeEventListener("error", onError);
  #|       worker.removeEventListener("messageerror", onMessageError);
  #|       worker.terminate();
  #|     }
  #|     return null;
  #|   }
  #| }

///|
extern "js" fn native_post(native : NativeWorker, text : String) -> Bool =
  #| (native, text) => {
  #|   try { native.worker.postMessage(text); return true; }
  #|   catch (_) { return false; }
  #| }

///|
extern "js" fn native_close(native : NativeWorker) -> Unit =
  #| native => {
  #|   const {worker, onMessage, onError, onMessageError} = native;
  #|   worker.removeEventListener("message", onMessage);
  #|   worker.removeEventListener("error", onError);
  #|   worker.removeEventListener("messageerror", onMessageError);
  #|   worker.terminate();
  #| }

///|
extern "js" fn timer_start(ms : Int, callback : () -> Unit) -> Int =
  #| (ms, callback) => setTimeout(callback, ms)

///|
extern "js" fn timer_clear(id : Int) -> Unit =
  #| id => clearTimeout(id)

///|
extern "js" fn callback_promise(
  register : ((@cmd.Cmd) -> Unit) -> Unit,
) -> @js.Promise[@cmd.Cmd] =
  #| register => new Promise(resolve => register(resolve))
