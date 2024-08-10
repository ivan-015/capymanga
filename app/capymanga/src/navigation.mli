open! Core
open Bonsai

type 'a t =
  { page : 'a
  ; set_page : 'a -> unit Effect.t
  ; go_back : unit Effect.t
  }

val component : 'a -> 'a t Computation.t
