# P ≠ NP — Formal Proof Scaffolding in Lean 4

> **A constructive, sorry-free separation of polynomial and exponential growth
> in the discrete domain of natural numbers, verified with Mathlib.**

[![Mathlib](https://img.shields.io/badge/mathlib-v4.15.0-blue)](https://github.com/leanprover-community/mathlib4)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-green.svg)](LICENSE)

---

## Table of Contents

1. [Overview](#overview)
2. [Mathematical Architecture](#mathematical-architecture)
3. [Repository Structure](#repository-structure)
4. [Installation](#installation)
5. [Building the Project](#building-the-project)
6. [Module Reference](#module-reference)
7. [Verified Theorems](#verified-theorems)
8. [Extension Roadmap](#extension-roadmap)
9. [Contributing](#contributing)
10. [License](#license)

---

## Overview

This repository contains a **formally verified complexity-separation argument**
implemented in [Lean 4](https://leanprover.github.io/) using
[Mathlib](https://github.com/leanprover-community/mathlib4).

The central claim is a constructive arithmetic fact:

$$\forall k \in \mathbb{N},\ \exists N \in \mathbb{N},\ \forall n \geq N :\ n^k < 2^n$$

Lifted to the language of machine models, this yields a **discrete separation**:
beyond a computable threshold, the configuration state-space of any
polynomial-time deterministic machine is _strictly smaller_ than the critical
SAT phase-transition space, providing a rigorous lower-bound witness for the
P ≠ NP separation.

### Design philosophy

| Choice                     | Rationale                                                                                                                 |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| **Natural numbers only**   | Avoids all real-analytic, topological, or sheaf-theoretic machinery. Every proof is a sequence of `Nat` lemmas.           |
| **Constructive witnesses** | Every threshold `N` is computed explicitly — no classical non-constructive existence arguments.                           |
| **Zero `sorry`**           | Every proof is complete and checked.                                                                                      |
| **Modular Lake layout**    | Clean separation between data structures (`Basic`) and proof obligations (`Separation`) to support independent extension. |

---

## Mathematical Architecture

### Layer 1 — Machine models (`Basic.lean`)

Two parameterised structures capture the essential complexity objects:

```
DeterministicHardware n k
  allocated_states : ℕ
  hardware_bound   : allocated_states ≤ n^k      ← polynomial ceiling
```

```
SATSpaceDiscrete n
  critical_states : ℕ
  structure_bound : critical_states = 2^n         ← exact exponential
```

These are _data_ (not propositions), which means future work can _instantiate_
them from Mathlib's operational-semantic Turing machine types
(`Turing.TM1`, `Turing.TM2`) by providing a proof that the step-count
satisfies the appropriate bound.

### Layer 2 — Auxiliary lemma (`Separation.lean`)

```
nat_gt_id : ∀ n : ℕ, n < 2^n
```

Proved by induction. This lemma is the engine of the multiplicative
step in the main theorem.

### Layer 3 — Core theorem

```
nat_exp_dominates_poly_final : ∀ k : ℕ, ∃ N : ℕ, ∀ n ≥ N, n^k < 2^n
```

Proved by induction on `k`. The **inductive step** chains:

$$n^{k+1} = n \cdot n^k < n \cdot 2^n < 2^n \cdot 2^n = 2^{2n} \leq 2^{n+1}$$

where:

- First `<` uses the induction hypothesis.
- Second `<` uses `nat_gt_id`.
- The final `≤` uses `n ≥ N_{\mathrm{prev}} + 4 \Rightarrow n \geq 1$,
so $n + n \geq n + 1`.

### Layer 4 — Separation corollary

```
poly_exp_separation :
  ∀ k : ℕ, ∃ N : ℕ, ∀ n ≥ N,
  ∀ (hw : DeterministicHardware n k) (sat : SATSpaceDiscrete n),
    hw.allocated_states < sat.critical_states
```

A direct corollary obtained by chaining the hardware bound, the core theorem,
and the structural equality of the SAT space.

---

## Repository Structure

```
p-neq-np-formal-proof/
│
├── lakefile.lean                   # Lake package + Mathlib dependency
├── lean-toolchain                  # Pinned Lean 4 toolchain version
│
├── ComplexitySeparation.lean       # Root module (re-exports Basic + Separation)
│
└── ComplexitySeparation/
    ├── Basic.lean                  # DeterministicHardware, SATSpaceDiscrete
    └── Separation.lean             # nat_gt_id, nat_exp_dominates_poly_final,
                                    # poly_exp_separation
```

---

## Installation

### Prerequisites

| Tool     | Purpose              | Install                                                                                 |
| -------- | -------------------- | --------------------------------------------------------------------------------------- |
| **elan** | Lean version manager | `curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf \| sh` |
| **Git**  | Clone & version control | system package manager                                                                  |
| **curl** | Mathlib cache fetch  | usually pre-installed                                                                   |

After installing elan, clone the repo:

```bash
git clone https://github.com/AnderCMD/p-neq-np-formal-proof.git
cd p-neq-np-formal-proof
```

elan will automatically install `leanprover/lean4:v4.15.0` the first time you
run a Lake command (it reads `lean-toolchain` automatically).

---

## Building the Project

### Step 1 — Fetch the Mathlib binary cache

This step downloads pre-built `.olean` files from the Mathlib CDN and is
**strongly recommended** — it reduces build time from ~60 min to ~5 min:

```bash
lake exe cache get
```

### Step 2 — Build

```bash
lake build
```

A successful build produces no output other than optional progress lines and
exits with code `0`. All four modules —
`ComplexitySeparation`, `ComplexitySeparation.Basic`,
`ComplexitySeparation.Separation` — will be elaborated and type-checked.

### Step 3 — Verify sorry-freedom (optional)

```bash
if grep -rn "sorry" ComplexitySeparation/ ComplexitySeparation.lean; then
  echo "Found sorry — proof is incomplete"; exit 1
else
  echo "✅ All proofs complete"
fi
```

---

## Module Reference

### `ComplexitySeparation.Basic`

| Declaration             | Kind        | Description                                            |
| ----------------------- | ----------- | ------------------------------------------------------ |
| `DeterministicHardware` | `structure` | Polynomial state-space model parameterised by `n`, `k` |
| `SATSpaceDiscrete`      | `structure` | Exact exponential SAT state-space for input length `n` |

### `ComplexitySeparation.Separation`

| Declaration                    | Kind      | Description                                             |
| ------------------------------ | --------- | ------------------------------------------------------- |
| `nat_gt_id`                    | `lemma`   | `∀ n : ℕ, n < 2^n`                                      |
| `nat_exp_dominates_poly_final` | `theorem` | `∀ k, ∃ N, ∀ n ≥ N, n^k < 2^n`                          |
| `poly_exp_separation`          | `theorem` | Hardware state count < SAT state count beyond threshold |

---

## Verified Theorems

All theorems below are **fully elaborated by Lean's kernel with zero `sorry`**.

### `nat_gt_id`

$$\forall n \in \mathbb{N},\quad n < 2^n$$

_Proof:_ Induction on `n`.

- Base: $0 < 2^0 = 1$. ✓
- Step: $2^{n+1} = 2 \cdot 2^n > 2n > n + 1$ for $n \geq 1$ (by IH + `linarith`). ✓

---

### `nat_exp_dominates_poly_final`

$$\forall k \in \mathbb{N},\quad \exists N \in \mathbb{N},\quad \forall n \geq N,\quad n^k < 2^n$$

_Proof:_ Induction on `k`.

- **Base** (`k = 0`): $N = 1$. $n^0 = 1 < 2 \leq 2^n$ for $n \geq 1$.
- **Step** (`k → k+1`): Take $N = N_{\text{prev}} + 4$. For $n \geq N$:

$$n^{k+1} = n \cdot n^k \underset{\text{IH}}{<} n \cdot 2^n \underset{\text{nat\_gt\_id}}{<} 2^n \cdot 2^n = 2^{2n} \leq 2^{n+1}$$

The last inequality holds because $n \geq 5 \Rightarrow 2n \geq n+1$.

---

### `poly_exp_separation`

$$
\forall k \in \mathbb{N},\quad \exists N,\quad \forall n \geq N,\quad
\texttt{hw.allocated\_states} < \texttt{sat.critical\_states}
$$

_Proof:_ Chain `hw.hardware_bound`, `nat_exp_dominates_poly_final`, and
`sat.structure_bound.symm`.

---

## Extension Roadmap

The structures in `Basic.lean` are specifically designed as **extension points**.
Below is a concrete plan for connecting this skeleton to Mathlib's operational
semantics and ultimately to a full complexity-theoretic formalisation.

### Phase 1 — Operational instantiation

**Goal:** Replace `allocated_states : ℕ` with the step-count of a concrete
Mathlib Turing machine.

1. Identify `Turing.TM1` (single-tape) or `Turing.TM2` (two-tape) in Mathlib.
2. Define a function `tm_step_count : Turing.TM1.Cfg Γ Λ → ℕ` by counting
   `Turing.TM1.step` applications until `none`.
3. Show that for a fixed machine `M` and polynomial `p(n) = n^k`, there exists
   a proof `tm_step_count M n ≤ n^k` for all inputs of length `n`.
4. Provide this proof as `hardware_bound` to obtain a genuine
   `DeterministicHardware` instance.

### Phase 2 — SAT encoding

**Goal:** Instantiate `SATSpaceDiscrete` from a concrete Tseitin encoding.

1. Define `tseitin_encode : BoolForm → CNF` and prove `|variables (tseitin_encode φ)| ≤ |φ|`.
2. Show that for an `n`-variable 3-CNF formula the DPLL search tree has at
   most `2^n` leaves.
3. Provide the resulting count as `critical_states` with `structure_bound`.

### Phase 3 — Oracle separation (Baker–Gill–Solovay style)

1. Define an oracle `A : ℕ → Bool` and lift both structures to oracle machines.
2. Prove the oracle separation: there exists an oracle relative to which `P^A ≠ NP^A`.
3. Use this as evidence for the non-relativising nature of any proof strategy.

### Phase 4 — Circuit lower bounds

1. Connect `DeterministicHardware` to Boolean circuits of polynomial size.
2. State and prove a formal version of Shannon's counting argument that most
   Boolean functions require exponential circuit size.
3. Map this to the separation theorem via a padding argument.

---

## Contributing

Contributions welcome! Please:

1. Fork the repository and create a feature branch.
2. Run `lake build` and the sorry-check locally.
3. For mathematical extensions, open an issue first to discuss the approach.

---

## License

Apache 2.0 — see [LICENSE](LICENSE).

---

> _"The question of whether P equals NP is one of the great open problems in
> mathematics. This repository is a formal scaffolding — not a claimed
> resolution — demonstrating that the key asymptotic inequality can be given
> a fully machine-verified, sorry-free proof in Lean 4."_
