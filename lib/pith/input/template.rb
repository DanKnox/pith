require "fileutils"
require "pathname"
require "pith/input/abstract"
require "pith/render_context"
require "tilt"
require "yaml"

module Pith
  module Input

    class Template < Abstract

      class UnrecognisedType < StandardError; end
      
      def initialize(project, path)
        super(project, path)
        path.to_s =~ /^(.*)\.(.*)$/
        @output_path = Pathname($1)
        @type = $2
        raise(UnrecognisedType, @type) unless Tilt.registered?(@type)
        load
      end

      attr_reader :output_path, :type

      # Check whether output is up-to-date.
      #
      # Return true unless output needs to be re-generated.
      #
      def uptodate?
        dependencies && FileUtils.uptodate?(output_file, dependencies)
      end

      # Generate output for this template
      #
      def generate_output
        output_file.parent.mkpath
        render_context = RenderContext.new(project)
        output_file.open("w") do |out|
          out.puts(render_context.render(self))
        end
        @dependencies = render_context.dependencies
      end

      # Render this input using Tilt
      #
      def render(context, locals = {}, &block)
        @tilt_template.render(context, locals, &block)
      end
      
      # Public: Get YAML metadata declared in the header of of a template.
      # 
      # If the first line of the template starts with "---" it is considered to be
      # the start of a YAML 'document', which is loaded and returned.
      #
      # Examples
      #
      #   Given input starting with:
      #
      #     ---
      #     published: 2008-09-15
      #     ...
      #     OTHER STUFF
      #
      #   input.meta
      #   #=> { "published" => "2008-09-15" }
      #  
      # Returns a Hash.
      #
      def meta
        @meta
      end

      # Public: Get page title.
      #
      # The default title is based on the input file-name, sans-extension, capitalised,
      # but can be overridden by providing a "title" in the metadata block.
      #
      # Examples
      #
      #  input.path.to_s
      #  #=> "some_page.html.haml"
      #  input.title
      #  #=> "Some page"
      # 
      def title
        meta["title"] || default_title
      end

      private

      # Read input file, extracting YAML meta-data header, and template content.
      #
      def load
        @meta = {}
        file.open do |input|
          header = input.gets
          if header =~ /^---/
            while line = input.gets
              break if line =~ /^(---|\.\.\.)/
              header << line
            end
            begin
              @meta = YAML.load(header)
            rescue
              logger.warn "#{file}:1: badly-formed YAML header"
            end
          else
            input.rewind
          end
          @tilt_template = Tilt.new(file, input.lineno + 1) { input.read }
        end
      end
      
      attr_accessor :dependencies

    end

  end
end
