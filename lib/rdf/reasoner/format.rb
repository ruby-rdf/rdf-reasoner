module RDF::Reasoner
  ##
  # LD::Patch format specification. Note that this format does not define any readers or writers.
  #
  # @example Obtaining an LD Patch format class
  #     RDF::Format.for(:reasoner)           #=> RDF::Reasoner::Format
  #
  # @see http://www.w3.org/TR/ldpatch/
  class Format < RDF::Format

    ##
    # Hash of CLI commands appropriate for this format
    # @return [Hash{Symbol => Lambda(Array, Hash)}]
    def self.cli_commands
      {
        entail: {
          description: "Perform RDFS entailment to expand the repository based on referenced built-in vocabuaries",
          help: "entail",
          parse: true,
          lambda: ->(argv, opts) do
            RDF::Reasoner.apply(:rdfs, :owl, :schema)
            start, stmt_cnt = Time.now, RDF::CLI.repository.count
            RDF::CLI.repository.entail!
            secs, new_cnt = (Time.new - start), (RDF::CLI.repository.count - stmt_cnt)
            $stdout.puts "\nEntailed #{new_cnt} new statements in #{secs} seconds."
          end
        },
        lint: {
          description: "Lint the repository using built-in vocabularies",
          help: "lint",
          parse: true,
          lambda: ->(argv, opts) do
            RDF::Reasoner.apply(:rdfs, :owl, :schema)
            start = Time.now
            messages = RDF::CLI.repository.lint
            secs = Time.new - start
            messages.each do |kind, term_messages|
              term_messages.each do |term, messages|
                $stdout.puts "#{kind}  #{term}"
                messages.each {|m| $stdout.puts "  #{m}"}
              end
            end
            $stdout.puts "\nLinted in #{secs} seconds."
          end
        }
      }
    end
  end
end
