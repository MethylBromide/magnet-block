# magnet-block
3D-printed holder for mounting small artwork on a refrigerator magnet, wrap-around style so the picture continues onto the edges behind a transparent "shell".

This project is implemented in the open-source [OpenSCAD](https://openscad.org) CAD modeling scripting language.

![Image](https://github.com/users/MethylBromide/projects/3/assets/12117008/b99dea3b-ed57-428b-be1d-10024fd480e6) ![Image](https://github.com/users/MethylBromide/projects/3/assets/12117008/acc35cd8-3320-4f1d-bf78-60d525609213)


This is a two-part, snap-together model. The front of the artwork is not covered. You can protect it with Mod-Podge if you like so no part of the picture is exposed. The pieces assemble by snapping securely together, with no glue needed to hold the frame together. If you choose to add magnet posts, you must glue the magnets on, and it's not a bad idea to glue the picture to the backing block to force it to lie flat.

## Printing Considerations
The model is fully parameterized as to dimensions, has options for whether and how to attach magnets to the back, and is designed for easy 3D printing. No supports are needed and most printers will not need a brim.

The "shell" needs to be transparent so the edges of the artwork show through. The "block" part can be any color, provided it doesn't show through the artwork. Therefore it's generally best to print them separately, from separate STL files.

You may want to tell your slicer program to "iron" the big flat back of the block, to improve adhesion of any stickers you want to put on it.

## Customizer Settings
All measurements are in mm.

### Layout
The **Layout** parameter of this script controls what aspects of the project you want to preview and export.

- The default setting, "Assembly diagram", shows in the preview window with both pieces in their assembled configuration. When you render this layout (F6 on Windows), the pieces are separated and moved into printing orientation -- with their flat sides down.
- "Shell only" or "Back only" display only the single part, oriented for printing. It's probably easiest to use these to create two STL files each containing one part, since you'll usually want to print them in different colors.
- "Artwork template" is a 2D shape showing the outline for the shape the artwork needs to be to fit into the holder.

![Preview of Assembly diagram with cross-section cut](https://github.com/users/MethylBromide/projects/3/assets/12117008/1980c4c3-f74c-44aa-86b4-e6661b4b2c72) ![Shell only](https://github.com/users/MethylBromide/projects/3/assets/12117008/f1e8f933-f944-428b-910f-5e82e05bb080) ![Block only](https://github.com/users/MethylBromide/projects/3/assets/12117008/8ec01b4c-250e-4fb5-8ad2-0208b14cb791) ![Artwork Template](https://github.com/users/MethylBromide/projects/3/assets/12117008/9905c788-2b70-471b-b7ea-5206fd4bf72d)

### tolerance
The **tolerance** setting corresponds to the precision of your 3D printer and filament. Only adjust it if you find the pieces are too difficult to fit together or too loose (but also check whether the "paper thickness" setting is correct).

### Picture size
This is the dimensions of the part of your artwork that faces outward, so the size of the "block". It doesn't matter which of the numbers is smaller -- the frame doesn't have a "top" edge.

### Flap width
The depth of the block, which is the same as the size of the flap that folds down around the edge.

### Paper thickness
I suggest using an accurate number here. If you aren't using the form-fitting template below, which gives you just one layer of paper between the two parts, you will need to adjust for that.

### Shell dimensions

- **side thickness** is the amount of clear material covering the edged of the work.
- **back thickness** is the thickness of the bottom of the U-shaped cross section of the shell.

### Block dimensions
 - **front thickness** is the thickness of the top surface of the block, which the artwork lies against.
 - **block side thickness** is the width of the box walls that make up the sides of the block. This also governs the side of the flap that folds under the edge of the block.

### Magnet settings
- **Magnet option** has four options for controlling what accommodation will be made for magnets you'll glue to the block.
  - _3 round magnets_ puts three columns for small round magnets, with one in the middle of a short side and the others at the corners of the opposite side.
  - _4 round magnets_ puts a magnet post in each corner. This is generally overkill unless your magnets are very weak or the art is large and heavy.
  - _none_ makes no particular provision for magnets.
  - _platforms for magnet tape_ places two rectangular pillars near the short ends of the back, 

![block with 3 round magnets posts](https://github.com/users/MethylBromide/projects/3/assets/12117008/3cecd993-73a7-466a-8071-0f64a8653f23)![4 posts](https://github.com/users/MethylBromide/projects/3/assets/12117008/9d979d5c-4f1a-4134-9915-61eed6b74dc4)
![no magnet supports](https://github.com/users/MethylBromide/projects/3/assets/12117008/b4dd3c8c-59dd-4e43-a0d8-e041f731096e)![platforms for tape](https://github.com/users/MethylBromide/projects/3/assets/12117008/20bd7a89-8b02-442b-a4dc-8a5a34d0bd34)

- **magnet diameter** is the diameter for a cylindrical magnet. Enter a number at least .5mm larger than the actual magnet -- you're gluing it on anyway.
- **magnet depth** is the depth of the cup you'll set the magnet into. If you want to recess the magnet all the way, that's fine, but I like to enter a value about .75mm less than the actual magnet depth so they stick out a little from the back.

## Preparation of Artwork
The artwork to go into the holder will need to be trimmed to the size and shape needed by the frame. The script can produce a template for export to SVG format, for you to import into a vector editor (e.g. Inkscape) and print as a cutting guide. Select "Artwork template for export as SVG" in the Layout field of Customizer.

![Image](https://github.com/users/MethylBromide/projects/3/assets/12117008/7708e88e-0f74-4664-b2a4-7869e9455463)
