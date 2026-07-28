begin;

create extension if not exists pgtap with schema extensions;
set local search_path = public, extensions;

select plan(12);

select has_role('explorer_reader', 'explorer_reader role exists');

select isnt_superuser(
    'explorer_reader',
    'explorer_reader is not a superuser'
);

-- Seed under a privileged role, then assert RLS still returns the row to explorer_reader.
insert into entities.entity (id, entity_type)
values ('cccccccc-cccc-4ccc-8ccc-cccccccccccc', 'item');

set local role explorer_reader;

select lives_ok(
    $$
    select count(*) from entities.entity;
    select count(*) from entities.entity_display;
    select count(*) from knowledge.claim;
    select count(*) from knowledge.claim_details;
    select count(*) from knowledge.claim_evidence_details;
    select count(*) from provenance.event;
    select count(*) from restitution.case_record;
    select entities.search_normalise('Hoa Hakananai''a');
    $$,
    'explorer_reader can select explorer query surfaces'
);

select is(
    (
        select count(*)::integer
        from entities.entity
        where id = 'cccccccc-cccc-4ccc-8ccc-cccccccccccc'
    ),
    1,
    'explorer_reader RLS policies expose entity rows'
);

select throws_ok(
    $$
    insert into entities.entity (id, entity_type)
    values ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'item');
    $$,
    '42501',
    NULL,
    'explorer_reader cannot insert into entities.entity'
);

select throws_ok(
    $$
    update entities.entity
    set entity_type = 'agent'
    where id = (
        select id from entities.entity limit 1
    );
    $$,
    '42501',
    NULL,
    'explorer_reader cannot update entities.entity'
);

select throws_ok(
    $$
    delete from knowledge.claim
    where id = (
        select id from knowledge.claim limit 1
    );
    $$,
    '42501',
    NULL,
    'explorer_reader cannot delete from knowledge.claim'
);

select throws_ok(
    $$
    create table entities.explorer_reader_probe (id integer);
    $$,
    '42501',
    NULL,
    'explorer_reader cannot create tables in entities'
);

select throws_ok(
    $$
    create role explorer_reader_should_fail;
    $$,
    '42501',
    NULL,
    'explorer_reader cannot create roles'
);

select throws_ok(
    $$
    insert into restitution.case_record (reference, title, status)
    values ('probe', 'probe', 'open');
    $$,
    '42501',
    NULL,
    'explorer_reader cannot insert into restitution.case_record'
);

select throws_ok(
    $$
    insert into provenance.event (id, event_kind)
    values ('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', 'transfer');
    $$,
    '42501',
    NULL,
    'explorer_reader cannot insert into provenance.event'
);

select throws_ok(
    $$
    drop table entities.entity;
    $$,
    '42501',
    NULL,
    'explorer_reader cannot drop tables'
);

reset role;

select * from finish();

rollback;
