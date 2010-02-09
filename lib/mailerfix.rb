require "openssl"
require "net/smtp"

Net::SMTP.class_eval do
  private
  def do_start(helodomain, user, secret, authtype)
    raise IOError, 'SMTP session already started' if @started
    check_auth_args user, secret, authtype if user or secret

    sock = timeout(@open_timeout) { TCPSocket.open(@address, @port) }
    @socket = Net::InternetMessageIO.new(sock)
    @socket.read_timeout = 60 #@read_timeout
    #@socket.debug_output = STDERR #@debug_output

    check_response(critical { recv_response() })
    do_helo(helodomain)

    if starttls
      raise 'openssl library not installed' unless defined?(OpenSSL)
      ssl = OpenSSL::SSL::SSLSocket.new(sock)
      ssl.sync_close = true
      ssl.connect
      @socket = Net::InternetMessageIO.new(ssl)
      @socket.read_timeout = 60 #@read_timeout
      #@socket.debug_output = STDERR #@debug_output
      do_helo(helodomain)
    end

    authenticate user, secret, authtype if user
    @started = true
  ensure
    unless @started
      # authentication failed, cancel connection.
      @socket.close if not @started and @socket and not @socket.closed?
      @socket = nil
    end
  end

  def do_helo(helodomain)
     begin
      if @esmtp
        ehlo helodomain
      else
        helo helodomain
      end
    rescue Net::ProtocolError
      if @esmtp
        @esmtp = false
        @error_occured = false
        retry
      end
      raise
    end
  end

  def starttls
    getok('STARTTLS') rescue return false
    return true
  end

  def quit
    begin
      getok('QUIT')
    rescue EOFError, OpenSSL::SSL::SSLError
    end
  end
end


module ActionMailer
 class Base
     
      class << self
      # or an array of mail objects, like:
      #
      #   mails = []
      #   mails << MyMailer.create_some_mail(parameters)
      #   mails << MyMailer.create_some_mail(parameters)
      #   MyMailer.deliver(mails)
      #
      # or, like:
      #
      #   first = MyMailer.create_some_mail(parameters)
      #   second = MyMailer.create_some_mail(parameters)
      #   MyMailer.deliver(first, second)
      #
      # If an array of mail objects is passed, and delivery_method is set to :smtp,
      # the messages will be delivered using a single SMTP connection.
      # +true+ is returned if all the mail objects are delivered successfully.
      # Otherwise, an array containing the mail objects that failed to be delivered
      # is returned.
      def deliver(*mails)
        mails.flatten!
        
        if mails.length == 1
          new.deliver!(mails.first)
        else
          errors = []

          case delivery_method
            when :smtp
              Net::SMTP.start(smtp_settings[:address], smtp_settings[:port], smtp_settings[:domain],
                  smtp_settings[:user_name], smtp_settings[:password], smtp_settings[:authentication]) do |smtp|
                mails.each do |mail|
                  logger.info "Sent mail:\n #{mail.encoded}" unless logger.nil?
                  
                  begin
                    destinations = mail.destinations
                    mail.ready_to_send
                    
                    smtp.sendmail(mail.encoded, mail.from, destinations)
                  rescue Object => e
                    errors << e
                  end
                end
              end
              
            else
              mails.each do |mail|
                begin
                  new.deliver!(mail)
                rescue Object => e
                  errors << e
                end
              end
          end
          
          if raise_delivery_errors and !errors.empty?
            errors
          else
            true
          end
        end
      end
      end
      
 end
 
end
 

