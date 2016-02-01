require 'taglib'
require 'highline'
require 'pathname'
require 'pry'
require 'yaml'
require 'hashie'

class CamelotKeyConverter::Converter
  MAP_FILE = File.expand_path('~/.key_convert_map.yml')
  attr_accessor :ignored, :map, :should_convert_all

  def initialize
    self.ignored = []
    self.map = {}
    self.should_convert_all = false
    try_load_file
  end

  def run!
    convert(Pathname.new('.'))
  rescue ExitError => e
    cli.say('exiting ...')
  ensure
    save_config!
  end

  def cli
    @cli ||= HighLine.new
  end

  def save_config!
    File.open(MAP_FILE, 'w') do |f|
      f.write({
        "ignored" => ignored,
        "map" => map
      }.to_yaml)
    end
  end

  def convert(path)
    if path.file?
      convert_file! path
      return
    end

    path.children.each do |child|
      if self.should_convert_all
        convert(child)
        next
      end

      cli.choose do |menu|
        menu.prompt = "What to do next?"
        menu.choice(:convert, "Convert #{child}") do
          convert(child)
        end

        menu.choice(:exit) do
          raise ExitError
        end

        menu.choice(:convert_all) do
          self.should_convert_all = true
          convert(child)
        end
      end
    end
  end

  def try_load_file
    x = YAML::load_file(MAP_FILE)
    self.ignored = x['ignored'] || []
    self.map = x['map'] || {}
  rescue
  end


  def convert_file!(path)
    TagLib::MPEG::File.open(path.to_s) do |file|
      tag = file.id3v2_tag
      key = tag.frame_list('TKEY').first

      if key.nil?
        cli.say "no key found for #{path}"
        return
      end

      if key.field_list.length != 1
        binding.pry
        return
      end

      if ignored.include? key.to_s
        cli.say("#{key.to_s} is ignored")
        return
      end

      if map.values.include? key.to_s
        cli.say("#{key.to_s} already correct value")
        return
      end

      new_key = map[key.to_s]
      unless new_key
        result = cli.choose do |menu|
          menu.prompt = "Cant find #{key.to_s}. What to you want to do?"
          menu.choice(:add)
          menu.choice(:ignore) do
            ignored << key.to_s
            return
          end
          menu.choice(:exit) do
            raise ExitError
          end
        end

        # can only be :add because :ignore and :exit return

        loop do
          new_key = cli.ask('Enter the replacement and press enter: ')
          if map.keys.include?(new_key)
            cli.say('This value does already exist as key, which is not allowed to prevent loops.')
          else
            break
          end
        end

        if cli.agree('Do you want to save the replacement?')
          map[key.to_s] = new_key
        end
      end

      cli.say("#{path.to_s} - #{new_key}")

      # don't alter file if nothing changed
      return if new_key == key.to_s

      key.field_list = [new_key]
      file.save
    end
  end

  class ExitError < StandardError
  end
end
