open! Core
open Capytui
open Bonsai.Let_syntax
module Catpuccin = Capytui_catpuccin

let sexp_for_debugging =
  let%sub flavor = Catpuccin.flavor in
  let%arr flavor = flavor in
  fun ?(attrs = []) sexp ->
    Node.sexp_for_debugging
      ~attrs:
        ([ Attr.background_color (Catpuccin.color ~flavor Crust)
         ; Attr.foreground_color (Catpuccin.color ~flavor Text)
         ]
         @ attrs)
      sexp
;;

let normalize_string_lossy string =
  String.map string ~f:(function
    | c when Char.is_whitespace c -> ' '
    | c -> c)
;;
