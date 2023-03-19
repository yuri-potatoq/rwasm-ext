const runtime = chrome.runtime || browser.runtime;

(
async () => 
    await wasm_bindgen(runtime.getURL('wwasm_bg.wasm'))
)()
