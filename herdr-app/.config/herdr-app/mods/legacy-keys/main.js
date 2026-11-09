import { View, div } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { focused, panes, spaces, run, theme, props, closeOverlay, nextCommand,
  shared, setShared, exec, notify } from "herdr";
import { prefixActions, prefixKey, moveTarget, togglePlan } from "./bindings.js";

const STATE = "emiel.legacyKeys";
export default class LegacyKeys extends View {
  init(_props, cx) {
    this.overlay = props()?.overlay;
    this.help = false;
    this.busy = false;
    this.hosts = {};
    this.hostPending = new Set();
    if (this.overlay) {
      this.handle = cx.focus_handle();
      this.handle.focus();
      cx.timer.after(0, () => this.handle.focus());
    } else {
      this.current = focused()?.pane ?? null;
      this.previous = null;
      cx.spawn(async (cx) => {
        for (;;) {
          const command = await nextCommand();
          try { await this.command(command); }
          catch (e) { notify({ title: "Herdr shortcut", body: String(e), level: "error" }); }
          cx.notify();
        }
      });
    }
  }

  dismiss() { if (this.overlay) closeOverlay(this.overlay); }

  key(e, cx) {
    cx.stop_propagation();
    if (e.is_held) return;
    const key = prefixKey(e);
    if (key === "escape") return this.dismiss();
    if (key === "?") { this.help = !this.help; cx.notify(); return; }
    const action = prefixActions[key];
    this.dismiss();
    if (!action) {
      notify({ title: "Prefix", body: "No migrated shortcut for " + e.keystroke });
    } else if (action.notice) {
      notify({ title: "Herdr migration", body: action.notice });
    } else {
      run(action.command, action.args ?? {});
    }
  }

  async command(command) {
    if (command === "last") {
      const target = panes().find(p => p.pane === this.previous);
      if (target) {
        run("tab.select", { id: target.tab });
        run("pane.focus", { pane: target.pane });
      }
    } else if (command === "move-prev" || command === "move-next") {
      const f = focused();
      const space = spaces().find(s => s.id === f?.space);
      const target = moveTarget(space?.tabs ?? [], f?.tab, command === "move-prev" ? -1 : 1);
      if (target) run("tab.move", target);
    } else if (command === "toggle") {
      await this.toggleTerminal();
    }
  }

  async toggleTerminal() {
    if (this.busy) return;
    const f = focused();
    if (!f?.pane) {
      notify({ title: "Toggle terminal", body: "Focus a terminal pane first." });
      return;
    }
    this.busy = true;
    try {
      const states = shared(STATE) ?? {};
      const tabPanes = panes().filter(p => p.tab === f.tab);
      const plan = togglePlan(tabPanes, states[f.tab], f.pane);
      if (plan.kind === "create") {
        if (tabPanes.some(p => p.zoomed)) run("pane.zoom", { pane: f.pane });
        // The CLI returns the created IDs; run() itself returns no result.
        const reply = await exec("herdr-app", ["do", "pane.split",
          JSON.stringify({ pane: f.pane, direction: "down" })]);
        if (reply.code !== 0) throw new Error(reply.stderr || reply.stdout || "Split failed");
        const made = JSON.parse(reply.stdout);
        if (made.error || typeof made.pane !== "string") throw new Error(made.error || "No pane ID returned");
        setShared(STATE, { ...(shared(STATE) ?? {}), [f.tab]: { main: f.pane, bottom: made.pane } });
        return;
      }
      if (plan.state) setShared(STATE, { ...states, [f.tab]: plan.state });
      for (const action of plan.actions) run(action.command, action.args);
    } finally { this.busy = false; }
  }

  trackFocus() {
    const now = focused()?.pane;
    if (now && now !== this.current) {
      this.previous = this.current;
      this.current = now;
    }
  }

  hostname(space, cx) {
    const machine = space?.machine ?? "";
    if (!(machine in this.hosts) && !this.hostPending.has(machine)) {
      this.hostPending.add(machine);
      cx.spawn(async (cx) => {
        try {
          const result = await exec("hostname", [], { on: machine || null });
          this.hosts[machine] = result.code === 0 ? result.stdout.trim() : (machine || "localhost");
        } catch { this.hosts[machine] = machine || "localhost"; }
        this.hostPending.delete(machine);
        cx.notify();
      });
    }
    return this.hosts[machine] ?? (machine || "…");
  }

  render(cx) {
    const t = theme();
    if (this.overlay) {
      const lines = this.help ? [
        "h / v  Split right / down    x  Close pane    z  Zoom",
        ";  Previous pane    c / r / k  New / rename / close tab",
        "p / n  Previous / next tab    1–9  Select tab",
        "Shift+C / R / K  New / rename / close space",
        "Shift+P / N  Previous / next space    d  Close window",
        "q  Reload information    ?  Help    Escape  Cancel",
        "Ctrl+\\  Toggle bottom terminal    Alt+Shift+←/→  Move tab",
        "Resize, pane rename and copy mode are unavailable in this app."
      ] : ["Press your shortcut, ? for help, or Escape to cancel."];
      return v_flex().id("legacy-prefix").track_focus(this.handle)
        .on_key_down((e, cx) => this.key(e, cx))
        .w_full().p(16).gap(8).bg(t.popover).text_color(t.foreground).text_size(12)
        .child(div().font_semibold().text_color(t.accent).child("Ctrl+Space"))
        .children(lines.map(line => div().child(line)));
    }
    this.trackFocus();
    const f = focused();
    const space = spaces().find(s => s.id === f?.space);
    const tab = space?.tabs.find(tab => tab.id === f?.tab);
    const host = this.hostname(space, cx);
    return h_flex().id("legacy-status").size_full().px(12).gap(10)
      .items_center().justify_end().bg(t.chrome).text_size(12).text_color(t.muted)
      .child(div().id("legacy-prefix-button").cursor_pointer()
        .on_click(() => run("mod.open", { name: "legacy-keys" }))
        .text_color(t.dim).child("Ctrl+Space"))
      .when(Boolean(tab?.zoomed), el => el.child(div().text_color(t.accent).child("Z")))
      .child(div().truncate().child(host));
  }
}
