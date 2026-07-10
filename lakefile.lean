import Lake
open Lake DSL

package ComplexitySeparation where
  -- Keep generated .olean files in the standard .lake/ build cache
  buildDir := ".lake/build"

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "v4.15.0"

/-- Root library target: includes all files under ComplexitySeparation/ -/
lean_lib ComplexitySeparation where
  roots := #[`ComplexitySeparation]
