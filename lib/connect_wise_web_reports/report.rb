module ConnectWiseWebReports

  class Report

    attr_accessor :options, :name, :records

    def initialize(name, options = {})
      @name = name
      @options = ConnectWiseWebReports::DEFAULT_OPTIONS.merge(options)
      @records = fetch
    end

    # @return [Array(Hash)]
    def fetch
      response = ConnectWiseWebReports.agent(options).get(url)
      doc = Nokogiri::XML(response.content)

      # raise errors if we got them
      unless doc.xpath('//error/message').empty?
        raise doc.xpath('//error/message').first.children.first.text
      end

      self.parse_records doc.xpath('//results/row')

      return self.records
    end

    # Generate the Web Report request url.
    #
    # @return [String]
    def url
      url = "https://#{self.options[:host]}/#{self.options[:version]}/webreport/"

      # Report
      url += "?r=#{self.name}"

      # API credentials
      url += "&c=#{self.options[:company_id].to_s}"
      url += "&u=#{self.options[:integrator_id].to_s}"
      url += "&p=#{self.options[:integrator_password].to_s}"

      #order
      url += "&o=#{self.options[:order_by].to_s}" unless self.options[:order_by].nil?

      # pagination
      url += "&l=#{self.options[:limit].to_s}" unless self.options[:limit].nil?
      url += "&s=#{self.options[:skip].to_s}" unless self.options[:skip].nil?

      # timeout
      url += "&t=#{self.options[:timeout].to_s}" unless self.options[:timeout].nil?

      # fields
      url += "&f=#{self.options[:fields].join('&f=')}" unless self.options[:fields].nil? || self.options[:fields].empty?

      # conditions
      url += "&q=#{self.options[:conditions]}" unless self.options[:conditions].blank?

      return URI.escape(url)
    end

    def parse_records(rows)
      self.records = []

      rows.each do |row|
        record = Hash.from_xml(row.to_s)['row'].to_snake_keys.with_indifferent_access
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