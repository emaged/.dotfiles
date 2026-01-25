// eslint.config.mjs
import js from "@eslint/js";
import globals from "globals";
import pluginReact from "eslint-plugin-react";
import reactHooks from "eslint-plugin-react-hooks";
import { defineConfig } from "eslint/config";
import prettier from "eslint-config-prettier/flat";
import html from "@html-eslint/eslint-plugin";
import css from "@eslint/css";

const htmlRecommended = html.configs["flat/recommended"];

export default defineConfig([
  // ------------------------------------------------------
  // JavaScript rules (scoped)
  // ------------------------------------------------------

  {
    files: ["**/*.{js,mjs,cjs,jsx}"],
    ...js.configs.recommended,
    languageOptions: {
      ...js.configs.recommended.languageOptions,
      globals: {
        ...globals.browser,
        ...(js.configs.recommended.languageOptions?.globals ?? {}),
      },
    },
  },

  // ------------------------------------------------------
  // React rules (scoped) — consolidated & safe
  // ------------------------------------------------------
  {
    files: ["**/*.{js,jsx}"],
    ...pluginReact.configs.flat.recommended,
  },
  {
    files: ["**/*.{js,jsx}"],
    ...pluginReact.configs.flat["jsx-runtime"],
  },
  {
    files: ["**/*.{js,jsx}"],
    settings: {
      react: {
        version: "detect",
      },
    },
    rules: {
      "react/prop-types": "off",
    },
  },
  {
    files: ["**/*.{js,jsx}"],
    plugins: {
      "react-hooks": reactHooks,
    },
    rules: reactHooks.configs.recommended.rules,
  },

  // ------------------------------------------------------
  // HTML linting (scoped)
  // ------------------------------------------------------
  {
    files: ["**/*.html"],
    ...htmlRecommended,
    rules: {
      ...htmlRecommended.rules, // keep the recommended HTML rules
      "@html-eslint/no-duplicate-class": "error", // add your extra rule
      "@html-eslint/require-closing-tags": ["off"],
      "@html-eslint/no-extra-spacing-attrs": "off",
      "@html-eslint/attrs-newline": "off",
      "@html-eslint/indent": "off",
    },
  },

  {
    files: ["**/*.css"],
    plugins: {
      css,
    },
    language: "css/css",
    rules: {
      "css/no-duplicate-imports": "error",
      // Lint CSS files to ensure they are using
      // only Baseline Widely available features:
      "css/use-baseline": [
        "warn",
        {
          available: "widely",
        },
      ],
    },
  },

  // ------------------------------------------------------
  // Prettier (always last)
  // ------------------------------------------------------
  prettier,
]);
