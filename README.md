# Open Problems in ITC & PAIC

An audited catalog of open methodological problems in indirect treatment comparisons (ITC)
and population-adjusted indirect comparisons (PAIC).

**Site:** <https://choxos.github.io/ITC-open-problems/>

Each entry states what the problem is, why it stays open, what has already been tried, and
the most probable route to a solution. Every entry carries a verification verdict recording
what happened when its claims were checked, and the evidence behind that verdict is shown on
the page.

## Why the verdicts are there

The source material was produced by a large language model. Publishing a machine-generated
research agenda as settled fact would be a disservice, so nothing appears here without having
been checked first:

- every DOI, arXiv identifier, PubMed identifier, CRAN version, and repository claim resolved
  against its registry;
- each cited work checked for whether it supports the claim attributed to it;
- an adversarial pass instructed to refute that each problem is open;
- two independent frontier models (GPT-5.6 Sol and Grok 4.5) auditing the same claims blind
  to each other;
- claims about a software package re-checked against that package's current source.

Where auditors disagreed, the site shows the disagreement rather than resolving it silently.
See [How this was verified](https://choxos.github.io/ITC-open-problems/methods.html).

## Repository layout

```
_quarto.yml            site configuration
index.qmd              landing page
catalog.qmd            the filterable master listing
agenda.qmd             prioritized agenda
landscape.qmd          method landscape and decision path
methods.qmd            audit protocol and its limits
categories/*.qmd       one listing page per category   (generated)
problems/*.qmd         one page per problem            (generated)
build/                 registry -> Quarto renderers and audit tooling
references.bib         verified citation set
documentation/         source documents and audit working files (not tracked)
```

`problems/` and `categories/` are **generated** from the audit registry by
`build/render_site.mjs`. Edit the registry, not the `.qmd` files; regenerating overwrites
them.

## Building locally

```bash
node build/render_site.mjs    # registry -> problem and category pages
quarto render                 # -> docs/
quarto preview                # live preview
```

Rendering needs [Quarto](https://quarto.org) 1.8 or later and Node 18 or later. Nothing else;
the site has no R execution at render time.

Pushing to `main` renders and publishes to the `gh-pages` branch via GitHub Actions.

## Audit tooling

| Script | Purpose |
|---|---|
| `build/render_site.mjs` | Registry to Quarto source |
| `build/make_audit_batches.mjs` | Registry to batched prompts for the external auditors |
| `build/adjudicate.mjs` | Auditor opinions to a published verdict, by a fixed rule |
| `build/fetch_papers.py` | Collects open-access copies of cited works for local reference |

`documentation/audit/calibration.json` holds known-answer cases verified by hand. Any audit
configuration that fails to reproduce them is miscalibrated, so they are asserted before the
site is built.

## License

[MIT](LICENSE).
