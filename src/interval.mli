(** Module for simple closed intervals over arbitrary types that are ordered
    correctly using polymorphic compare. *)

open! Core_kernel.Std
open Interval_intf

module type S1 = S1

(* Sexps are () for empty interval and (3 5) for an interval containing 3, 4, and 5. *)
include S1

module type S = S
  with type 'a poly_t := 'a t
  with type 'a poly_set := 'a Set.t

module Make (Bound : sig
  type t [@@deriving bin_io, sexp]
  include Comparable.S with type t := t
end)
  : S with type bound = Bound.t

module Float : S with type bound = Float.t

module Int : sig
  include S with type bound = Int.t

  include Container.S0        with type t := t with type elt := bound
  include Binary_searchable.S with type t := t with type elt := bound
end

module Time : sig
  include S with type bound = Time.t


  (** [create_ending_after ?zone (od1, od2) ~now] returns the smallest interval [(t1 t2)]
      with minimum [t2] such that [t2 >= now], [to_ofday t1 = od1], and [to_ofday t2 =
      od2].  If zone is specified, it is used to translate od1 and od2 into times,
      otherwise the machine's time zone is used.  It is not guaranteed that [contains (t1
      t2) now], which will be false iff there is no interval containing [now] with
      [to_ofday t1 = od1] and [to_ofday t2 = od1] . *)
  val create_ending_after : ?zone:Zone.t -> Ofday.t * Ofday.t -> now:Time.t -> t

  (** [create_ending_before ?zone (od1, od2) ~ubound] returns the smallest interval [(t1
      t2)] with maximum [t2] such that [t2 <= ubound], [to_ofday t1 = od1], and [to_ofday
      t2 = od2]. If zone is specified, it is used to translate od1 and od2 into times,
      otherwise the machine's time zone is used. *)
  val create_ending_before : ?zone:Zone.t -> Ofday.t * Ofday.t -> ubound:Time.t -> t
end

(* The spec for [Ofday] must be below the spec for [Time], so as not to shadow the uses
   of [Ofday] in the spec for [Time]. *)
module Ofday : S with type bound = Ofday.t

module Stable : sig
  module V1 : sig
    module Float : Stable with type t = Float.t
    module Int   : Stable with type t = Int.  t
    module Time  : Stable with type t = Time. t
    module Ofday : Stable with type t = Ofday.t
  end
end
