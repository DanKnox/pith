require "pathname"
require "logger"
require "pith/input"
require "tilt"

module Pith
  
  class Project
    
    def initialize(attributes = {})
      attributes.each do |k,v|
        send("#{k}=", v)
      end
    end
    
    attr_accessor :input_dir, :output_dir
    
    def inputs
      Pathname.glob(input_dir + "**/*").map do |input_file|
        next if input_file.directory?
        path = input_file.relative_path_from(input_dir)
        input_cache[path]
      end.compact
    end
    
    def input(path)
      path = Pathname(path)
      inputs.each do |input|
        return input if input.path == path || input.output_path == path
      end
      raise "Can't find #{path.inspect}"
    end
    
    def build
      load_config
      inputs.each do |input| 
        input.build
      end
    end
    
    def logger
      @logger ||= Logger.new(nil)
    end
    
    attr_writer :logger

    def helpers(&block)
      helper_module.module_eval(&block)
    end
    
    def helper_module
      @helper_module ||= Module.new
    end
    
    private
    
    def load_config
      config_file = input_dir + "_pith/config.rb"
      project = self
      if config_file.exist?
        eval(config_file.read, binding, config_file)
      end
    end

    def input_cache
      @input_cache ||= Hash.new do |h, path|
        h[path] = Input.new(self, path)
      end
    end

  end
  
end
