# Component Scaffolding

Before any component file is created under `src/features/**` or `src/components/**`, the layer placement is resolved on paper and confirmed. The recurring defect is scaffolding first and discovering the wrong layer afterward: a Template wired directly to a Block, or data hardcoded inside a dumb Block. The layer trace below is completed and presented before the first file is written.

## Layer Trace

Four questions, answered in order, before the first file is written:

1. **Consumer** — which layer imports this component? The consumer fixes the layer. A Template imports a Module; a Module imports a Block; a Block imports a Base atom. Anchor on the consumer, never on the leaf the component happens to render.
2. **Data ownership** — where does the data originate now, and where will it originate once an API exists? The Module owns data and fetching. The Block receives every value as props and hardcodes nothing.
3. **Base usage** — does the component render a Base atom (for example `Image`, `Button`)? If it does, it belongs in a Block. A Module never imports Base.
4. **Import direction** — the resulting import edges match `docs/architecture/overview.md` section 6. A Template imports only `structures/` and `modules/`.

## Don't

- Create a component file before the layer trace is written and confirmed
- Import a Block from a Template — the Template imports a Module that composes the Block
- Import a Base atom from a Module — push the Base usage down into a Block
- Hardcode `src`, `label`, or any content value inside a Block — the Module supplies it
- Offer a layer choice to the user when the architecture already determines it — resolve the fact first, ask only genuine taste questions

## Do

- Write the four-question layer trace and confirm it before the first file
- Place data in the Module (a `{name}.data.ts` placeholder now, an async view once an API exists)
- Keep the Block dumb: props only, styling through `cva`, no data ownership
- Verify every import edge against `docs/architecture/overview.md` section 6 before scaffolding
- Read `docs/architecture/layers/{layer}.md` for the target layer when the placement is not obvious

## Exceptions

- A single-file edit inside an existing component that does not change its layer or import edges does not require a new layer trace

## Comment exception for Base atoms

This is the stack-specific `no-code-comments` exception for this repository. One-line JSDoc per own prop on Base atoms under `src/components/base/**` is permitted — the base-atom authoring pattern documents each prop a component adds (with `@default` where one applies); native props inherited from the element are left undocumented. See `docs/architecture/layers/base.md`. No other source comments are permitted; the baseline `no-code-comments` rule governs the rest.
