open! Core
open Capytui
open Bonsai

val component
  :  dimensions:Dimensions.t Value.t
  -> set_page:(Page.t -> unit Effect.t) Value.t
  -> Component.t Computation.t
