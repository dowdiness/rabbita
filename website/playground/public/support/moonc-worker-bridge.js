const mooncModule = { exports: {} };
self.module = mooncModule;
self.exports = mooncModule.exports;
const workerUrl = new URL("../vendor/moonc-worker.js", self.location.href);
const revision = new URL(self.location.href).searchParams.get("v");
if (revision) {
  workerUrl.searchParams.set("v", revision);
}
importScripts(workerUrl.href);

const moonc = mooncModule.exports;

function raw(value) {
  return { type: "RAW", value };
}

function throwable(error) {
  const fallback = String(error);
  return {
    type: "HANDLER",
    name: "throw",
    value: {
      isError: error instanceof Error,
      value: {
        name: (error && error.name) || "Error",
        message: (error && error.message) || fallback,
        stack: (error && error.stack) || "",
      },
    },
  };
}

function deserialize(argument) {
  if (argument && argument.type === "RAW") {
    return argument.value;
  }
  throw new Error("Unsupported worker argument: " + (argument && argument.type));
}

self.addEventListener("message", (event) => {
  const message = event.data || {};
  const id = message.id;

  try {
    if (message.type !== "APPLY") {
      throw new Error("Unsupported worker request: " + message.type);
    }

    const name = message.path && message.path[0];
    const fn = moonc[name];
    if (typeof fn !== "function") {
      throw new Error("MoonBit compiler function is not available: " + name);
    }

    const args = (message.argumentList || []).map(deserialize);
    self.postMessage({ id, ...raw(fn(...args)) });
  } catch (error) {
    self.postMessage({ id, ...throwable(error) });
  }
});
