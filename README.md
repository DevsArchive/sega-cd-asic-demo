# Sega CD ASIC Graphics Demo
This is a basic demonstration of the ASIC graphics chip found on the Sega CD. In 2M/2M mode, it can be used to scale and rotate an image, alongside other fun kinds of manipulation.

This demo draws a scaled repeating 256x256 pixel stamp map with 32x32 pixel stamps.

## Technical details
The input image consists of a tilemap made up of metatiles (called stamps). Stamps are made up of 8x8 Mega Drive tiles, arranged vertically (just like Mega Drive sprites). They can either be 16x16 or 32x32 pixels in size. Stamp data is to be stored at the beginning of Word RAM, and the first stamp MUST be blank.

The stamp map can either be 16x16 16x16 stamps or 8x8 32x32 stamps in size (256x256 pixels), or 256x256 16x16 stamps or 128x128 32x32 stamps in size (4096x4096 pixels).

Stamp IDs in the stamp map are just the address of the stamp you want to use, divided by $80, and fit within 11 bits. With 32x32 stamps, the last 2 bits are masked out (making them only multiples of 4). The top 3 bits are used for flipping and rotation. Bit 15 controls the horizontal flip of a stamp, and bits 13 and 14 control the rotation (00 = 0 degrees, 01 = 90 degrees, 10 = 180 degrees, 11 = 270 degrees).

The image buffer is the area of Word RAM that will hold the final rendered image that can be transferred into VRAM. The size of the image buffer can be set by the user.

The trace table dictates how the final image is drawn. The number of entries it holds is the equal to the vertical resolution of the image buffer. For each entry, it holds an X and Y starting position, both 13.3 fixed point, and delta X and Y values, both signed 5.11 fixed point.

How the image is rendered is that it will go down the image buffer, row by row, and for each row's trace table entry, it will go to the calculated starting X and Y position in the input image, and continuously add the delta values to the input image position until all the pixels in the image buffer row are plotted.

The rendering begins when the pointer to the trace table is set. The status of the rendering can be checked by checking bit 15 in the stamp size register.

The Sub CPU must have access to Word RAM in order for the rendering to operate.

## Registers
* $FF8058 - Stamp size
    * Bit 15 = GRON, 0 if ASIC is inactive, 1 if it's busy rendering.
    * Bit 2 = SMS, Stamp map size. 0 for 256x256 pixel map, 1 for 4096x4096 pixel map.
    * Bit 1 = STS, Stamp size. 0 for 16x16 pixel stamps, 1 for 32x32 pixel stamps.
    * Bit 0 = RPT, 0 for no repeating stamp map, 1 for repeating stamp map when out of bounds.
* $FF805A - Stamp map base address
    * Holds the stamp map base address, relative to the start of Word RAM, divided by 4.
    * 256x256 map, 16x16 stamps - Bits 7-15 are used.
    * 256x256 map, 32x32 stamps - Bits 5-15 are used.
    * 4096x4096 map, 16x16 stamps - Bits 13-15 are used.
    * 4096x4096 map, 32x32 stamps - Only bit 15 is used.
* $FF805C - Image buffer vertical tile size
    * Set this to the height of the image buffer in pixels, divided by 8, minus 1.
* $FF805E - Image buffer start address
    * Holds the image buffer start address, relative to the start of Word RAM, divided by 4. Bits 3-15 are used.
* $FF8060 - Image buffer offset
    * Offsets the initial drawing position in the image buffer.
    * Bits 0-2 hold the horizontal offset.
    * Bits 3-5 hold the vertical offset.
* $FF8062 - Image buffer horizontal pixel size
    * Set this to the width of the image buffer in pixels (9 bits).
* $FF8064 - Image buffer vertical pixel size
    * Set this to the height of the image buffer in pixels (8 bits).
    * This is decremented to 0 during the ASIC's operation, so it must be reset every time the ASIC should start rendering.
* $FF8066 - Trace table base address
    * Holds the trace table base address, relative to the start of Word RAM, divided by 4. Bits 1-15 are used.
    * Setting this will start the rendering process.