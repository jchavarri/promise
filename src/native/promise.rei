/* This file is part of reason-promise, released under the MIT license. See
   LICENSE.md for details, or visit
   https://github.com/aantron/repromise/blob/master/LICENSE.md. */



type rejectable('a, 'e);
type never;

type promise('a) = rejectable('a, never);
type t('a) = promise('a);



/* Making promises. */
let pending:
  unit =>
    (promise('a), 'a => unit);

let resolved:
  'a =>
    promise('a);

let exec:
  (('a => unit) => unit) =>
    promise('a);



/* Using promises. */
let on:
  (promise('a), 'a => unit) =>
    unit;

let tap:
  (promise('a), 'a => unit) =>
    promise('a);

let map:
  (promise('a), 'a => 'b) =>
    promise('b);

let flatMap:
  (promise('a), 'a => promise('b)) =>
    promise('b);



/* Compatibility with OCaml 4.02. */
type result('a, 'e) = Result.result('a, 'e);

/* Results. */
let onOk:
  (promise(result('a, 'e)), 'a => unit) =>
    unit;

let tapOk:
  (promise(result('a, 'e)), 'a => unit) =>
    promise(result('a, 'e));

let mapOk:
  (promise(result('a, 'e)), 'a => 'b) =>
    promise(result('b, 'e));

let flatMapOk:
  (promise(result('a, 'e)), 'a => promise(result('b, 'e))) =>
    promise(result('b, 'e));

let onError:
  (promise(result('a, 'e)), 'e => unit) =>
    unit;

let tapError:
  (promise(result('a, 'e)), 'e => unit) =>
    promise(result('a, 'e));

let mapError:
  (promise(result('a, 'e)), 'e => 'e2) =>
    promise(result('a, 'e2));

let flatMapError:
  (promise(result('a, 'e)), 'e => promise(result('a, 'e2))) =>
    promise(result('a, 'e2));

module Operators: {
  let (>|=):
    (promise(result('a, 'e)), 'a => 'b) =>
      promise(result('b, 'e));

  let (>>=):
    (promise(result('a, 'e)), 'a => promise(result('b, 'e))) =>
      promise(result('b, 'e));
};



/* Options. */
let onSome:
  (promise(option('a)), 'a => unit) =>
    unit;

let tapSome:
  (promise(option('a)), 'a => unit) =>
    promise(option('a));

let mapSome:
  (promise(option('a)), 'a => 'b) =>
    promise(option('b));

let flatMapSome:
  (promise(option('a)), 'a => promise(option('b))) =>
    promise(option('b));



/* Combining promises. */
let race:
  list(promise('a)) =>
    promise('a);

let all:
  list(promise('a)) =>
    promise(list('a));

let arrayAll:
  array(promise('a)) =>
    promise(array('a));

let all2:
  (promise('a), promise('b)) =>
    promise(('a, 'b));

let all3:
  (promise('a), promise('b), promise('c)) =>
    promise(('a, 'b, 'c));

let all4:
  (promise('a), promise('b), promise('c), promise('d)) =>
    promise(('a, 'b, 'c, 'd));

let all5:
  (promise('a), promise('b), promise('c), promise('d), promise('e)) =>
    promise(('a, 'b, 'c, 'd, 'e));

let all6:
  (promise('a),
   promise('b),
   promise('c),
   promise('d),
   promise('e),
   promise('f)) =>
    promise(('a, 'b, 'c, 'd, 'e, 'f));



/* Shouldn't be used; provided for compatibility with Js. */
module Js: {
  type t('a, 'e) = rejectable('a, 'e);

  /* Making. */
  let pending:
    unit =>
      (rejectable('a, 'e), 'a => unit, 'e => unit);

  let resolved:
    'a =>
      rejectable('a, 'e);

  let rejected:
    'e =>
      rejectable('a, 'e);

  /* Handling fulfillment. */
  let on:
    (rejectable('a, 'e), 'a => unit) =>
      unit;

  let tap:
    (rejectable('a, 'e), 'a => unit) =>
      rejectable('a, 'e);

  let map:
    (rejectable('a, 'e), 'a => 'b) =>
      rejectable('b, 'e);

  let flatMap:
    (rejectable('a, 'e), 'a => rejectable('b, 'e)) =>
      rejectable('b, 'e);

  /* Handling rejection. */
  let catch:
    (rejectable('a, 'e), 'e => rejectable('a, 'e2)) =>
      rejectable('a, 'e2);

  /* Combining. */
  let all:
    list(rejectable('a, 'e)) =>
      rejectable(list('a), 'e);

  let race:
    list(rejectable('a, 'e)) =>
      rejectable('a, 'e);

  /* Conversions. */
  let relax:
    promise('a) =>
      rejectable('a, 'e);

  let toResult:
    rejectable('a, 'e) =>
      promise(result('a, 'e));

  let fromResult:
    promise(result('a, 'e)) =>
      rejectable('a, 'e);
};



module FastPipe: {
  let (|.): ('a, 'a => 'b) => 'b;
};



let onUnhandledException: ref(exn => unit);



/* This is not part of the public API. It is used by I/O libraries to drive
   native promise callbacks on each tick. */

module ReadyCallbacks: {
  let callbacksPending: unit => bool;

  /* When about to iterate over the ready callbacks, Repromise first takes a
     snapshot of them, and iterates over the snapshot. This is to prevent new
     ready callbacks, that may be created by the processing of the current ones,
     from being processed immediately. That could lead to I/O loop starvation
     and other problems. */
  type snapshot;

  let snapshot: unit => snapshot;
  let isEmpty: snapshot => bool;
  let call: snapshot => unit;
};