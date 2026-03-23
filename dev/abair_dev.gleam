import abair
import gleam/httpc
import simplifile

pub fn main() {
  let assert Ok(response) = abair.synthesis_request("Dia duit!") |> httpc.send
  let assert Ok(synthesized) = abair.synthesis_response(response)
  simplifile.write_bits("greeting.wav", synthesized.audio)
}
