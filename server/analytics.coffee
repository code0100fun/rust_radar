Mixpanel = require('mixpanel')

class Analytics
  @track: (event, params) =>
    if(process.env.mixpanel_key? && !@mixpanel?)
      @mixpanel = Mixpanel.init(process.env.mixpanel_key)
    @mixpanel.track(event, params) if @mixpanel?

module.exports = Analytics
