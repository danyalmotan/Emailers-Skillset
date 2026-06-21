# Fixture Notes

This folder is for real or trimmed Samsung jobs that you want to keep as repeatable validation cases.

Recommended pattern:

```text
fixtures/
  sa-basic/
    job/
      [original job files or a reduced representative subset]
    expected/
      sa-basic.expected.json
```

## How to build a good fixture

Keep each fixture focused on one rule cluster:

1. Region and footer selection
2. French localization
3. Shared image handling
4. 1x vs `_2x` image selection
5. Published folder and ZIP packaging
6. Live MirrorPage and unsubscribe markup
7. Published packaging and ZIP completeness

## Guidance

- Prefer one strong fixture per edge case over many near-duplicates.
- Trim large asset sets if the rule under test does not need every file.
- Keep expectation files next to the fixture they validate.
- Do not store generated CDN-rewritten HTML as the expected result for this harness. This validator is for the local pre-Everlytic output.