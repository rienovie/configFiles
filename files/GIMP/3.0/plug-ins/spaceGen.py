#!/usr/bin/env python3

import random
# Import necessary GIMP and GLib modules
from gi.repository import Gimp, Gio, GLib
import sys

# This function registers the plugin with GIMP.


def supernova_random_effect(
    procedure, run_mode, image, n_drawables, drawables, args, data
):
    # Ensure there's an active image and drawable
    if not image:
        print("No active image found.")
        return Gimp.PlugInReturn.FAILURE
    if not drawables:
        print("No active drawable found.")
        return Gimp.PlugInReturn.FAILURE

    drawable = drawables[0]

    # Get image dimensions for random center coordinates
    img_width = image.get_width()
    img_height = image.get_height()

    # Define ranges for random values
    # You can adjust these ranges as needed
    min_x_percent = 0.1
    max_x_percent = 0.9
    min_y_percent = 0.1
    max_y_percent = 0.9

    min_rays = 10
    max_rays = 50

    min_color_val = 0
    max_color_val = 255

    # Generate random values
    rand_x = random.randint(
        int(img_width * min_x_percent), int(img_width * max_x_percent)
    )
    rand_y = random.randint(
        int(img_height * min_y_percent), int(img_height * max_y_percent)
    )
    rand_rays = random.randint(min_rays, max_rays)
    rand_red = random.randint(min_color_val, max_color_val)
    rand_green = random.randint(min_color_val, max_color_val)
    rand_blue = random.randint(min_color_val, max_color_val)

    # Convert RGB values to a Gimp.RGB object
    rand_color = Gimp.RGB()
    rand_color.red = rand_red / 255.0  # Gimp.RGB expects 0.0-1.0
    rand_color.green = rand_green / 255.0
    rand_color.blue = rand_blue / 255.0

    try:
        # Run the 'gimp-supernova' procedure (plug-in)
        # The arguments must match the procedure's expected signature.
        # Use Gimp.Procedure.run() and pass arguments as a Gimp.ValueArray.
        # This is where the GIMP 3.0 API differs significantly from 2.x PDB calls.

        # Create a Gimp.ValueArray to hold the arguments
        # The order and type of arguments are critical.
        # Refer to GIMP's procedure browser (Help -> Procedure Browser) for exact signatures
        # of 'gimp-supernova' in GIMP 3.0.
        # Basic expected arguments for gimp-supernova are usually:
        # drawable, x, y, rays, color, random_hue
        # Some procedures might have additional arguments like 'progress_id', 'run_mode' etc.
        # For simplicity, we assume the core arguments.

        # Let's try to pass values based on a typical gimp-supernova signature.
        # If this fails, you'll need to check the exact GIMP 3.0 procedure signature
        # using the Help -> Procedure Browser in GIMP.
        # Look for 'gimp-supernova' and examine its parameters.

        # The signature for gimp-supernova typically looks something like:
        # (gint32 run_mode, GimpDrawable drawable, gdouble x, gdouble y,
        # gint32 rays, GimpRGB color, gboolean random_hue)

        Gimp.context_push()  # Push a new context
        image.undo_group_start()  # Start an undo group

        Gimp.Procedure.run(
            "gimp-supernova",
            # List of arguments, must match procedure signature
            [
                GLib.Value(Gimp.RunMode, run_mode),
                GLib.Value(Gimp.Drawable, drawable),
                GLib.Value(float, float(rand_x)),  # X coordinate (gdouble)
                GLib.Value(float, float(rand_y)),  # Y coordinate (gdouble)
                GLib.Value(int, rand_rays),  # Rays (gint32)
                GLib.Value(Gimp.RGB, rand_color),  # Color (GimpRGB)
                GLib.Value(bool, False),  # Random Hue (gboolean), set to False
            ],
        )

        image.undo_group_end()  # End the undo group
        Gimp.context_pop()  # Pop the context

        drawable.update(
            0, 0, drawable.get_width(), drawable.get_height()
        )  # Update display
        Gimp.displays_flush()  # Ensure display is updated

        print(
            f"Applied Supernova with: X={rand_x}, Y={
                rand_y}, Rays={rand_rays},"
            f" Color=({rand_red},{rand_green},{rand_blue})"
        )
        return Gimp.PlugInReturn.SUCCESS

    except Exception as e:
        image.undo_group_end()  # Ensure undo group is ended even on error
        Gimp.context_pop()
        print(f"Error applying Supernova: {e}")
        return Gimp.PlugInReturn.FAILURE


# Registration function required for GIMP 3.0 Python plugins
# This tells GIMP about your plugin, where it appears in the menus, etc.
class SupernovaRandomPlugIn(Gimp.PlugIn):
    __gtype_name__ = "SupernovaRandomPlugIn"

    def do_query_procedures(self):
        # Register the procedure for the plugin
        # The tuple defines the procedure's properties:
        # (name, blurb, help, author, copyright, date, menu_label, imagetypes,
        #                   params, results, status_flags, run_modes)
        return [
            (
                "python-fu-supernova-random",  # The name GIMP uses internally
                "Applies Supernova filter with random parameters",  # Short description
                "Applies the GIMP Supernova filter with randomized center coordinates,"
                # Long description/help
                " number of rays, and color. Run multiple times for more effects.",
                "Your Name",  # Author
                "Your Copyright",  # Copyright
                "2023",  # Date
                "<Image>/Filters/Light and Shadow/Random Supernova...",  # Menu path
                "RGB*, GRAY*, INDEXED*",  # Supported image types
                # Input parameters for the script (none needed if internal randomness)
                [],
                [],  # Output parameters from the script
                Gimp.PDBStatusType.SUCCESS,  # Status flags
                Gimp.RunMode.INTERACTIVE,  # Supported run modes
            )
        ]

    def do_create_procedure(self, name):
        # Assign the procedure to the function
        # This maps "python-fu-supernova-random" to our 'supernova_random_effect' function.
        procedure = Gimp.Procedure.new_from_function(
            self.do_query_procedures()[0][0], supernova_random_effect, None
        )
        procedure.set_menu_label(
            self.do_query_procedures()[0][6]
        )  # Set menu label again for good measure
        return procedure


Gimp.main(SupernovaRandomPlugIn.__gtype_name__, sys.argv)
