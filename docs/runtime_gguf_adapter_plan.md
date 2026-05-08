# Runtime GGUF Adapter Plan

## القرار المختصر

- Primary: `llama-server` managed by Rust Engine.
- Fallback/debug only: `llama-cli`.
- Future: direct `llama.cpp` C API when the local runtime is stable.

## Step 22 scope

Step 22 starts real GGUF execution through Rust by managing a local `llama-server` process and calling its OpenAI-compatible chat completions endpoint.

## Runtime policy

- Flutter remains a control UI only.
- Rust starts/stops the local model runtime.
- First target is Gemma 4B only.
- 12B is deferred until 4B is stable.
- First generation mode is non-streaming.
- No hardcoded GGUF model path.
- The model path comes from the active model profile.
- Default runtime policy keeps `unload_after_response = true` unless the user explicitly changes it.

## Environment overrides

- `LOGIXA_LLAMA_SERVER_BIN`: optional path/name for the `llama-server` binary.
- `LOGIXA_LLAMA_SERVER_PORT`: optional local server port. Default: `8788`.
- `LOGIXA_LLAMA_SERVER_URL`: optional full local server URL.
