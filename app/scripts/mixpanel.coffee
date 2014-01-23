((e, b) ->
  unless b.__SV
    a = undefined
    f = undefined
    i = undefined
    g = undefined
    window.mixpanel = b
    a = e.createElement("script")
    a.type = "text/javascript"
    a.async = not 0
    a.src = ((if "https:" is e.location.protocol then "https:" else "http:")) + "//cdn.mxpnl.com/libs/mixpanel-2.2.min.js"
    f = e.getElementsByTagName("script")[0]
    f.parentNode.insertBefore a, f
    b._i = []
    b.init = (a, e, d) ->
      f = (b, h) ->
        a = h.split(".")
        2 is a.length and (b = b[a[0]]
        h = a[1]
        )
        b[h] = ->
          b.push [h].concat(Array::slice.call(arguments, 0))
      c = b
      (if "undefined" isnt typeof d then c = b[d] = [] else d = "mixpanel")
      c.people = c.people or []
      c.toString = (b) ->
        a = "mixpanel"
        "mixpanel" isnt d and (a += "." + d)
        b or (a += " (stub)")
        a

      c.people.toString = ->
        c.toString(1) + ".people (stub)"

      i = "disable track track_pageview track_links track_forms register register_once alias unregister identify name_tag set_config people.set people.set_once people.increment people.append people.track_charge people.clear_charges people.delete_user".split(" ")
      g = 0
      while g < i.length
        f c, i[g]
        g++
      b._i.push [a, e, d]

    b.__SV = 1.2
) document, window.mixpanel or []
