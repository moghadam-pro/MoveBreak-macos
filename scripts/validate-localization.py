#!/usr/bin/env python3
"""Check translations and exercise resource integrity without external dependencies."""
import json
import re
from pathlib import Path

root = Path(__file__).resolve().parent.parent
languages = ('en', 'fa', 'es', 'tr', 'de')
catalogs = {lang: json.loads((root / f'Sources/MoveBreakCore/Resources/strings.{lang}.json').read_text()) for lang in languages}
for lang, catalog in catalogs.items():
    assert set(catalog) == set(catalogs['en']), f'Incomplete {lang} UI catalog'
    for key, value in catalog.items():
        assert value.strip(), (lang, key)
        assert value.count('%@') == catalogs['en'][key].count('%@'), (lang, key)
exercises = json.loads((root / 'Sources/MoveBreak/Resources/exercises.json').read_text())
assert len(exercises) == 18
assert len({exercise['id'] for exercise in exercises}) == 18
for exercise in exercises:
    assert (root / 'Sources/MoveBreak/Resources/Exercises' / exercise['image']).is_file()
    for lang in languages:
        assert exercise['titles'][lang].strip() and exercise['instructions'][lang].strip(), (lang, exercise['id'])
# Check literal keys used by application-owned controls; dynamic status/category keys
# are validated by the complete catalog and exercise checks above.
for path in (root / 'Sources/MoveBreak').glob('*.swift'):
    for key in re.findall(r'(?:model\.|self\.)?text\("([^"\n]+)"', path.read_text()):
        assert key in catalogs['en'], (path.name, key)
print(f'{len(catalogs["en"])} UI keys and 18 exercises verified in all five languages.')
