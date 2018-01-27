# tartan-wallpapers
Collection of tartan wallpapers in beautiful high resolution.

Thread-count data comes from three sources:

    Smith's book of tartans
    The Scottish Registry of Tartans
    individuals (including myself)

To build the images, you need Perl and ImageMagick. Mac and Linux users already
have these. Windows users will have to install them, or download the pre-built images.

The tartan.pl script generates one image from one data file. You can script it to
loop over all the data files. The resulting collection is about 1.2 GB.

If you find a problem with a tartan, or want me to include another one, please open
a new issue in this project. For a new tartan, I will need

    its name
    color pallette as RGB hex (e.g., "red = df2020") [optional; I can use a default pallette]
    thread counts
    symmetric or asymmetric?
    number in the Scottish Registry of Tartans [optional]

