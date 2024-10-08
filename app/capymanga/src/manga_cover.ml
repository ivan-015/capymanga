open! Core
open Bonsai
open Capytui
open Bonsai.Let_syntax
open Mangadex_api.Types

type t = { url : string }

let cover_filename ~cover_id =
  let%sub state, set_state = Bonsai.state_opt () in
  let%sub () =
    match%sub state with
    | None -> Loading_state.i_am_loading
    | Some _ -> Bonsai.const ()
  in
  let%sub effect =
    let%sub cover = Outside_world.Manga_cover.component in
    let%arr cover = cover in
    fun cover_id -> cover ~cover_id
  in
  let%sub effect = Bonsai.Effect_throttling.poll effect in
  let%sub () =
    let%sub callback =
      let%arr set_state = set_state
      and effect = effect in
      fun cover_id ->
        let%bind.Effect () = set_state None in
        let%bind.Effect response = effect cover_id in
        match response with
        | Aborted -> Effect.Ignore
        | Finished response -> set_state (Some response)
    in
    Bonsai.Edge.on_change ~equal:[%equal: string] cover_id ~callback
  in
  return state
;;

let component
  : Mangadex_api.Types.Manga.t option Value.t -> t option Computation.t
  =
  fun manga ->
  (* TODO: Add some caching here (there are duplicate queries on the manga
     search and the manga view pages.)... *)
  match%sub manga with
  | None -> Bonsai.const None
  | Some manga ->
    let%sub cover_id =
      let%arr manga = manga in
      List.find_map manga.relationships ~f:(fun { type_; id } ->
        match type_ with "cover_art" -> Some id | _ -> None)
    in
    (match%sub cover_id with
     | None -> Bonsai.const None
     | Some cover_id ->
       let%sub manga_id =
         let%arr manga = manga in
         manga.id
       in
       let%sub bounced =
         Bonsai_extra.value_stability
           ~equal:[%equal: string * Manga_id.t]
           ~time_to_stable:(Value.return (Time_ns.Span.of_sec 0.3))
           (Value.both cover_id manga_id)
       in
       (match%sub bounced with
        | Unstable _ -> Bonsai.const None
        | Stable (cover_id, manga_id) ->
          let%sub filename =
            Bonsai.scope_model (module String) ~on:cover_id
            @@ cover_filename ~cover_id
          in
          (match%sub filename with
           | Some (Ok { data = { attributes = { filename; _ }; _ } }) ->
             let%arr filename = filename
             and manga_id = manga_id in
             let url =
               [%string
                 "https://mangadex.org/covers/%{manga_id#Manga_id}/%{filename}"]
             in
             Some { url }
           | _ -> Bonsai.const None)))
;;
