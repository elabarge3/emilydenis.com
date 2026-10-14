# emilydenis.com

Emily Denis's portfolio — Astro 5 + Tailwind 4 static site.

## Develop

```bash
npm install
npm run dev        # local dev server
npm run build      # static build → dist/
npm run preview    # serve the built site
```

## Deploy (Render)

One-time setup, ~2 minutes:

1. In the [Render dashboard](https://dashboard.render.com): **New → Static Site**.
2. Connect this GitHub repo (`elabarge3/emilydenis.com`). `render.yaml`
   pre-fills the settings (build `npm install && npm run build`, publish `dist`).
3. Create the site. Every push to `main` auto-deploys from then on.

### Custom domain

In the Render site: **Settings → Custom Domains** → add `emilydenis.com` and
`www.emilydenis.com`. Then at your domain registrar add the records Render
shows you — typically:

| Host | Type  | Value                       |
|------|-------|-----------------------------|
| `@`  | A     | `216.24.57.1`               |
| `www`| CNAME | `<your-site>.onrender.com`  |

(Trust the values in the Render dashboard if they differ.) TLS is provisioned
automatically once DNS propagates. Verify with `dig emilydenis.com` and then
`curl -I https://emilydenis.com`.

## Resume

`src/pages/resume.astro` is the single source of truth. The PDF is generated
from it, so edit the page and never the PDF:

```bash
npm run resume:pdf   # builds, prints /resume via headless Chrome → public/resume.pdf
```

Requires Google Chrome. Keep the output at two pages, single column, with real
selectable text so applicant tracking systems can parse it. `public/resume.pdf`
is committed, since Render builds straight from the repo.

Resumes tailored to a specific company are deliberately kept **out of this
repo** so nothing company-specific is ever published to the site.

## Content TODOs

- `src/pages/hangeasy.astro` / `napmap.astro` — `TODO(emily)` notes at the top
  of each file list the personal facts (origin stories, traction) worth adding.

## Structure

- `src/pages/` — `index` (landing), `fitscript`, `hangeasy`, `napmap` case studies
- `src/components/` — Header, Footer, ProjectCard, CaseStudyHero
- `public/images/` — screenshots (FitScript shots captured from the live demo)
