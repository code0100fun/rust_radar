(($) ->
  $.fn.equalHeights = ->
    $el = $(this)
    $master = $el.select('.equal-height-master')
    equalize = ->
      maxHeight = 0
      if $master?
        maxHeight = $master.height()
      else
        $el.each ->
          height = $(this).innerHeight()
          maxHeight = height  if height > maxHeight
      $el.css "height", maxHeight
    equalize()
    $(window).resize ->
      equalize()
)(jQuery)
