create extension if not exists unaccent with schema extensions;

create or replace function entities.search_normalise(
    p_value text
)
returns text
language sql
immutable
security invoker
set search_path = ''
as $$
    select translate(
        lower(extensions.unaccent('extensions.unaccent'::regdictionary, coalesce(p_value, ''))),
        'ʻ''’`´',
        ''
    );
$$;
