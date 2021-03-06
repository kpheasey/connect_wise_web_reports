module ConnectWiseWebReports

  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  class Configuration
    attr_accessor :host, :company_id, :integrator_id, :integrator_password, :version,
                  :proxy_host, :proxy_port, :proxy_user, :proxy_pass

    def initialize
      @version = 'v4_6_release'
    end

    def set(options = {})
      options.each { |k, v| self.send("#{k.to_s}=", v) }
    end

  end

  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = self.name
      end
    end
  end

end