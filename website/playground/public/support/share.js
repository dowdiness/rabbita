(function () {
  const state = { shared: undefined };

  function fileKey(name) {
    switch (name) {
      case "mbt": return "main.mbt";
      case "html": return "index.html";
      case "css": return "style.css";
      case "moon_pkg": return "moon.pkg";
      default: return name;
    }
  }

  function currentUrl() {
    return new URL(window.location.href);
  }

  const shareAlphabet =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
  const shareReverse = Object.create(null);
  for (let i = 0; i < shareAlphabet.length; i += 1) {
    shareReverse[shareAlphabet.charAt(i)] = i;
  }

  function pushCompressedBit(context, bitsPerChar, bit) {
    context.dataVal = (context.dataVal << 1) | bit;
    if (context.dataPosition === bitsPerChar - 1) {
      context.dataPosition = 0;
      context.data.push(shareAlphabet.charAt(context.dataVal));
      context.dataVal = 0;
    } else {
      context.dataPosition += 1;
    }
  }

  function pushCompressedValue(context, bitsPerChar, value, bitCount) {
    for (let i = 0; i < bitCount; i += 1) {
      pushCompressedBit(context, bitsPerChar, value & 1);
      value >>= 1;
    }
  }

  function compressToUrl(value) {
    const dictionary = Object.create(null);
    const pending = Object.create(null);
    let dictSize = 3;
    let numBits = 2;
    let enlargeIn = 2;
    let w = "";
    const context = { data: [], dataVal: 0, dataPosition: 0 };

    function decrementEnlarge() {
      enlargeIn -= 1;
      if (enlargeIn === 0) {
        enlargeIn = 1 << numBits;
        numBits += 1;
      }
    }

    function writeEntry(entry) {
      if (Object.prototype.hasOwnProperty.call(pending, entry)) {
        const code = entry.charCodeAt(0);
        if (code < 256) {
          pushCompressedValue(context, 6, 0, numBits);
          pushCompressedValue(context, 6, code, 8);
        } else {
          pushCompressedValue(context, 6, 1, numBits);
          pushCompressedValue(context, 6, code, 16);
        }
        decrementEnlarge();
        delete pending[entry];
      } else {
        pushCompressedValue(context, 6, dictionary[entry], numBits);
      }
      decrementEnlarge();
    }

    for (let i = 0; i < value.length; i += 1) {
      const c = value.charAt(i);
      if (!Object.prototype.hasOwnProperty.call(dictionary, c)) {
        dictionary[c] = dictSize;
        dictSize += 1;
        pending[c] = true;
      }
      const wc = w + c;
      if (Object.prototype.hasOwnProperty.call(dictionary, wc)) {
        w = wc;
      } else {
        writeEntry(w);
        dictionary[wc] = dictSize;
        dictSize += 1;
        w = c;
      }
    }

    if (w !== "") writeEntry(w);
    pushCompressedValue(context, 6, 2, numBits);
    for (;;) {
      context.dataVal <<= 1;
      if (context.dataPosition === 5) {
        context.data.push(shareAlphabet.charAt(context.dataVal));
        break;
      }
      context.dataPosition += 1;
    }
    return context.data.join("");
  }

  function readCompressedBits(data, bitCount) {
    let bits = 0;
    let power = 1;
    const maxPower = 1 << bitCount;
    while (power !== maxPower) {
      const bit = data.val & data.position;
      data.position >>= 1;
      if (data.position === 0) {
        data.position = 32;
        data.val = data.index < data.input.length
          ? shareReverse[data.input.charAt(data.index)] || 0
          : 0;
        data.index += 1;
      }
      if (bit > 0) bits |= power;
      power <<= 1;
    }
    return bits;
  }

  function decompressFromUrl(input) {
    if (!input) return "";
    const dictionary = [0, 1, 2];
    let enlargeIn = 4;
    let dictSize = 4;
    let numBits = 3;
    const data = {
      input,
      val: shareReverse[input.charAt(0)] || 0,
      position: 32,
      index: 1,
    };

    let next = readCompressedBits(data, 2);
    let c;
    if (next === 0) {
      c = String.fromCharCode(readCompressedBits(data, 8));
    } else if (next === 1) {
      c = String.fromCharCode(readCompressedBits(data, 16));
    } else {
      return "";
    }

    dictionary[3] = c;
    let w = c;
    const result = [c];

    for (;;) {
      const code = readCompressedBits(data, numBits);
      let entryCode = code;
      if (code === 0) {
        dictionary[dictSize] = String.fromCharCode(readCompressedBits(data, 8));
        entryCode = dictSize;
        dictSize += 1;
        enlargeIn -= 1;
      } else if (code === 1) {
        dictionary[dictSize] = String.fromCharCode(readCompressedBits(data, 16));
        entryCode = dictSize;
        dictSize += 1;
        enlargeIn -= 1;
      } else if (code === 2) {
        return result.join("");
      }

      if (enlargeIn === 0) {
        enlargeIn = 1 << numBits;
        numBits += 1;
      }

      let entry = dictionary[entryCode];
      if (entry === undefined) {
        if (entryCode === dictSize) {
          entry = w + w.charAt(0);
        } else {
          return "";
        }
      }

      result.push(entry);
      dictionary[dictSize] = w + entry.charAt(0);
      dictSize += 1;
      enlargeIn -= 1;
      w = entry;

      if (enlargeIn === 0) {
        enlargeIn = 1 << numBits;
        numBits += 1;
      }
    }
  }

  function encodeSharePayload(payload) {
    return compressToUrl(JSON.stringify(payload));
  }

  function decodeSharePayload(value) {
    return JSON.parse(decompressFromUrl(value));
  }

  function readSharedPayload() {
    if (state.shared !== undefined) return state.shared;
    let payload = null;
    try {
      const encoded = currentUrl().searchParams.get("share");
      if (encoded) payload = decodeSharePayload(encoded);
    } catch {
      payload = null;
    }
    state.shared = payload;
    return payload;
  }

  function readStoredField(field, fallback) {
    try {
      const parsed = JSON.parse(
        localStorage.getItem("rabbita-pure-mbt-playground") || "{}",
      );
      return typeof parsed[field] === "string" ? parsed[field] : fallback;
    } catch {
      return fallback;
    }
  }

  function readSource(field, fallback) {
    const shared = readSharedPayload();
    if (shared && typeof shared === "object") {
      if (field === "example" && typeof shared.example === "string") {
        return shared.example;
      }
      const files = shared.files && typeof shared.files === "object"
        ? shared.files
        : shared;
      const value = files[fileKey(field)];
      return typeof value === "string" ? value : fallback;
    }

    let example = "";
    try {
      example = currentUrl().searchParams.get("example") || "";
    } catch {
      example = "";
    }
    if (field === "example" && example) return example;
    if (example) return fallback;
    return readStoredField(field, fallback);
  }

  function saveSource(example, mbt, html, css, moonPkg) {
    localStorage.setItem("rabbita-pure-mbt-playground", JSON.stringify({
      example,
      mbt,
      html,
      css,
      moon_pkg: moonPkg,
    }));
    return Promise.resolve(null);
  }

  function setExampleUrl(example) {
    const url = currentUrl();
    url.search = "";
    url.hash = "";
    url.searchParams.set("example", example);
    window.history.pushState(null, "", url);
    state.shared = undefined;
  }

  function shareSource(example, mbt, html, css, moonPkg) {
    try {
      const payload = {
        v: 1,
        example,
        files: {
          "main.mbt": mbt,
          "index.html": html,
          "style.css": css,
          "moon.pkg": moonPkg,
        },
      };
      const encoded = encodeSharePayload(payload);
      const url = currentUrl();
      url.search = "";
      url.hash = "";
      url.searchParams.set("share", encoded);
      window.history.pushState(null, "", url);
      state.shared = payload;
      const href = url.href;
      const write = navigator.clipboard && navigator.clipboard.writeText;
      if (typeof write === "function") {
        return write.call(navigator.clipboard, href)
          .then(() => ({ ok: true, url: href, status: "Share URL copied" }))
          .catch(() => ({ ok: true, url: href, status: "Share URL ready" }));
      }
      return Promise.resolve({ ok: true, url: href, status: "Share URL ready" });
    } catch (error) {
      return Promise.resolve({
        ok: false,
        error: error && error.message ? error.message : String(error),
      });
    }
  }

  globalThis.RabbitaPlaygroundShare = {
    readSource,
    saveSource,
    hasSharedSource() {
      try {
        return currentUrl().searchParams.has("share");
      } catch {
        return false;
      }
    },
    hasExampleParam() {
      try {
        const url = currentUrl();
        return !url.searchParams.has("share") && !!url.searchParams.get("example");
      } catch {
        return false;
      }
    },
    setExampleUrl,
    shareSource,
  };
}());
