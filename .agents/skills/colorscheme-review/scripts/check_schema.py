"""Validate JSON or YAML files against one JSON Schema.

Usage: check_schema.py <schema.json> <instance.json|.yml|.yaml>...
Prints one tab-separated line per invalid or unparsable file,
`<file>\t<errors>`, with up to five errors joined by " | ". Exits 0 when the
files were checked, whatever the result, and 2 when the schema is unusable.
"""

import json
import sys

import jsonschema
import yaml

schema_path, *instance_paths = sys.argv[1:]
try:
    with open(schema_path) as f:
        schema = json.load(f)
    validator = jsonschema.validators.validator_for(schema)(schema)
except (ValueError, jsonschema.SchemaError) as error:
    print(f"unusable schema: {error}", file=sys.stderr)
    sys.exit(2)


def problems(path):
    try:
        with open(path) as f:
            if path.endswith((".yml", ".yaml")):
                instance = yaml.safe_load(f)
            else:
                instance = json.load(f)
    except (ValueError, yaml.YAMLError) as error:
        return [f"cannot parse: {error}"]
    return [
        f"{'/'.join(map(str, e.absolute_path)) or '<root>'}: {e.message}"
        for e in list(validator.iter_errors(instance))[:5]
    ]


for path in instance_paths:
    if messages := problems(path):
        print(f"{path}\t{' | '.join(messages)}".replace("\n", " "))
