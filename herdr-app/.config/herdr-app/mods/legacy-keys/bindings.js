// Actions migrated from ~/.config/herdr/config.toml.
export const prefixActions = {
  "q": { notice: "Herdr reloads settings, keys and mods automatically when saved." },
  "d": { command: "window.close" },
  "[": { notice: "Keyboard copy mode is unavailable. Select text with the mouse and use Ctrl+Shift+C; Ctrl+Shift+F searches scrollback." },
  "h": { command: "pane.split", args: { direction: "right" } },
  "v": { command: "pane.split", args: { direction: "down" } },
  "x": { command: "pane.close" },
  "z": { command: "pane.zoom" },
  ";": { command: "legacy-keys.last" },
  "shift-o": { notice: "This Herdr build has no pane-rename command." },
  "c": { command: "tab.new" },
  "r": { command: "tab.rename" },
  "k": { command: "tab.close", args: { confirmed: true } },
  "p": { command: "tab.prev" },
  "n": { command: "tab.next" },
  "shift-c": { command: "space.new" },
  "shift-r": { command: "space.rename" },
  "shift-k": { command: "space.close", args: { confirmed: true } },
  "shift-p": { command: "space.prev" },
  "shift-n": { command: "space.next" }
};
for (let i = 1; i <= 9; i++) prefixActions[String(i)] = { command: "tab.select", args: { index: i } };
for (const direction of ["left", "down", "up", "right"]) {
  prefixActions["ctrl-" + direction] = { notice: "Keyboard pane resizing is unavailable in this Herdr build. Drag a split boundary to resize." };
}

export function prefixKey(event) {
  const m = event.modifiers ?? {};
  const key = event.key.toLowerCase();
  if (!m.control && !m.alt && !m.platform && (event.key_char === "?" || key === "?" || (key === "/" && m.shift))) return "?";
  const modifiers = [];
  if (m.control) modifiers.push("ctrl");
  if (m.alt) modifiers.push("alt");
  if (m.platform) modifiers.push("cmd");
  if (m.shift) modifiers.push("shift");
  return [...modifiers, key].join("-");
}

export function moveTarget(tabs, id, delta) {
  const tab = tabs.find(tab => tab.id === id);
  if (!tab) return null;
  const index = Math.max(1, Math.min(tabs.length, tab.index + delta));
  return index === tab.index ? null : { id: tab.id, index };
}

export function togglePlan(panes, state, current) {
  const bottom = panes.find(p => p.pane === state?.bottom);
  if (!bottom) return { kind: "create" };
  const main = panes.find(p => p.pane === state?.main && p.pane !== bottom.pane)
    ?? panes.find(p => p.pane !== bottom.pane);
  if (!main) return { kind: "existing", actions: [{ command: "pane.focus", args: { pane: bottom.pane } }] };
  const actions = [];
  if (panes.some(p => p.zoomed)) {
    actions.push({ command: "pane.zoom", args: { pane: current } });
    actions.push({ command: "pane.focus", args: { pane: bottom.pane } });
  } else {
    actions.push({ command: "pane.focus", args: { pane: main.pane } });
    actions.push({ command: "pane.zoom", args: { pane: main.pane } });
  }
  return { kind: "existing", state: { main: main.pane, bottom: bottom.pane }, actions };
}
