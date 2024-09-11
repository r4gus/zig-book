const std = @import("std");
const gtk = @import("gtk.zig");

fn onButtonClicked(_: *gtk.GtkWidget, _: gtk.gpointer) void {
    std.log.info("Hello, World!", .{});
}

fn onActivate(app: *gtk.GtkApplication) void {
    const window: *gtk.GtkWidget = gtk.gtk_application_window_new(app);

    gtk.gtk_window_set_title(
        @as(*gtk.GtkWindow, @ptrCast(window)),
        "Zig Basics",
    );
    gtk.gtk_window_set_default_size(
        @as(*gtk.GtkWindow, @ptrCast(window)),
        920,
        640,
    );

    const button = gtk.gtk_button_new_with_label("Click Me!");
    gtk.gtk_window_set_child(
        @as(*gtk.GtkWindow, @ptrCast(window)),
        @as(*gtk.GtkWidget, @ptrCast(button)),
    );
    _ = gtk.z_signal_connect(
        button,
        "clicked",
        @as(gtk.GCallback, @ptrCast(&onButtonClicked)),
        null,
    );

    gtk.gtk_window_present(@as(*gtk.GtkWindow, @ptrCast(window)));
}

pub fn main() !void {
    const application = gtk.gtk_application_new(
        "de.zig.basics",
        gtk.G_APPLICATION_FLAGS_NONE,
    );
    _ = gtk.z_signal_connect(
        application,
        "activate",
        @as(gtk.GCallback, @ptrCast(&onActivate)),
        null,
    );
    _ = gtk.g_application_run(
        @as(*gtk.GApplication, @ptrCast(application)),
        0,
        null,
    );
}
