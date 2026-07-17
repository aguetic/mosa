# Case 04: Ancestral person and cranial remains

## Purpose

Test the distinction between an ancestral person and physical remains held in a collection.

## Entities

- **Agent:** Unidentified ancestral person, `agent_kind = person`
- **Item:** Cranial remains, `item_kind = ancestral_remains`
- **Agent:** Museo Colegio San Pedro Nolasco, `agent_kind = organisation`
- **Place:** Santiago, Chile
- **Sources:** Paula's note; linked Mercedarios page; photograph, if used as evidence

## Expected claims

- The item `physical_remains_of` the ancestral person.
- Each source `refers_to` the relevant item or agent.
- The item is `associated_with_agent` the museum.
- The item is `associated_with_place` Santiago.
- Paula's note `described_as` return discussions or promises having occurred.

## Questions

- Can the ancestral person exist without being classified as an item?
- Can physical remains and the person be linked without collapsing them?
- Can an item exist without an inventory number?
- Can sparse and partly informal evidence be represented accurately?

## Pass condition

The ancestral person and physical remains have separate identities, connected by a sourced claim.
