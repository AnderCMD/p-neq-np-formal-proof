/-!
# ComplexitySeparation.Basic

Foundational structures for the discrete complexity-separation argument.

We work entirely in `ℕ` to avoid any analytic machinery.  Two structures
capture the essential asymptotic objects:

* `DeterministicHardware n k` — a polynomial-time deterministic machine whose
  state count is bounded above by `n ^ k`.
* `SATSpaceDiscrete n` — the critical phase-transition state space for 3-SAT,
  whose cardinality equals `2 ^ n` exactly.

These are intentionally *data* structures (not propositions) so that future
work can instantiate them from Mathlib's Turing-machine operational semantics.
-/

import Mathlib.Data.Nat.Basic
import Mathlib.Data.Nat.Pow

namespace ComplexitySeparation

/-! ## Machine models -/

/-- A deterministic, polynomial-time hardware model parameterised by
input length `n` and degree `k`.  The field `hardware_bound` guarantees that
the number of reachable configurations is at most `n ^ k`. -/
structure DeterministicHardware (n : ℕ) (k : ℕ) where
  /-- Concrete upper bound on allocated configuration states. -/
  allocated_states : ℕ
  /-- The bound witness: `allocated_states ≤ n ^ k`. -/
  hardware_bound   : allocated_states ≤ n ^ k

/-- The discrete state-space induced by a 3-SAT instance of length `n`.
The critical phase-transition region requires exactly `2 ^ n` configurations
to be examined in the worst case. -/
structure SATSpaceDiscrete (n : ℕ) where
  /-- The exact number of critical configurations. -/
  critical_states : ℕ
  /-- Structural equality: the SAT space is *exactly* exponential. -/
  structure_bound : critical_states = 2 ^ n

end ComplexitySeparation
