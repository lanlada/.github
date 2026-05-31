# Module Layout

The repository is divided into module directories under `src/modules/**`, a shared layer under `src/common/**`, a database layer under `src/db/**`, and a configuration layer under `src/config/**`. This rule governs where new code belongs. The default disposition for newly observed duplication is WET (write everything twice). Code is promoted to a shared location only when the criteria documented below are satisfied.

## Decision Rule

Before sharing a piece of code, classify the duplication.

- If two or more places contain the same logic because they implement the same business rule, the code is a candidate for sharing.
- If two or more places contain logic that looks similar but each instance belongs to a different domain or a different lifecycle, the duplication is accidental. Leave the code WET in each module.

Premature abstraction produces shared utilities whose change-set is unpredictable across modules. Wait until ownership is stable.

## Placement Matrix

| Kind of code                                                | Location                                               | When to use                                                     |
| ----------------------------------------------------------- | ------------------------------------------------------ | --------------------------------------------------------------- |
| Interface used inside a single module                       | `src/modules/<module>/<module>.interface.ts`           | Contract internal to the owning module.                         |
| Interface used across multiple modules                      | `src/common/interfaces/`                               | Generic, domain-neutral type required by more than two modules. |
| Request or response data transfer object                    | `src/modules/<module>/dto/`                            | API contract owned by the module that exposes it.               |
| Module-scoped helper (parsing, mapping, formatting, policy) | `src/modules/<module>/<topic>.utility.ts`              | Helper coupled to the module's domain.                          |
| Cross-module helper                                         | `src/common/utilities/<topic>.utility.ts`              | Domain-neutral primitive used by more than two modules.         |
| Helper coupled to a business rule                           | The owning module's service or domain file             | Business-rule logic does not belong in `common`.                |
| Guard or decorator applied across the system                | `src/common/guards/`, `src/common/decorators/`         | Genuinely cross-cutting concern.                                |
| Guard or decorator scoped to one module                     | `src/modules/<module>/guards/`, `<module>/decorators/` | The behaviour is meaningful only inside that module's domain.   |
| Repository                                                  | `src/db/repositories/`                                 | Database boundary.                                              |
| Schema type or database model                               | `src/db/schema/`                                       | Database contract only.                                         |

## Four Gates Before Promotion to `src/common/`

A file moves to `src/common/` only when every gate below is satisfied. If any gate fails, the file remains in its owning module.

1. The code carries no business-domain coupling.
2. The code has no dependency on any specific module under `src/modules/`.
3. The code is consumed by more than two modules in current production code.
4. A change to the code does not alter behaviour in any consuming domain in a way the change author did not intend.

The third gate measures actual current consumers, not anticipated future consumers. Anticipation is not eligibility.

## Filename and Symbol Naming

The locked ESLint configuration rejects the abbreviation `util` in filenames (`unicorn/prevent-abbreviations`). The repository convention is therefore `<topic>.utility.ts`, not `<topic>.util.ts`.

- Module-scoped helper: `src/modules/<module>/<topic>.utility.ts`
  - Example: `src/modules/auth/auth-token.utility.ts`
  - Example: `src/modules/appointments/appointments-state.utility.ts`
  - Example: `src/modules/platform-users/platform-user-normalisation.utility.ts`
- Cross-module helper: `src/common/utilities/<topic>.utility.ts`
  - Example: `src/common/utilities/pagination.utility.ts`
  - Example: `src/common/utilities/request-id.utility.ts`

Topic-named files (`string.utility.ts`, `date.utility.ts`) carry a junk-drawer risk. They are permitted but require active discipline: every export inside such a file must satisfy all four gates above on its own, and the file must not grow into a collection of unrelated helpers.

Exported function names use a verb-first form that names what the function does, not what kind of file it lives in: `parseJwtClaims`, `extractBearerToken`, `normaliseEmail`, `createRequestId`.

## Test File Layout

Test files follow the `*.test.ts` convention enforced by `nextfriday/enforce-test-filename`. The `nextfriday/no-helper-function-in-test` rule additionally prohibits helper functions declared at the top level of a test file.

- A helper used by a single `describe` block is declared inside that `describe` block. The rule applies only to the file's program scope.
- A helper used by more than one test file moves to a sibling fixture file with a semantic name (for example `src/modules/<module>/<topic>.fixture.ts`), imported by every consumer.

The test file owns the cases for the symbol under test. When ownership of a symbol moves between files (for example, a function is extracted from `*.service.ts` into `<topic>.utility.ts`), the corresponding test cases move with it. Duplicate cases across the previous and new test owner are removed.

## Factory Callback Exception

Functions passed as callbacks to NestJS factory APIs are exempt from the extraction rules above. The callback is bound to its declared constant at module construction and has no meaningful identity outside that binding.

- `createParamDecorator(fn)` and the function `fn` live together in the same `*.decorator.ts` file.
- `Reflector` metadata factories and similar bind-on-construction patterns follow the same exception.

Extracting the callback to a separate file removes the binding context and produces a worse, not better, reading order.

## Worked Examples From the Auth Module

The examples below are drawn from the Auth module as documented at the time this rule landed.

### `parseJwtClaims`

The function validates that a verified Supabase JWT payload contains a `sub` and an `email` claim and that both are strings. The validation is auth-domain logic; it raises `UNAUTHORIZED` on failure per the API policy.

- Location: `src/modules/auth/auth-token.utility.ts`.
- Rationale: the function is module-scoped (Auth) and coupled to the Supabase JWT contract.
- Not eligible for `src/common/utilities/`: gate 1 fails (business-domain coupled) and gate 3 fails (single consumer).

### `extractBearerToken`

The function parses the HTTP `Authorization` header to extract a Bearer token and raises `UNAUTHORIZED` on a missing or malformed header.

- Location: `src/modules/auth/auth-token.utility.ts`, alongside `parseJwtClaims`.
- Rationale: both functions are auth-token plumbing primitives that share the Auth domain. Cohesion places them in one file.
- Not eligible for `src/common/utilities/`: gate 3 fails (single consumer) and the behaviour is part of the AuthGuard contract.

### `RequestWithAuth`

The interface extends the Express `Request` with an optional `auth` field carrying the resolved `AuthContext`.

- Location: `src/modules/auth/auth.interface.ts`.
- Rationale: the interface is the Auth module's context contract. Multiple guards and decorators import it, but the source of truth belongs to the Auth module.
- Not eligible for `src/common/interfaces/`: gate 1 fails (`AuthContext` is auth-domain).

### `ApiError`

The error envelope is the cross-cutting API behaviour applied by every controller, service, and guard.

- Location: `src/common/errors/`.
- Rationale: all four gates are satisfied. The envelope is domain-neutral, has no module-specific dependency, is consumed by every module, and its behaviour is the same in every consumer.

## WET That Stays WET

The following situations resemble shared logic but are accidental duplications. They remain WET until evidence of a shared business rule appears.

- A `DISABLED` user membership, a `SUSPENDED` tenant, a `CANCELLED` appointment, and a `PAST_DUE` billing subscription all read as a "status" check. The lifecycles, transitions, and authorisation implications are different. Do not create `src/common/utilities/status.utility.ts`.
- An email normalisation step used during platform user invite (lowercase, trim, unique enforcement) is not the same operation as an email normalisation step in customer record import (which may permit aliases). Each module owns its own normalisation until a written specification establishes one rule for both.

## Mandate

- New helper code that does not satisfy the four gates above is added to the owning module.
- New cross-module utilities require an issue that documents the gate evaluation in the Background section.
- Test cases follow ownership. When a symbol moves between files, its tests move with it; duplicate cases are removed.
- The factory-callback exception is explicit. Other exceptions require an entry in this rule before the code lands.

## Exceptions

- Code generators and migration tooling that produce single-purpose throw-away files (for example `*.migration.sql`) are not subject to this rule.
- Files vendored from upstream sources under `.agents/skills/` follow their upstream conventions and are not modified to match this rule.
