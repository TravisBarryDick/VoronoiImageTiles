# The js/ folder is not tracked by git since it is the compiler output. In order
# to track the library files,
require.config {
  paths:
    "domReady": ["https://cdnjs.cloudflare.com/ajax/libs/require-domReady/2.0.1/domReady.min"
                 "../lib/domReady"]
}

require ["RandUtils", "KDTree", "AliasMethod", "VoronoiImageTiles", "domReady"],\
        (ru, kdt, AliasTable, vit, domReady) ->
  window.ru = ru
  window.kdt = kdt
  window.AliasTable = AliasTable
  window.vit = vit

  load_image = ->
    fr = new FileReader()
    fr.onload = ->
      document.getElementById("sourceimage").src = fr.result
    fr.readAsDataURL(document.getElementById("fileselector").files[0])

  get_clamped_size = (w,h, mw=800, mh=600) ->
    w_scale = mw / w
    h_scale = mh / h
    scale = Math.min(w_scale, h_scale)
    if scale >= 1
      return [w,h]
    else
      return [w*scale, h*scale]

  get_image_data = (img) ->
    cvs = document.createElement("canvas")
    [w, h] = get_clamped_size(img.naturalWidth, img.naturalHeight)
    cvs.width = w
    cvs.height = h
    ctx = cvs.getContext("2d")
    ctx.drawImage(img, 0, 0, w, h)
    return vit.imagedata_to_image ctx.getImageData(0, 0, w, h)

  domReady ->
    fs = document.getElementById("fileselector")
    fs.onchange = (e) ->
      load_image()

    make_image = =>
      source_img = get_image_data(document.getElementById("sourceimage"))
      num_samples = document.getElementById("numsamples").value
      samples = vit.gradient_sample source_img, num_samples
      tree = kdt.make_kdtree(samples)
      result_img = vit.render_tiled_image(source_img, samples)
      document.getElementById("resultimage").src = vit.image_to_dataurl(result_img)

      kdtreegraph = document.getElementById("kdtreegraph")
      kdtreegraph.width = source_img.width
      kdtreegraph.height = source_img.height
      tree.draw_on_canvas(kdtreegraph)

    document.getElementById("sourceimage").onload = -> setTimeout(make_image, 0)
    document.getElementById("run_button").onclick = -> setTimeout(make_image, 0)
