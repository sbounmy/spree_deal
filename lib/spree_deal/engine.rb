module SpreeDeal
  class Engine < Rails::Engine
    engine_name 'spree_deal'

    config.autoload_paths += %W(#{config.root}/lib #{config.root}/app/jobs)

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../../app/**/*_decorator*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
      StateMachine::Machine.ignore_method_conflicts = true
    end

    config.to_prepare &method(:activate).to_proc
  end
end
