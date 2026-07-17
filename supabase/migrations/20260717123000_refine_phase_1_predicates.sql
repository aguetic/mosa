begin;

-- Replace the ambiguous research predicate `created_by` in the
-- existing Hoa Hakananaiʻa test case.
update knowledge.claim c
set predicate = 'published_by'
from entities.entity subject
where c.subject_id = subject.id
  and c.predicate = 'created_by'
  and subject.entity_type = 'source'
  and subject.working_label =
      'British Museum catalogue record: Oc1869,1005.1';

update knowledge.claim c
set predicate = 'authored_by'
from entities.entity subject
where c.subject_id = subject.id
  and c.predicate = 'created_by'
  and subject.entity_type = 'source'
  and subject.working_label =
      'Paula Rossetti note: Moai Hoa Haka Nanaia';

-- Treat the MPE 32571 photograph as a visual source that depicts
-- the item, rather than merely referring to it.
with photo as (
    select id
    from entities.entity
    where entity_type = 'source'
      and working_label = 'Photograph of MPE 32571'
    order by created_at
    limit 1
),
item as (
    select id
    from entities.entity
    where entity_type = 'item'
      and working_label = 'MPE 32571'
    order by created_at
    limit 1
)
update knowledge.claim c
set predicate = 'depicts'
from photo, item
where c.subject_id = photo.id
  and c.object_entity_id = item.id
  and c.predicate = 'refers_to';

with photo as (
    select id
    from entities.entity
    where entity_type = 'source'
      and working_label = 'Photograph of MPE 32571'
    order by created_at
    limit 1
),
item as (
    select id
    from entities.entity
    where entity_type = 'item'
      and working_label = 'MPE 32571'
    order by created_at
    limit 1
),
photo_claim as (
    select c.id
    from knowledge.claim c, photo, item
    where c.subject_id = photo.id
      and c.object_entity_id = item.id
      and c.predicate = 'depicts'
    order by c.created_at
    limit 1
)
update knowledge.claim_evidence ce
set source_id = photo.id,
    relationship = 'supports',
    locator = 'Whole image',
    excerpt = null
from photo, photo_claim
where ce.claim_id = photo_claim.id;

-- Treat the documentary as depicting its provisional item.
with documentary as (
    select id
    from entities.entity
    where entity_type = 'source'
      and working_label =
          'The Lost Gods of Easter Island documentary'
    order by created_at
    limit 1
),
item as (
    select id
    from entities.entity
    where entity_type = 'item'
      and working_label =
          'Curved wooden moai shown in The Lost Gods of Easter Island'
    order by created_at
    limit 1
)
update knowledge.claim c
set predicate = 'depicts'
from documentary, item
where c.subject_id = documentary.id
  and c.object_entity_id = item.id
  and c.predicate = 'refers_to';

-- Attribute the two current project interpretations to Paula
-- Rossetti rather than leaving the asserting agent ambiguous.
-- Change these assignments if another contributor made either
-- interpretation.
with paula as (
    select id
    from entities.entity
    where entity_type = 'agent'
      and working_label = 'Paula Rossetti'
    order by created_at
    limit 1
),
item_a as (
    select id
    from entities.entity
    where entity_type = 'item'
      and working_label = 'МАЭ № 736-205'
    order by created_at
    limit 1
),
item_b as (
    select id
    from entities.entity
    where entity_type = 'item'
      and working_label =
          'Curved wooden moai shown in The Lost Gods of Easter Island'
    order by created_at
    limit 1
)
update knowledge.claim c
set asserted_by_agent_id = paula.id,
    notes =
        'Working identity hypothesis recorded by Paula Rossetti. The entities remain separate until the identity is resolved.'
from paula, item_a, item_b
where c.subject_id = item_a.id
  and c.object_entity_id = item_b.id
  and c.predicate = 'possibly_same_as';

with paula as (
    select id
    from entities.entity
    where entity_type = 'agent'
      and working_label = 'Paula Rossetti'
    order by created_at
    limit 1
),
remains as (
    select id
    from entities.entity
    where entity_type = 'item'
      and working_label =
          'Unidentified cranial remains — Museo Colegio San Pedro Nolasco'
    order by created_at
    limit 1
),
person as (
    select id
    from entities.entity
    where entity_type = 'agent'
      and working_label =
          'Unidentified ancestral person associated with the cranial remains'
    order by created_at
    limit 1
)
update knowledge.claim c
set asserted_by_agent_id = paula.id,
    notes =
        'Structural interpretation recorded by Paula Rossetti. This does not identify the person.'
from paula, remains, person
where c.subject_id = remains.id
  and c.object_entity_id = person.id
  and c.predicate = 'physical_remains_of';

-- Preserve the source-language wording for the cranial-remains
-- classification.
with remains as (
    select id
    from entities.entity
    where entity_type = 'item'
      and working_label =
          'Unidentified cranial remains — Museo Colegio San Pedro Nolasco'
    order by created_at
    limit 1
)
update knowledge.claim c
set literal_value = jsonb_build_object(
        'type', 'text',
        'value', 'cráneo humano',
        'language', 'es'
    )
from remains
where c.subject_id = remains.id
  and c.predicate = 'classified_as'
  and c.literal_value ->> 'value' = 'human cranium';

commit;
