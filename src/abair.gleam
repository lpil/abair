import gleam/bit_array
import gleam/bool
import gleam/dynamic/decode
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/json
import gleam/result

pub type Synthesised {
  Synthesised(phonemes: List(String), audio: BitArray)
}

fn synthesised_decoder() -> decode.Decoder(Synthesised) {
  use phonemes <- decode.field("phonemes", decode.list(decode.string))
  use audio <- decode.field("audioContent", {
    use text <- decode.then(decode.string)
    case bit_array.base64_decode(text) {
      Ok(audio) -> decode.success(audio)
      Error(_) -> decode.failure(<<>>, "Base64 encoded data")
    }
  })
  decode.success(Synthesised(phonemes:, audio:))
}

pub type AbairError {
  UnexpectedResponse
  FailedToDecodeJson(json.DecodeError)
}

/// Create a request to abair.ie
pub fn synthesis_request(content: String) -> Request(String) {
  let query = [
    #("input", content),
    #("voice", "ga_MU_cmg_piper"),
    #("normalise", "true"),
  ]

  request.new()
  |> request.set_method(http.Get)
  |> request.set_query(query)
  |> request.set_host("synthesis.abair.ie")
  |> request.set_path("/api/synthesise")
  |> request.prepend_header("content-type", "application/json")
}

/// Parse a synthesis response from abair.ie
pub fn synthesis_response(
  response: Response(String),
) -> Result(Synthesised, AbairError) {
  use <- bool.guard(response.status != 200, Error(UnexpectedResponse))
  json.parse(response.body, synthesised_decoder())
  |> result.map_error(FailedToDecodeJson)
}
