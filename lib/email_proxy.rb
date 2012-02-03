require 'email_proxy/version'
require 'net/smtp'
require 'mini-smtp-server'

module EmailProxy

  extend self

  class ProxySmtpServer < MiniSmtpServer
    def new_message_event(message)
      EmailProxy.before_filters.each do |filter|
        return unless filter.call(message)
      end

      Net::SMTP.start(EmailProxy.destination_host,
                      EmailProxy.destination_port) do |smtp|
        smtp.send_message(message[:data], message[:from], message[:to])
        smtp.finish
      end

      EmailProxy.after_filters.each do |filter|
        filter.call(message)
      end
    end
  end

  class << self
    attr_accessor :host, :port, :destination_host, :destination_port
    attr_reader :before_filters, :after_filters
  end

  def start(options)
    @host = options.fetch(:host) {
      raise ArgumentError, "host is required"
    }
    @port = options.fetch(:port) {
      raise ArgumentError, "port is required"
    }
    @destination_host = options.fetch(:destination_host) {
      raise ArgumentError, "desination_host is required"
    }
    @destination_port = options.fetch(:destination_port) {
      raise ArgumentError, "desination_port is required"
    }

    @before_filters = []
    @after_filters  = []

    @server = ProxySmtpServer.new(port, host)
    @server.start
  end

  def stop
    @server.shutdown
    while(@server.connections > 0)
      sleep 0.01
    end
    @server.stop
    @server.join
  end

  def before_filter(&block)
    before_filters << block
  end

  def after_filter(&block)
    after_filters << block
  end

end
