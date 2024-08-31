open! Core
open Bonsai

type t =
  { dispose : bool option
  ; nosig : bool option
  ; mouse : bool option
  ; bpaste : bool option
  ; optimize : bool
  ; target_frames_per_second : int
  ; use_wezterm: bool 
  ; app : (Node.t * Image.t list) Computation.t
  }

let sanity_check_exn
  { dispose = _
  ; nosig = _
  ; mouse = _
  ; bpaste = _
  ; optimize = _
  ; target_frames_per_second
  ; use_wezterm = _
  ; app = _
  }
  =
  if target_frames_per_second < 1
  then
    raise_s
      [%message
        "Assertion failure: [target_frames_per_second < 1]"
          (target_frames_per_second : int)
          "please pick a value >= 1"]
;;

let create_exn
  ~dispose
  ~nosig
  ~mouse
  ~bpaste
  ~optimize
  ~target_frames_per_second
  ~use_wezterm
  ~app
  =
  let out =
    { dispose
    ; nosig
    ; mouse
    ; bpaste
    ; optimize
    ; target_frames_per_second
    ; use_wezterm
    ; app
    }
  in
  sanity_check_exn out;
  out
;;
