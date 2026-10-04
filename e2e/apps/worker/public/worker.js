let workCount = 0;

self.addEventListener('message', (event) => {
  let request;
  try {
    request = JSON.parse(event.data);
  } catch {
    self.postMessage('{malformed');
    return;
  }

  const mode = new URL(self.location.href).searchParams.get('mode');
  if (mode === 'runtime') throw new Error('worker fixture runtime failure');
  if (!request || request.rabbita_worker !== 1 || request.kind !== 'request') {
    self.postMessage('{"rabbita_worker":1,"id":"bad","kind":"result","payload":"bad request"}');
    return;
  }

  // A monotonically changing side effect makes accidental posts to a replacement
  // or post-after-timeout observable in the returned value.
  workCount += 1;
  const payload = String(request.payload);
  if (payload === 'work:hold') return;

  const result = {
    rabbita_worker: 1,
    id: request.id,
    kind: 'result',
    payload: `${workCount}|${payload}`,
  };
  const send = () => self.postMessage(JSON.stringify(result));

  if (mode === 'malformed') {
    self.postMessage('{not-json');
  } else if (payload === 'work:slow') {
    setTimeout(send, 80);
  } else if (payload === 'work:duplicate') {
    send();
    setTimeout(send, 0);
  } else {
    send();
  }
});
