# Samsung Mailer Harness

This harness validates generated Samsung mailer outputs against the current rules in `SKILL.md`.

It is separate from the prompt itself:

- `SKILL.md` tells the agent how to build a mailer
- `evals/evals.json` is prompt-eval oriented
- `harness/` checks the generated deliverables on disk

## What the harness validates

The validator is designed around the current production workflow:

- `Published/` exists inside the job folder
- the root `Published/` HTML-only copy exists
- the mailer subfolder exists with its own HTML copy
- the mailer ZIP exists inside the mailer subfolder
- the live MirrorPage block is present for View Online
- the live Adobe unsubscribe URL is present
- `ZZZZZ` and `YYYYY` placeholders do not remain in output
- local image references are flat, sanitized filenames
- all referenced local images exist beside the folder HTML
- remote images are limited to known reusable CDN assets
- the ZIP contains the folder HTML plus the referenced local images only

By default those packaging checks stay strict. For mined historical fixtures, you can opt out per expectation when an older completed job is still useful as a content or structure reference but does not match the latest packaging workflow.

## Folder layout

```text
harness/
  README.md
  expected/
    template.expected.json
  fixtures/
    README.md
  scripts/
    new-expectation-from-mailer.ps1
    run-harness.ps1
    validate-mailer-output.ps1
```

## Quick start

1. Copy `expected/template.expected.json` to a new file for the mailer you want to validate.
2. Update the job-relative paths and the assertions you care about.
3. Run the validator.

```powershell
powershell -ExecutionPolicy Bypass -File .github/skills/samsung-mailer/harness/scripts/validate-mailer-output.ps1 -ExpectationPath .github/skills/samsung-mailer/harness/expected/template.expected.json
```

To run every expectation file in a folder:

```powershell
powershell -ExecutionPolicy Bypass -File .github/skills/samsung-mailer/harness/scripts/run-harness.ps1 -ExpectationDirectory .github/skills/samsung-mailer/harness/expected
```

## Grow The Harness

Yes, the harness can improve with each completed email, but it should do that through a controlled promotion step rather than silently rewriting its own rules.

Recommended loop for every finished mailer:

1. Generate and package the mailer as normal.
2. Promote the completed mailer folder into a candidate expectation.
3. Validate that expectation immediately.
4. Keep it if it adds useful coverage for a new region, layout, packaging pattern, or edge case.

Use the promotion script like this:

```powershell
powershell -ExecutionPolicy Bypass -File .github/skills/samsung-mailer/harness/scripts/new-expectation-from-mailer.ps1 -MailerFolderPath "2026\Some Job\Published\Some Mailer Folder" -Validate
```

What it does:

- detects the job folder, `Published/` folder, folder HTML, and ZIP automatically
- harvests the current title, key required strings, local image references, and remote asset basenames
- infers whether the completed mailer follows the current strict packaging layout or an older legacy layout
- writes a candidate `.expected.json` into `harness/expected/`
- optionally runs the validator immediately when `-Validate` is supplied

That gives you a safe self-improvement loop: each successful real-world mailer can become a new regression fixture, but only after review.

## Expectation model

The expectation file is intentionally simple. It points at one generated mailer and declares the invariants that must hold.

Core fields:

- `jobFolder`: relative or absolute path to the mailer job folder
- `rootHtml`: root HTML-only copy inside `Published/`
- `mailerFolder`: folder inside `Published/` containing the local-image version
- `mailerHtml`: HTML file inside that mailer folder
- `zipName`: ZIP file inside the mailer folder
- `requireRootHtmlCopy`: optional, defaults to `true`; set to `false` for legacy fixtures without a root `Published/` HTML copy
- `requireFolderZip`: optional, defaults to `true`; set to `false` for legacy fixtures without a per-mailer ZIP inside the folder
- `titleContains`: title text to assert
- `mustContain`: required strings in the folder HTML
- `mustNotContain`: forbidden strings in the folder HTML
- `requiredLocalImages`: optional list of local image filenames that must be referenced
- `allowed2xImages`: optional list of `_2x` filenames explicitly allowed when no 1x exists
- `allowedRemoteHosts`: optional list of extra remote hosts allowed for that specific fixture, in addition to the default MailerCDN host

Use the legacy switches sparingly. The default expectation for new generated mailers is still the full current packaging layout.

## Suggested fixture coverage

Build expectation files for at least these cases:

1. SA mailer with white footer
2. NG or GH regional variant using `africa_en`
3. SN or CI French variant
4. KE/TZ shared-image variant
5. Mailer with a sliced border frame
6. Mailer with shared images and flat sanitized filenames across variants
7. 1200px design-source job

## What this harness does not do yet

- It does not render HTML screenshots
- It does not OCR the JPG to confirm copy accuracy
- It does not compare visual diffs against the design
- It does not generate the mailer for you

That is deliberate. This first version is for structural and packaging regressions, because those are stable and cheaply testable.