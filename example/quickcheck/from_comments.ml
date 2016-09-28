open Core.Std
open Quickcheck.Observer

type 'a bst = Leaf | Node of 'a bst * 'a * 'a bst

let bst_obs key_obs =
  recursive (fun bst_of_key_obs ->
    unmap (Either.obs Unit.obs (tuple3 bst_of_key_obs key_obs bst_of_key_obs))
      ~f:(function
        | Leaf           -> First ()
        | Node (l, k, r) -> Second (l, k, r))
      ~f_sexp:(fun () -> Sexp.Atom "either_of_bst"))
