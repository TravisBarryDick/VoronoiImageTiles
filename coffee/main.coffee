require.config {
  paths:
    "domReady": ["https://cdnjs.cloudflare.com/ajax/libs/require-domReady/2.0.1/domReady.min"
                 "../lib/domReady"]
}

require ["ImageUtils"
         "VoronoiImageTiles"
         "domReady"], \
         (iu, vit, domReady) ->

  # Sets the sourceimage element's src attribute to a data url obtained by
  # reading the file selected by the fileselector element.
  load_selected_image = ->
    fr = new FileReader()
    fr.onload = ->
      document.getElementById("sourceimage").src = fr.result
    fr.readAsDataURL(document.getElementById("fileselector").files[0])

  get_clamping_scale = (w, h, mw=800, mh=600) ->
    wscale = mw / w
    hscale = mh / h
    return Math.min(wscale, hscale, 1.0)

  # Renders the tiled image using the content of the sourceimage element.
  # Updates other dom elements.
  make_tiled_image = ->
    simg_element = document.getElementById("sourceimage")
    dimg_element = document.getElementById("distimage")
    rimg_element = document.getElementById("resultimage")
    kdtreegraph_element = document.getElementById("kdtreegraph")
    numsamples = Math.floor(document.getElementById("numsamples").value)
    edge_sensitivity = Number(document.getElementById("edgesensitivity").value)
    uniform_bias = Number(document.getElementById("uniformbias").value)

    # render the tiled image
    scale = get_clamping_scale simg_element.naturalWidth, simg_element.naturalHeight
    simg = iu.convert_image_element simg_element, scale
    console.log "simg.width = #{simg.width}, simg.height=#{simg.height}"
    dist = vit.gradient_dist simg, edge_sensitivity, uniform_bias
    result = vit.render_tiled_image simg, dist, numsamples

    # show the distribution
    dimg_element.src = iu.image_to_dataurl iu.grayscale_to_rgb iu.rescale_to_255 result.dist

    # Draw the k-d tree
    kdtreegraph.width = result.out.width
    kdtreegraph.height = result.out.height
    result.kdtree.draw_on_canvas(kdtreegraph_element)

    # Draw the tiled image
    rimg_element.src = iu.image_to_dataurl result.out



  domReady ->
    fs = document.getElementById("fileselector")
    fs.onchange = (e) -> load_selected_image()
    document.getElementById("sourceimage").onload = -> setTimeout(make_tiled_image, 0)
    document.getElementById("run_button").onclick = -> setTimeout(make_tiled_image, 0)
