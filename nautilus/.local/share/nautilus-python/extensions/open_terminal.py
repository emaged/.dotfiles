from gi import require_version

require_version("Nautilus", "4.1")

from gi.repository import Gio, GObject, Nautilus


class OpenTerminalAction(GObject.GObject, Nautilus.MenuProvider):
    def _on_activate(self, _menu, path):
        Gio.Subprocess.new(
            ["setsid", "uwsm-app", "--", "xdg-terminal-exec", f"--dir={path}"],
            Gio.SubprocessFlags.NONE,
        )

    def _items_for_folder(self, folder, context):
        if not folder.is_directory() or folder.get_uri_scheme() != "file":
            return []

        location = folder.get_location()
        path = location.get_path() if location else None
        if path is None:
            return []

        item = Nautilus.MenuItem(
            name=f"OpenTerminalNautilus::{context}",
            label="Open in Terminal",
            tip="Open a terminal in this folder",
            icon="utilities-terminal",
        )
        item.connect("activate", self._on_activate, path)
        return [item]

    def get_file_items(self, files):
        if len(files) != 1:
            return []
        return self._items_for_folder(files[0], "selected_folder")

    def get_background_items(self, current_folder):
        return self._items_for_folder(current_folder, "current_folder")
