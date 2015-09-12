define ["AliasMethod", "RandUtils", "KDTree"], (AliasTable, ru, kdt) ->
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

  imagedata_to_image = (imgdata) ->
    [w, h] = [imgdata.width, imgdata.height]
    result = new Image w, h
    for x in [0...w]
      for y in [0...h]
        red_ix = 4*x + 4*y*w
        r = imgdata.data[red_ix]
        g = imgdata.data[red_ix+1]
        b = imgdata.data[red_ix+2]
        result.set x, y, new RGB(r,g,b)
    return result

  image_to_dataurl = (img) ->
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
    return cvs.toDataURL("image/png")

  to_grayscale = (img) ->
    gray = new Image img.width, img.height
    gray.data = (c.to_gray() for c in img.data)
    return gray

  img_gradx = (gsimg) ->
    gradx = new Image gsimg.width, gsimg.height
    for x in [1...gradx.width]
      for y in [0...gradx.height]
        gradx.set(x,y, gsimg.get(x,y) - gsimg.get(x-1,y))
    return gradx

  img_grady = (gsimg) ->
    grady = new Image gsimg.width, gsimg.height
    for x in [0...grady.width]
      for y in [1...grady.height]
        grady.set(x,y, gsimg.get(x,y) - gsimg.get(x,y-1))
    return grady

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

  class RGB
    constructor: (@r, @g, @b) ->
    scale: (s) -> new RGB @r*s, @g*s, @b*s
    div: (s) -> @scale(1/s)
    add: (o) -> new RGB @r + o.r, @g + o.g, @b + o.b
    sub: (o) -> @add(o.scale(-1))
    to_gray: -> 0.21*@r + 0.72*@g + 0.07*@b

  sample_points = (weight_img, n) ->
    N = weight_img.data.length
    alias_table = new AliasTable weight_img.data
    sample_ixs = (alias_table.sample() for i in [1..n])
    sample_pts = (weight_img.ix2c(ix) for ix in sample_ixs)
    return sample_pts

  gradient_sample = (img, n) ->
    gsimg = to_grayscale img
    gradm = img_gradm gsimg
    max_gm = 0
    for g in gradm.data
      max_gm = Math.max(max_gm, g)
    gradm.data = (g + (max_gm / 10) for g in gradm.data)
    return sample_points gradm, n

  render_tiled_image = (img, samples) ->
    n = samples.length
    kdtree = kdt.make_kdtree(samples)
    total_colors = (new RGB 0,0,0 for s in samples)
    counts = (0 for s in samples)
    for ix in [0...img.data.length]
      [nn, nn_ix, d] = kdtree.nns(img.ix2c(ix))
      total_colors[nn_ix] = total_colors[nn_ix].add(img.data[ix])
      counts[nn_ix] += 1
    colors = (total_colors[i].div(counts[i]) for i in [0...n])

    get_pixel_color = (x,y) ->
      c = new RGB 0, 0, 0
      for dx in [-0.5,0.5]
        for dy in [-0.5,0.5]
          [nn_p, nn_ix, nn_d] = kdtree.nns([x+dx,y+dy])
          c = c.add colors[nn_ix]
      return c.div 4

    result = new Image img.width, img.height
    for ix in [0...result.data.length]
      result.data[ix] = get_pixel_color(img.ix2c(ix)...)
    return result

  return {
    Image: Image
    RGB: RGB
    imagedata_to_image: imagedata_to_image
    image_to_dataurl: image_to_dataurl
    sample_points: sample_points
    gradient_sample: gradient_sample
    render_tiled_image: render_tiled_image
  }
