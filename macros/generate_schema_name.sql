{% macro generate_schema_name(custom_schema_name, node) -%}
    {#
        Usa o schema customizado exatamente como definido, sem prefixar
        com target.schema. Evita raw_raw quando profile e +schema
        apontam para o mesmo nome.

        Sem custom_schema → usa target.schema (ex.: adventureworks.raw)
        Com custom_schema → usa só o custom (ex.: adventureworks.staging)
    #}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
