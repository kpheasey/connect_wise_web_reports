require 'mechanize'
require 'nokogiri'

require 'connect_wise_web_reports/version'
require 'connect_wise_web_reports/configuration'
require 'connect_wise_web_reports/error'
require 'connect_wise_web_reports/report'

module ConnectWiseWebReports
  DEFAULT_OPTIONS = {
    conditions: nil,
    fields: [],
    limit: 100,
    order_by: nil,
    skip: nil,
    timeout: 5,

    # authentication
    host: ConnectWiseWebReports.configuration.host,
    company_id: ConnectWiseWebReports.configuration.company_id,
    integrator_id: ConnectWiseWebReports.configuration.integrator_id,
    integrator_password: ConnectWiseWebReports.configuration.integrator_password,
    version: ConnectWiseWebReports.configuration.version,
    proxy_host: ConnectWiseWebReports.configuration.proxy_host,
    proxy_port: ConnectWiseWebReports.configuration.proxy_port,
    proxy_user: ConnectWiseWebReports.configuration.proxy_user,
    proxy_pass: ConnectWiseWebReports.configuration.proxy_pass
  }.freeze

  # Create a new Mechanize agent.
  #
  # @return [Mechanize]
  def self.agent(options)
    Mechanize.new do |agent|
      if options[:proxy_host]
        agent.set_proxy(options[:proxy_host], options[:proxy_port],
                        options[:proxy_user], options[:proxy_pass])
      end

      agent.read_timeout = options[:timeout]
      agent.keep_alive = false
      agent.idle_timeout = 5
    end
  end

  def self.info(options)
    options = DEFAULT_OPTIONS.merge(options)
    url = "https://#{options[:host]}/login/companyinfo/#{options[:company_id]}"
    response = agent(options).get(url)

    return {} if response.content == 'null'

    JSON.parse(response.content)
  rescue StandardError => e
    raise ConnectionError.new(e.message)
  end

end
