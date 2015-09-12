define ["ImageUtils", "AliasMethod", "RandUtils", "KDTree"], (iu, am, ru, kdt) ->

  # Class for storing all intermediate stages in rendering the tiled image.
  class RenderedImage
    constructor: (@src, @dist, @kdtree, @out) ->

  # Given a scalar image with non-negative entries, draw a sample of size n from
  # the normalized distribution.
  sample_points = (dist_img, n) ->
    N = dist_img.data.length
    alias_table = am.make_alias_table dist_img.data
    sample_ixs = (alias_table.sample() for i in [1..n])
    sample_pts = (dist_img.ix2c(ix) for ix in sample_ixs)
    return sample_pts

  # Creates a distribution to sample from that is obtained by computing the
  # magnitude of the image intensity gradient and mixing with the uniform
  # distribution.
  gradient_dist = (img, edge_sensitivity = 20, min_v = 0.005) ->
    gsimg = iu.rgb_to_grayscale img
    gradm = iu.img_gradm gsimg
    gradm.data = ((Math.tanh((g-123)/255*edge_sensitivity) + 1)/2 + min_v for g in gradm.data)
    gradm = iu.box_smooth gradm, 7
    return gradm

  # Given an image, a distribution, and a number of samples, render the tiled
  # image.
  render_tiled_image = (img, dist, n) ->
    # Draw n samples from the distribution and build a k-d tree on them
    samples = sample_points dist, n
    kdtree = kdt.make_kdtree(samples)
    # Compute the mean color in each Voronoi tile. (Note that it's a bit silly
    # to do this in RGB space. Should convert to XYZ before avaraging.)
    total_colors = (img.get(s[0], s[1]) for s in samples)
    counts = (1 for s in samples)
    for ix in [0...img.data.length]
      [nn_p, nn_ix, nn_d] = kdtree.nns(img.ix2c(ix))
      total_colors[nn_ix] = total_colors[nn_ix].add(img.data[ix])
      counts[nn_ix] += 1
    colors = (total_colors[i].div(counts[i]) for i in [0...n])
    # Calculate the color of each pixel in the result as the average of the
    # colors of the nearest sample points to the four corners of this pixel. By
    # averaging the corners, we get some crude aliasing effects.
    get_pixel_color = (x,y) ->
      c = new iu.RGB 0, 0, 0
      for dx in [-0.5,0.5]
        for dy in [-0.5,0.5]
          [nn_p, nn_ix, nn_d] = kdtree.nns([x+dx,y+dy])
          c = c.add colors[nn_ix]
      return c.div 4
    # Render the image using the above pixel color function
    result = new iu.Image img.width, img.height
    for ix in [0...result.data.length]
      result.data[ix] = get_pixel_color(img.ix2c(ix)...)
    # Return the result along with the intermediate steps
    return new RenderedImage img, dist, kdtree, result

  return {
    RenderedImage: RenderedImage
    sample_points: sample_points
    gradient_dist: gradient_dist
    render_tiled_image: render_tiled_image
  }
