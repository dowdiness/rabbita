let nextId = 0;

function serialize(value) {
  return { type: "RAW", value };
}

function deserialize(message) {
  if (message.type === "RAW") {
    return message.value;
  }
  if (message.type === "HANDLER" && message.name === "throw") {
    const errorValue = message.value;
    if (errorValue?.isError) {
      const error = new Error(errorValue.value.message);
      error.name = errorValue.value.name;
      error.stack = errorValue.value.stack;
      throw error;
    }
    throw errorValue?.value ?? errorValue;
  }
  throw new Error(`Unsupported worker response: ${message.type}`);
}

export function createMooncWorker() {
  const worker = new Worker(new URL("./moonc-worker-bridge.js", import.meta.url), {
    name: "moonc-worker",
  });
  const pending = new Map();

  worker.addEventListener("message", (event) => {
    const id = event.data?.id;
    const entry = pending.get(id);
    if (!entry) {
      return;
    }
    pending.delete(id);
    try {
      entry.resolve(deserialize(event.data));
    } catch (error) {
      entry.reject(error);
    }
  });

  worker.addEventListener("error", (event) => {
    for (const entry of pending.values()) {
      entry.reject(event.error || new Error(event.message));
    }
    pending.clear();
  });

  function call(name, argument) {
    const id = `rpc-${++nextId}`;
    const promise = new Promise((resolve, reject) => {
      pending.set(id, { resolve, reject });
    });
    worker.postMessage({
      id,
      type: "APPLY",
      path: [name],
      argumentList: [serialize(argument)],
    });
    return promise;
  }

  return {
    buildPackage: (params) => call("buildPackage", params),
    linkCore: (params) => call("linkCore", params),
    genTestInfo: (params) => call("genTestInfo", params),
    terminate: () => worker.terminate(),
  };
}
