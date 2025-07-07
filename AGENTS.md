## Project Overview

This is a SvelteKit application for a fictional printing services company, "PrintPro Services". It uses:
- SvelteKit as the web framework.
- Tailwind CSS for styling.
- GSAP (GreenSock Animation Platform) for animations.

## Development

### Prerequisites
- Node.js (version specified in `.nvmrc` if present, otherwise latest LTS)
- npm (usually comes with Node.js)

### Setup
1. Clone the repository.
2. Install dependencies:
   ```bash
   npm install
   ```

### Running the Development Server
To start the SvelteKit development server:
```bash
npm run dev
```
This will typically open the application on `http://localhost:5173`. The `--open` flag can be added to automatically open it in your browser:
```bash
npm run dev -- --open
```

### Building for Production
To create a production build:
```bash
npm run build
```
The output will be in the `build` directory (or as configured in `svelte.config.js`). You can then use an adapter (e.g., `adapter-static` for static sites, `adapter-node` for Node.js server) to prepare for deployment. This project is currently configured with the default `adapter-auto`.

## Key Technologies & Structure

- **SvelteKit (`src/routes`)**: Pages and layouts are defined here.
  - `src/routes/+page.svelte`: The main homepage.
  - `src/routes/+layout.svelte`: The main layout, imports global CSS and sets up header/footer.
- **Components (`src/lib/components`)**: Reusable Svelte components like `Header.svelte`, `Footer.svelte`, `ServiceCard.svelte`.
- **Styling (`src/app.css`, Tailwind CSS)**: Global styles (including Tailwind's base, components, utilities) are in `src/app.css`. Tailwind utility classes are used directly in Svelte components.
  - `tailwind.config.js`: Tailwind CSS configuration.
  - `postcss.config.js`: PostCSS configuration (used by Tailwind).
- **Animations (GSAP)**: GSAP is used for programmatic animations.
  - Scroll-triggered animations are used on the homepage (`+page.svelte`).
  - Hover animations are used in components like `ServiceCard.svelte`.
  - GSAP plugins like `ScrollTrigger` are registered in `src/routes/+layout.svelte`.

## Coding Conventions & Notes

- **Tailwind CSS First**: Prioritize using Tailwind utility classes for styling. Add custom CSS in `app.css` or component `<style>` blocks only when necessary.
- **GSAP Animations**: Ensure animations are smooth and performant.
  - Use `gsap.from()` for intro animations.
  - Use `ScrollTrigger` for animations that react to scroll position.
  - Clean up GSAP instances (e.g., timelines, ScrollTriggers) in Svelte's `onDestroy` or the return function of `onMount` to prevent memory leaks, especially for timelines created within components.
- **Component Reusability**: Design components to be reusable and configurable via props.
- **Accessibility**: Keep accessibility in mind (e.g., semantic HTML, ARIA attributes if needed, keyboard navigation). (This is a general guideline, specific ARIA has not been implemented yet).

## Linting and Formatting
- This project was initialized without ESLint or Prettier. If these are added later, ensure to configure them appropriately for Svelte and Tailwind CSS.
  - Example: `eslint-plugin-svelte`, `prettier-plugin-svelte`, `prettier-plugin-tailwindcss`.

This `AGENTS.md` provides a basic guide for working with the project.
Remember to keep dependencies updated and follow best practices for Svelte, Tailwind, and GSAP.
