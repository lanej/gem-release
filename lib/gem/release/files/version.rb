require 'gem/release/version/number'

module Gem
  module Release
    module Files
      class Version < Struct.new(:name, :version)
        VERSION      = /(VERSION\s*=\s*(?:"|'))((?:(?!"|').)*)("|')/
        RELEASE      = /^(\d+)\.(\d+)\.(\d+)(.*)$/
        PRE_RELEASE  = /^(\d+)\.(\d+)\.(\d+)\.?(.*)(\d+)$/

        STAGES = [:major, :minor, :patch]

        def exists?
          !!path
        end

        def bump
          File.write(path, bumped)
        end

        def path
          @path ||= paths.detect { |path| File.exists?(path) }
        end

        def from
          @from ||= content =~ VERSION && $2 || raise("Could not determine current version from file #{path}")
        end

        def to
          @to ||= number.bump
        end

        private

          def paths
            %W(
              lib/#{name.gsub('-', '/')}/version.rb
              lib/#{name}/version.rb
            ).uniq
          end

          def not_found
            raise Abort, "version.rb file not found (#{paths.join(', ')})"
          end

          def number
            @number ||= Release::Version::Number.new(from, version ? version.to_sym : nil)
          end

          def bumped
            content.sub(VERSION) { "#{$1}#{to}#{$3}" }
          end

          def content
            @content ||= File.read(path) if exists?
          end

          def to_num(*args)
            args.join('.')
          end

          def path_to(path)
            "lib/#{path}/version.rb"
          end
      end
    end
  end
end