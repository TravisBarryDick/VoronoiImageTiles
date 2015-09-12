define ->

#-----------------#
# Basic Datatypes #
#-----------------#

  # Class for represnting image data
  class Image
    constructor: (@width, @height, @data = (0 for i in [1..@width * @height])) ->
    # Converts an (x,y) pair into an index into the data array
    c2ix: (x,y) -> y + x*@height
    # Convers an index in the data array into a coordinate pair
    ix2c: (ix) -> [ix // @height, ix % @height]
    # Gets the pixel data at the given coordinates
    get: (x,y) -> @data[@c2ix(x,y)]
    # Sets the pixel data at the given coordinates
    set: (x,y,c) -> @data[@c2ix(x,y)] = c

  # Class for representing RGB colors
  class RGB
    constructor: (@r, @g, @b) ->
    scale: (s) -> new RGB @r*s, @g*s, @b*s
    div: (s) -> @scale(1/s)
    add: (o) -> new RGB @r + o.r, @g + o.g, @b + o.b
    sub: (o) -> @add(o.scale(-1))
    to_gray: -> 0.21*@r + 0.72*@g + 0.07*@b

#------------------------------#
# Image Manipulation Functions #
#------------------------------#

  # Takes an RGB image and returns a new scalar image in grayscale
  rgb_to_grayscale = (img) ->
    gray = new Image img.width, img.height
    gray.data = (c.to_gray() for c in img.data)
    return gray

  # Takes a grayscale scalar image and returns an RGB image
  grayscale_to_rgb = (gsimg) ->
    rgb = new Image gsimg.width, gsimg.height
    rgb.data = (new RGB g, g, g for g in gsimg.data)
    return rgb

  # Given a grayscale image, rescales everything so that the maximum value is
  # 255.
  rescale_to_255 = (gsimg) ->
    max_g = 0
    for g in gsimg.data
      max_g = Math.max(max_g, g)
    scale = 255 / max_g
    result = new Image gsimg.width, gsimg.height
    result.data = (g * scale for g in gsimg.data)
    return result

  # Convolves a grayscale image with the given kernel.
  img_filter = (gsimg, kernel) ->
    [w,h] = [kernel.length, kernel[0].length]
    result = new Image gsimg.width, gsimg.height
    for x in [0...gsimg.width]
      for y in [0...gsimg.height]
        g = 0.0
        for dx in [-(w // 2)..(w // 2)]
          for dy in [-(h // 2)..(h // 2)]
            if 0 <= x+dx < gsimg.width and 0 <= y+dy < gsimg.height
              g += kernel[dx+(w // 2)][dy+(h // 2)] * gsimg.get(x+dx, y+dy)
        result.set(x,y,g)
    return result

  box_smooth = (gsimg, size) ->
    s = 1.0 / (size*size)
    kernel = ((s for i in [1..size]) for j in [1..size])
    return img_filter gsimg, kernel

  # Takes a grayscale image and returns the image intensity derivative with
  # respect to the x coordinate
  img_gradx = (gsimg) ->
    gradx = new Image gsimg.width, gsimg.height
    for x in [1...gradx.width]
      for y in [0...gradx.height]
        gradx.set(x,y, gsimg.get(x,y) - gsimg.get(x-1,y))
    return gradx

  # Takes a grayscale image and returns the image intensity derivative with
  # respect to the y coordinate
  img_grady = (gsimg) ->
    grady = new Image gsimg.width, gsimg.height
    for x in [0...grady.width]
      for y in [1...grady.height]
        grady.set(x,y, gsimg.get(x,y) - gsimg.get(x,y-1))
    return grady

  # Takes a grayscale image and returns the magnitude of the image intensity
  # gradient (as a function of (x,y) coordinates).
  img_gradm = (gsimg) ->
    gradx = img_gradx gsimg
    grady = img_grady gsimg
    gradm = new Image gsimg.width, gsimg.height
    for x in [0...gradm.width]
      for y in [0...gradm.height]
        gx = gradx.get(x,y)
        gy = grady.get(x,y)
        m = Math.sqrt(gx*gx + gy*gy)
        gradm.set(x,y,m)
    return gradm

#-------------------------------#
# Interacting with DOM elements #
#-------------------------------#

  # takes an HTML image element and returns an instance of the above image class
  convert_image_element = (imgelement, scale = 1.0) ->
    [w, h] = [Math.floor(imgelement.naturalWidth*scale), Math.floor(imgelement.naturalHeight*scale)]
    c = document.createElement("canvas")
    [c.width, c.height] = [w, h]
    ctx = c.getContext("2d")
    ctx.drawImage(imgelement,0,0,w,h)
    imgdata = ctx.getImageData(0,0,w,h)
    result = new Image w, h
    for x in [0...w]
      for y in [0...h]
        red_ix = 4*x + 4*y*w
        r = imgdata.data[red_ix]
        g = imgdata.data[red_ix+1]
        b = imgdata.data[red_ix+2]
        result.set x, y, new RGB(r,g,b)
    return result

  # takes an instance of the image class and returns a data URL in the given format
  image_to_dataurl = (img, format="image/png") ->
    cvs = document.createElement("canvas")
    [cvs.width, cvs.height] = [img.width, img.height]
    ctx = cvs.getContext("2d")
    imgdata = ctx.getImageData(0, 0, cvs.width, cvs.height)
    for x in [0...cvs.width]
      for y in [0...cvs.height]
        red_ix = 4*x + 4*y*cvs.width
        c = img.get(x,y)
        imgdata.data[red_ix] = c.r
        imgdata.data[red_ix+1] = c.g
        imgdata.data[red_ix+2] = c.b
        imgdata.data[red_ix+3] = 255
    ctx.putImageData(imgdata,0,0)
    return cvs.toDataURL(format)

#----------------#
# Module Exports #
#----------------#

  return {
    Image: Image
    RGB: RGB
    rgb_to_grayscale: rgb_to_grayscale
    grayscale_to_rgb: grayscale_to_rgb
    rescale_to_255: rescale_to_255
    img_filter: img_filter
    box_smooth: box_smooth
    img_gradx: img_gradx
    img_grady: img_grady
    img_gradm: img_gradm
    convert_image_element: convert_image_element
    image_to_dataurl: image_to_dataurl
  }
