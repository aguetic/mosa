-- Synthetic local development fixture only.

insert into entities.entity (
    id,
    entity_type
)
values
    (
        '00000000-0000-4000-8000-000000000001',
        'agent'
    ),
    (
        '00000000-0000-4000-8000-000000000002',
        'item'
    ),
    (
        '00000000-0000-4000-8000-000000000003',
        'place'
    ),
    (
        '00000000-0000-4000-8000-000000000004',
        'source'
    );

insert into entities.agent (
    id,
    agent_kind
)
values (
    '00000000-0000-4000-8000-000000000001',
    'organisation'
);

insert into entities.item (
    id,
    item_kind
)
values (
    '00000000-0000-4000-8000-000000000002',
    'artefact'
);

insert into entities.place (
    id,
    place_kind
)
values (
    '00000000-0000-4000-8000-000000000003',
    'site'
);

insert into entities.source (
    id,
    source_kind,
    reference
)
values (
    '00000000-0000-4000-8000-000000000004',
    'institutional_record',
    'https://example.invalid/catalogue/123'
);

insert into entities.external_identifier (
    entity_id,
    namespace,
    value,
    source_id
)
values (
    '00000000-0000-4000-8000-000000000002',
    'example-museum',
    '123',
    '00000000-0000-4000-8000-000000000004'
);

insert into knowledge.claim (
    id,
    subject_id,
    predicate,
    object_entity_id,
    asserted_by_agent_id,
    notes
)
values (
    '10000000-0000-4000-8000-000000000001',
    '00000000-0000-4000-8000-000000000004',
    'refers_to',
    '00000000-0000-4000-8000-000000000002',
    '00000000-0000-4000-8000-000000000001',
    'The catalogue record is assessed as referring to this item.'
);

insert into knowledge.claim (
    id,
    subject_id,
    predicate,
    literal_value,
    asserted_by_agent_id
)
values
    (
        '10000000-0000-4000-8000-000000000002',
        '00000000-0000-4000-8000-000000000002',
        'has_name',
        jsonb_build_object(
            'type', 'text',
            'value', 'Example institutional name',
            'language', 'en'
        ),
        '00000000-0000-4000-8000-000000000001'
    ),
    (
        '10000000-0000-4000-8000-000000000003',
        '00000000-0000-4000-8000-000000000001',
        'has_name',
        jsonb_build_object(
            'type', 'text',
            'value', 'Example Museum'
        ),
        '00000000-0000-4000-8000-000000000001'
    ),
    (
        '10000000-0000-4000-8000-000000000004',
        '00000000-0000-4000-8000-000000000003',
        'has_name',
        jsonb_build_object(
            'type', 'text',
            'value', 'Example location'
        ),
        '00000000-0000-4000-8000-000000000001'
    );

insert into knowledge.claim_evidence (
    claim_id,
    source_id,
    relationship,
    locator,
    excerpt
)
values
    (
        '10000000-0000-4000-8000-000000000001',
        '00000000-0000-4000-8000-000000000004',
        'supports',
        'Whole catalogue record',
        null
    ),
    (
        '10000000-0000-4000-8000-000000000002',
        '00000000-0000-4000-8000-000000000004',
        'supports',
        'Object name field',
        'Example institutional name'
    ),
    (
        '10000000-0000-4000-8000-000000000003',
        '00000000-0000-4000-8000-000000000004',
        'supports',
        'Publisher field',
        'Example Museum'
    ),
    (
        '10000000-0000-4000-8000-000000000004',
        '00000000-0000-4000-8000-000000000004',
        'supports',
        'Location field',
        'Example location'
    );
