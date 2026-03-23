# abair

A client for abair.ie's Gaeilge voice synthesis

[![Package Version](https://img.shields.io/hexpm/v/abair)](https://hex.pm/packages/abair)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/abair/)

```sh
gleam add abair@1
```
```gleam
import abair
import gleam/httpc
import simplifile

pub fn main() {
  let assert Ok(response) = abair.synthesis_request("Dia duit!") |> httpc.send
  let assert Ok(synthesized) = abair.synthesis_response(response)
  simplifile.write_bits("greeting.wav", synthesized.audio)
}
```

Further documentation can be found at <https://hexdocs.pm/abair>.
