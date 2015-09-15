# Voronoi Image Tiles

A fun image processing project in javascript that is marginally related some of
the learning theory projects that I work on. To try it for yourself, go here:
http://imagetiles.travisdick.net. Instructions are given below.

## Examples

### The Hubble 25-year Anniversary Photo
![](examples/hubble-25-year/original.jpg)
becomes
![](examples/hubble-25-year/result.png)

### A shot of the mountains in Invermere, BC, Canada
![](examples/invermere-mountains/original.jpg)
becomes
![](examples/invermere-mountains/result.png)

## How to Use

You can apply the tool to a new image by going to
http://imagetiles.travisdick.net (or by cloning the repository and working in a
local copy) and selecting your image file. There are a couple of additional
options for tweaking the output that can be controlled below the file selection
button. All three sliders (labeled "detail level", "edge sensitivity", and
"uniform bias") control how much detail the resulting image has, and what
regions of the image have detail. If you create an image that you would like to
save, right clicking on the output will allow you to save it or open it in a new
tab.

For those of you worried about privacy, all the processing is done in your web
browser and the images you apply it to never leave your computer. This approach
saves us both the bandwidth necessary to send the images, and it saves me the
computational power required to process your images.

## Brief Description

The output is produced in several stages, some of which are similar to the
constructions used in some of the learning theory projects that I am working on.

First, a magic function is applied to the image to identify regions of the image
that are interesting. The "map of interestingness" is represented as a weight
image of the same dimensions as the original image, with high weights
corresponding to highly interesting pixels. At the moment, this magic function
computes the gradient of intensity at each pixel and passes the magnitude of the
gradient through a sigmoidal function. This is a cheap and lousy edge detection
algorithm, but it seems to produce reasonably nice output.

Next, that weight map is normalized to create a probability distribution over
the pixel coordinates and a sample of points is drawn from that distribution.
Each one of these points will become one of the tiles in the final image, so
drawing more points corresponds to more detail. Also, since we will see more
points in places where the "interest map" had high weights, this will give more
detail to the interesting portions of the image.

Finally, the output is generated by partitioning the set of pixels into tiles
and coloring each tile with the average color of the underlying pixels in the
original image. To convert the sampled points into the tiling, we make one tile
for each point sampled in the previous step. The tile created by one sample
contains all the pixels that are closer to that sample than any other. This way
of partitioning the space is called a Voronoi partition.

I wrote this code because I am curious about how the Voronoi partitions behave
when they are generated from samples randomly drawn from non-trivial
distributions. I actually care about high-dimensional instances of this problem,
but the 2 dimensional output is nice to look at.

## Build Instructions:

Since the code is written in coffeescript, you must first compile the
coffeescript into javascript. In the root directory running `make build_js` will
build the javascript files. If you are editing the coffeescript code, running
`make continuously` will watch the .coffee source files and recompile whenever
they change. Finally, `make deploy` is a convenience target that copies the
compiled page to my school webspace.
