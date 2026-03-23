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
  let payload =
    json.object([
      #(
        "synthinput",
        json.object([
          #("text", json.string(content)),
          #("ssml", json.string("string")),
        ]),
      ),
      #(
        "voiceparams",
        json.object([
          #("languageCode", json.string("ga-IE")),
          #("name", json.string("ga_MU_cmg_piper")),
          #("ssmlGender", json.string("UNSPECIFIED")),
        ]),
      ),
      #(
        "audioconfig",
        json.object([
          #("audioEncoding", json.string("LINEAR16")),
          #("speakingRate", json.int(1)),
          #("volumeGainDb", json.int(1)),
          #("htsParams", json.string("string")),
          #("sampleRateHertz", json.int(0)),
          #("effectsProfileId", json.preprocessed_array([])),
        ]),
      ),
      #("outputType", json.string("JSON")),
    ])
  request.new()
  |> request.set_method(http.Post)
  |> request.set_host("api.abair.ie")
  |> request.set_path("/v3/synthesis")
  |> request.prepend_header("content-type", "application/json")
  |> request.set_body(json.to_string(payload))
}

/// Parse a synthesis response from abair.ie
pub fn synthesis_response(
  response: Response(String),
) -> Result(Synthesised, AbairError) {
  use <- bool.guard(response.status != 200, Error(UnexpectedResponse))
  json.parse(response.body, synthesised_decoder())
  |> result.map_error(FailedToDecodeJson)
}
