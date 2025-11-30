require 'obd'
require 'text-table'
require File.expand_path('../error_codes', __FILE__)

class Auto
  attr_reader :obd

  def self.detect
    dev_tty = OBD::Connection.detect
    raise 'No device detected.' if dev_tty.nil?
    Auto.new(dev_tty)
  end

  def initialize(dev_tty, baud = 38400)
    # because OBD is trusting hash keys to remain in order
    # which isn't true in Ruby 1.8

    raise 'Ruby 1.9 or greater required' unless RUBY_VERSION > '1.8.999'
    puts 'Connecting to port. This may take several seconds...'
    @obd = OBD.connect(dev_tty, baud)
  end

  def debug
    @obd.debug = !@obd.debug
    "Debug is now #{!!@obd.debug}"
  end

  def dashboard(opts={})
    options = {:include_unsupported => false}.merge(opts)
    puts options.inspect
    pids = if options[:include_unsupported]
             OBD::Command.pids.keys
           else
             supported_pids
           end

    puts (pids.map { |pid| [pid, @obd[pid]] }.to_text_table)
  end

  def supported_pids
    # obd gem might be for earlier than ELM327, which I think had
    # one less piece of data returned, thus the incorrect parsing
    # in OBD::Command.response

    # @obd[:pids_supported_1].compact

    data = @obd.send '0100'
    bits = ''
    data[6..-1].split(' ').each { |byte| bits << byte.to_i(16).to_s(2) }

    puts bits
    bits.split('').each_with_index.map do |b, i|
      OBD::Command.pids.keys[i + 1] if b == '1'
    end.compact
  end

  def error_codes
    # TODO: This is out of date for newer cars.

    # This is from Gemini after a long chat, it seems consistent, but I haven't
    # taken the time to trace it back.
    #
    # How Length is Handled in CAN (ISO 15765-4)
    #
    # The actual length indication for the entire message depends on the
    # transport layer protocol used:
    #
    # Single Frame Message (most common for short messages): The first byte of
    # the data payload often acts as a length indicator for the entire OBD
    # message payload that follows it. In your example, if this were the case,
    # the full message might look like 03 43 01 03 02, where 03 would mean the
    # following 3 bytes (43 01 03 02) are the payload.
    #
    # The specific interpretation for Mode 03: When a vehicle responds to a Mode
    # 03 request for DTCs, the bytes following the positive response byte (43)
    # are structured differently. The standard defines the byte 01 as the count
    # of codes present, not the total length of the remaining data bytes.

    puts "code may be out of date! use debug and dbl-check the byte output!"

    result = @obd.send('03').split(' ')
    raise 'First byte should be 43' unless result.shift == '43'
    codes = []
    while result.length > 0
      code = result.shift(2)
      break if code.join == '0000' || code.length != 2
      error = ErrorCodes.codes[code[0][0]]
      interpreted_code = "#{error[0]}#{code[0][1]}#{code[1]}"
      codes << "#{interpreted_code} - #{error[1]}"
    end
    codes
  end

  def reset
    @obd.reset
  end

  def clear_check_engine_light(are_you_sure=false)
    raise 'Must pass are_you_sure=true to method' unless are_you_sure
    @obd.send('04')
  end
end

class OBD::Connection
  attr_accessor :debug

  def send_with_debug(data)
    if debug
      $stderr.puts ">> #{data}"
      send_without_debug(data).tap { |res| $stderr.puts "<< #{res}" }
    else
      send_without_debug(data)
    end
  end

  # to support Pry reload
  unless OBD::Connection.method_defined? :send_without_debug
    alias_method :send_without_debug, :send
    alias_method :send, :send_with_debug
  end

  def reset
    send('AT Z')
  end

  def self.detect
    puts 'Press Return when OBD cable is unplugged.'
    gets
    before = Dir.entries('/dev')
    puts 'Press Return after OBD cable is plugged in.'
    gets
    # this could just loop if you wanted til it found new entries?
    after = Dir.entries('/dev')

    tty = (after - before).grep(/tty/).first
    tty.nil? ? puts('Could not detect!') : "/dev/#{tty}"
  end
end

class OBD::Command
  # thinking ELM327 has a newer format with additional data.
  # though this is also insufficient for supported pids
  # processing
  def self.h response
    response[6..-1].to_i(16)
  end
end
