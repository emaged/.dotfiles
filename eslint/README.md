# Shared ESLint configuration

Use Node.js 20.19+, 22.13+, or 24+ to satisfy the CSS plugin's requirements.
Install the locked dependencies after cloning or updating this directory:

```sh
npm ci --prefix "$HOME/.dotfiles/eslint" --ignore-scripts
```

From the project you want to lint, run:

```sh
"$HOME/.dotfiles/eslint/node_modules/.bin/eslint" \
  --config "$HOME/.dotfiles/eslint/eslint.config.js" .
```

The configuration covers browser JavaScript, React JSX, HTML, and CSS. Dependencies
are local to this directory; globally installed npm packages do not satisfy its
ES module imports. ESLint stays on major version 9 for compatibility with the
React plugin. ESLint 9 is now out of upstream support; upgrading to ESLint 10
requires a compatible release or replacement of `eslint-plugin-react`. The
lockfile records the tested dependency versions.
