#include "include/display_metrics_linux/display_metrics_linux_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <X11/Xlib.h>
#include <X11/extensions/Xrandr.h>

#include <cstring>

#include "display_metrics_linux_plugin_private.h"

#define DISPLAY_METRICS_LINUX_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), display_metrics_linux_plugin_get_type(), \
                              DisplayMetricsLinuxPlugin))

struct _DisplayMetricsLinuxPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(DisplayMetricsLinuxPlugin, display_metrics_linux_plugin, g_object_get_type())

static void display_metrics_linux_plugin_handle_method_call(
    DisplayMetricsLinuxPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "getResolution") == 0) {
    response = get_resolution();
  } else if (strcmp(method, "getSize") == 0) {
    response = get_physical_size();
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }
  fl_method_call_respond(method_call, response, nullptr);
}

static void display_metrics_linux_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(display_metrics_linux_plugin_parent_class)->dispose(object);
}

static void display_metrics_linux_plugin_class_init(DisplayMetricsLinuxPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = display_metrics_linux_plugin_dispose;
}

static void display_metrics_linux_plugin_init(DisplayMetricsLinuxPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  DisplayMetricsLinuxPlugin* plugin = DISPLAY_METRICS_LINUX_PLUGIN(user_data);
  display_metrics_linux_plugin_handle_method_call(plugin, method_call);
}

void display_metrics_linux_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  DisplayMetricsLinuxPlugin* plugin = DISPLAY_METRICS_LINUX_PLUGIN(
      g_object_new(display_metrics_linux_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "display_metrics",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}

FlMethodResponse* get_resolution() {
    Display* display = XOpenDisplay(NULL);
    if (!display) {
        g_autoptr(FlValue) error = fl_value_new_string("Error: Unable to open X11 display");
        return FL_METHOD_RESPONSE(fl_method_error_response_new("display_error", "Failed to open X11 display", error));
    }

    Screen* screen = DefaultScreenOfDisplay(display);
    int width = screen->width;
    int height = screen->height;
    XCloseDisplay(display);

    g_autoptr(FlValue) result = fl_value_new_map();
    fl_value_set(result, fl_value_new_string("width"), fl_value_new_int(width));
    fl_value_set(result, fl_value_new_string("height"), fl_value_new_int(height));

    return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
}

FlMethodResponse* get_physical_size() {
    Display* display = XOpenDisplay(NULL);
    if (!display) {
        g_autoptr(FlValue) error = fl_value_new_string("Error: Unable to open X11 display");
        return FL_METHOD_RESPONSE(fl_method_error_response_new("display_error", "Failed to open X11 display", error));
    }

    Window root = DefaultRootWindow(display);
    XRRScreenResources* resources = XRRGetScreenResources(display, root);
    if (!resources) {
        XCloseDisplay(display);
        g_autoptr(FlValue) error = fl_value_new_string("Error: Unable to fetch screen resources");
        return FL_METHOD_RESPONSE(fl_method_error_response_new("screen_error", "Failed to fetch screen resources", error));
    }

    XRROutputInfo* output_info = XRRGetOutputInfo(display, resources, resources->outputs[0]);
    if (!output_info) {
        XRRFreeScreenResources(resources);
        XCloseDisplay(display);
        g_autoptr(FlValue) error = fl_value_new_string("Error: Unable to fetch output information");
        return FL_METHOD_RESPONSE(fl_method_error_response_new("output_error", "Failed to fetch output information", error));
    }

    Atom edid_atom = XInternAtom(display, "EDID", True);
    if (edid_atom == None) {
        XRRFreeOutputInfo(output_info);
        XRRFreeScreenResources(resources);
        XCloseDisplay(display);
        g_autoptr(FlValue) error = fl_value_new_string("Error: EDID property not found");
        return FL_METHOD_RESPONSE(fl_method_error_response_new("edid_error", "EDID property not found", error));
    }

    Atom actual_type;
    int actual_format;
    unsigned long nitems, bytes_after;
    unsigned char* prop = nullptr;

    if (XRRGetOutputProperty(display, resources->outputs[0], edid_atom, 0, 100, False, False,
                             AnyPropertyType, &actual_type, &actual_format, &nitems,
                             &bytes_after, &prop) == Success && prop) {
        if (nitems >= 128) {
            int width_cm = prop[21];
            int height_cm = prop[22];

            double width_in = width_cm / 2.54;
            double height_in = height_cm / 2.54;

            XFree(prop);
            XRRFreeOutputInfo(output_info);
            XRRFreeScreenResources(resources);
            XCloseDisplay(display);

            g_autoptr(FlValue) result = fl_value_new_map();
            fl_value_set(result, fl_value_new_string("width"), fl_value_new_float(width_in));
            fl_value_set(result, fl_value_new_string("height"), fl_value_new_float(height_in));

            return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
        }
        XFree(prop);
    }

    // Fallback to screen dimensions if EDID fails
    XRRFreeOutputInfo(output_info);
    XRRFreeScreenResources(resources);
    XCloseDisplay(display);

    display = XOpenDisplay(NULL);
    if (!display) {
        g_autoptr(FlValue) error = fl_value_new_string("Error: Unable to open X11 display for fallback");
        return FL_METHOD_RESPONSE(fl_method_error_response_new("display_error", "Failed to open X11 display", error));
    }

    Screen* screen = DefaultScreenOfDisplay(display);
    int width_mm_fallback = screen->mwidth;
    int height_mm_fallback = screen->mheight;
    XCloseDisplay(display);

    double width_in_fallback = width_mm_fallback / 25.4;
    double height_in_fallback = height_mm_fallback / 25.4;

    g_autoptr(FlValue) result_fallback = fl_value_new_map();
    fl_value_set(result_fallback, fl_value_new_string("width"), fl_value_new_float(width_in_fallback));
    fl_value_set(result_fallback, fl_value_new_string("height"), fl_value_new_float(height_in_fallback));

    return FL_METHOD_RESPONSE(fl_method_success_response_new(result_fallback));
}
