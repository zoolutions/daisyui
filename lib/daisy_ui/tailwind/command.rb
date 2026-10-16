# frozen_string_literal: true

module DaisyUI
  module Tailwind
    # `daisyui-tailwind`: the Tailwind sources for the components an app uses,
    # for its CSS build to call (`bundle exec daisyui-tailwind app -o …`).
    # Returns the exit status; usage errors print to `err` and return 1.
    class Command
      BANNER = <<~TEXT
        Usage: daisyui-tailwind [options] [PATH...]

        Prints Tailwind CSS v4 sources (@source inline) for the DaisyUI components
        that the Ruby and templates under each PATH use, plus the components those
        render. @import the output from your Tailwind entry.

      TEXT

      def self.run(argv, out: $stdout, err: $stderr) = new(out:, err:).run(argv)

      def initialize(out:, err:)
        @out = out
        @err = err
      end

      def run(argv)
        require "optparse"

        options = { components: [], format: "css", responsive: [] }
        parser = parser(options)
        paths = parser.parse(argv)
        return help(parser) if options[:help]
        return usage(parser) if paths.empty? && options[:components].empty?

        result = Tailwind.sources(scan: paths, **options.slice(:components, :format, :responsive, :prefix))
        options[:output] ? write(options[:output], result) : @out.write(result)
        0
      rescue OptionParser::ParseError, ArgumentError, SystemCallError => e
        @err.puts "daisyui-tailwind: #{e.message}"
        1
      end

      private

      def parser(options)
        OptionParser.new do |opts|
          opts.banner = BANNER
          opts.on("-c", "--component NAMES", Array, "Components to include, e.g. Button,Navbar (repeatable)") do |names|
            options[:components].concat(names)
          end
          opts.on("-f", "--format FORMAT", %w[css json], "css (default) or json") { |format| options[:format] = format }
          opts.on("-o", "--output FILE", "Write to FILE, only when its content changes") { |file| options[:output] = file }
          opts.on("--responsive BREAKPOINTS", Array, "Add breakpoint variants, e.g. sm,md,lg") do |breakpoints|
            options[:responsive].concat(breakpoints)
          end
          opts.on("--prefix PREFIX", "The DaisyUI.configuration.prefix your app sets") { |prefix| options[:prefix] = prefix }
          opts.on("-h", "--help", "Show this help") { options[:help] = true }
        end
      end

      def help(parser)
        @out.puts parser
        0
      end

      def usage(parser)
        @err.puts parser
        1
      end

      # Only on change: a CSS watcher that sees its own input rewritten on
      # every build rebuilds forever.
      def write(path, content)
        if File.exist?(path) && File.read(path) == content
          @err.puts "daisyui-tailwind: #{path} is up to date"
        else
          require "fileutils"

          FileUtils.mkdir_p(File.dirname(path))
          File.write(path, content)
          @err.puts "daisyui-tailwind: wrote #{path}"
        end
      end
    end
  end
end
