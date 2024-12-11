require "bundler/setup"
require "rails"
require "action_cable/engine"
require "active_record/railtie"
require "solid_cable"

class App < Rails::Application
  config.load_defaults 8.0
  config.enable_reloading = true
  config.eager_load = false

  config.logger = ActiveSupport::TaggedLogging.logger(STDOUT)

  # The bug does not rely on this config setting - but it helps it manifest:
  config.reload_classes_only_on_change = false
end

Rails.application.initialize!

module ShutdownPatch
  def shutdown
    # help the race condition manifest:
    Thread.pass
    super
  end

  prepend_features ActionCable::SubscriptionAdapter::SolidCable::Listener
end

Rails.application.reloader.wrap do
  ActionCable.server.pubsub
end
