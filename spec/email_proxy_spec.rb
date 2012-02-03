require 'spec_helper'

describe EmailProxy do

  def send_email(options = {})
    options = {
      :to => 'to@example.com',
      :from => 'from@example.com',
    }.merge(options)

    options[:message] ||= <<-EOD.unindent
      From: Your Name <your@mail.address>
      To: Destination Address <someone@example.com>
      Subject: test message
      Date: Sat, 23 Jun 2001 16:26:43 +0900
      Message-Id: <unique.message.id.string@example.com>

      This is a test message.
    EOD

    Net::SMTP.start('127.0.0.1', 2525) do |smtp|
      smtp.send_message(options[:message], options[:from], options[:to])
      smtp.finish
      sleep 0.01
    end
  end

  def messages
    message_observer.messages
  end

  let(:rumbster) { Rumbster.new(2526) }
  let(:message_observer) { MailMessageObserver.new }
  let(:valid_options) {
    {
      :host => '127.0.0.1',
      :port => 2525,
      :destination_host => '127.0.0.1',
      :destination_port => 2526
    }
  }

  before do
    rumbster.add_observer message_observer
    rumbster.start

    EmailProxy.start(valid_options)
  end

  after do
    rumbster.stop
    EmailProxy.stop
  end

  it 'delivers messages to the destination server' do
    expect {
      send_email
    }.to change { messages.size }.by(1)
  end

  it 'raises an error when host is missing' do
    expect {
      EmailProxy.start(valid_options.except(:host))
    }.to raise_error ArgumentError
  end

  it 'raises an error when port is missing' do
    expect {
      EmailProxy.start(valid_options.except(:port))
    }.to raise_error ArgumentError
  end

  it 'raises an error when destination host is missing' do
    expect {
      EmailProxy.start(valid_options.except(:destination_host))
    }.to raise_error ArgumentError

  end

  it 'raises an error when destination host is missing' do
    expect {
      EmailProxy.start(valid_options.except(:destination_port))
    }.to raise_error ArgumentError
  end

  it 'does not deliver messages when a before filter returns false' do
    bounced = 'bounce@example.org'

    EmailProxy.before_filter { |message|
      message[:to] == bounced
    }

    expect {
      send_email(:to => bounced)
    }.not_to change { messages.size }
  end

  it 'delivers a message when a before filter returns true' do
    EmailProxy.before_filter { |message|
      true
    }

    expect {
      send_email
    }.to change { messages.size }.by(1)
  end

  it 'runs multiple before filters' do
    count = 0
    EmailProxy.before_filter {
      count += 1
    }

    EmailProxy.before_filter {
      count += 1
    }

    send_email

    count.should == 2
  end

  it 'executes before filters in the order added' do
    count = 0
    EmailProxy.before_filter {
      false
    }

    EmailProxy.before_filter {
      count = 1
    }

    send_email

    count.should == 0
  end

  it 'runs multiple after filters' do
    count = 0
    EmailProxy.after_filter {
      count += 1
    }

    EmailProxy.after_filter {
      count += 1
    }

    send_email

    count.should == 2
  end

end
