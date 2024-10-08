open! Core
open Async
open Types

let search ?title ?limit ?offset () =
  let query =
    List.filter_opt
      [ Option.map title ~f:(fun x -> "title", [ x ])
      ; Option.map limit ~f:(fun limit -> "limit", [ Int.to_string limit ])
      ; Option.map offset ~f:(fun offset ->
          "offset", [ Int.to_string offset ])
      ]
  in
  let uri =
    Uri.make ~scheme:"https" ~host:"api.mangadex.org" ~path:"manga" ~query ()
  in
  Deferred.Or_error.try_with_join (fun () ->
    let%bind _, body = Cohttp_async.Client.get uri in
    let%map string = Cohttp_async.Body.to_string body in
    try
      Ok
        (Yojson.Safe.from_string string
         |> Collection.t_of_yojson Manga.t_of_yojson)
    with
    | exn ->
      let uri = Uri.to_string uri in
      Error
        (Error.tag_s
           (Error.of_exn exn)
           ~tag:
             [%message
               "Error while parsing response from uri" (uri : string)]))
;;
