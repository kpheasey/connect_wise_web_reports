module ConnectWiseWebReports

  class Report

    attr_accessor :options, :name, :records

    # Generate the Web Report request url.
    #
    # @param name [String]
    # @param options [Hash]
    # @return [String]
    def self.url(name, options = {})
      # Report
      params = "r=#{name}"

      # API credentials
      params += "&c=#{CGI.escape options[:company_id].to_s}"
      params += "&u=#{CGI.escape options[:integrator_id].to_s}"
      params += "&p=#{CGI.escape options[:integrator_password].to_s}"

      #order
      params += "&o=#{CGI.escape options[:order_by].to_s}" unless options[:order_by].nil?

      # pagination
      params += "&l=#{CGI.escape options[:limit].to_s}" unless options[:limit].nil?
      params += "&s=#{CGI.escape options[:skip].to_s}" unless options[:skip].nil?

      # timeout
      params += "&t=#{CGI.escape options[:timeout].to_s}" unless options[:timeout].nil?

      # fields
      unless options[:fields].nil? || options[:fields].empty?
        params += "&f=#{options[:fields].map { |f| CGI.escape f }.join('&f=')}"
      end

      # conditions
      params += "&q=#{CGI.escape options[:conditions]}" unless options[:conditions].blank?

      url = "https://#{options[:host]}/#{options[:version]}/webreport/?#{params}"

      ConnectWiseWebReports.logger.info url

      return url
    end

    def initialize(name, options = {})
      @name = name
      @options = ConnectWiseWebReports::DEFAULT_OPTIONS.merge(options)
      @records = fetch
    end

    # @return [Array(Hash)]
    def fetch
      begin
        response = ConnectWiseWebReports.agent(options).get(url)
      rescue StandardError => e
        raise ConnectionError.new(e.message)
      end

      doc = Nokogiri::XML(response.content)

      # raise errors if we got them
      unless doc.xpath('//error/message').empty?
        raise ConnectionError.new(doc.xpath('//error/message').first.children.first.text)
      end

      self.parse_records doc.xpath('//results/row')

      return self.records
    end

    def url
      Report.url(self.name, self.options)
    end

    def parse_records(rows)
      self.records = []

      rows.each do |row|
        record = Hash.from_xml(row.to_s)['row']
        record.delete 'result_number'
        self.records << record
      end
    end


    ### Pagination ###

    def page
      if self.options[:limit].nil?
        return 1
      else
        self.options[:skip] = 0 if self.options[:skip].nil?
        return (self.options[:skip] / self.options[:limit]) + 1
      end
    end

    def next_page?
      if self.options[:limit].nil? || self.options[:limit].zero? || self.records.count < self.options[:limit]
        return false
      else
        return true
      end
    end

    def next_page
      self.options[:skip] = 0 if self.options[:skip].nil?
      self.options[:skip] += self.options[:limit]

      return self.fetch
    end

    def previous_page?
      self.page > 1
    end

    def previous_page
      self.options[:skip] -= self.options[:limit]
      self.options[:skip] = [0, self.options[:skip]].max # ensure we don't skip negative

      return self.fetch
    end

  end

end