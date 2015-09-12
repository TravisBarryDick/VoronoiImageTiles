# VoronoiImageTiles
A fun image processing project in javascript that is marginally related to my learning theory research. The page can be found live here: http://www.cs.cmu.edu/afs/cs/user/tdick/www/VoronoiImageTiles/

## Instructions:

Since the code is written in coffeescript, you must first compile the coffeescript into javascript. In the root directory running `make build_js` will build the javascript files. If you are editing the coffeescript code, running `make continuously` will watch the .coffee source files and recompile whenever they change. Finally, `make deploy` is a convenience target that copies the compiled page to my school webspace.
