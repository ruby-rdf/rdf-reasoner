$:.unshift "."
require 'spec_helper'
require 'rdf/spec'

describe RDF::Reasoner do
  # W3C RDF Semantics Test suite from https://dvcs.w3.org/hg/rdf/file/default/rdf-mt/tests/
  describe "w3c reasoner tests" do
    before(:all) {RDF::Reasoner.apply(:rdfs)}
    require 'suite_helper'

    %w(manifest.ttl).each do |man|
      Fixtures::SuiteTest::Manifest.open(Fixtures::SuiteTest::BASE + man) do |m|
        describe m.comment do
          m.entries.each_with_index do |t, ndx|
            specify "#{t.name}: #{Array(t.comment).join(' - ')}" do
              t.logger = RDF::Spec.logger
              t.logger.info "action:\n#{t.input}" if t.input
              t.logger.info "expected:\n#{t.expected}" if t.expected

              action_graph = t.action ? RDF::Repository.load(t.action, base_uri: t.base) : false
              result_graph = t.result.is_a?(String) ? RDF::Repository.load(t.result, base_uri: t.base) : false

              # Extract any triples 
              if vocab = extract_vocab(action_graph, ndx)
                t.logger.info vocab.inspect
              end

              case t.name
              when 'datatypes-semantic-equivalence-within-type-1',
                   'datatypes-semantic-equivalence-within-type-2',
                   'datatypes-semantic-equivalence-between-datatypes'
                pending "Datatype Entailment"
              when *%w(rdfs-subPropertyOf-semantics-test001)
                pending 'subProperty inheritance'
              when *%w(tex-01-language-tag-case-1 tex-01-language-tag-case-2)
                pending 'language tag case insensitivity'
              when 'datatypes-test008'
                pending 'rdfD1'
              when /rdfms-seq/
                skip 'No rdf:Seq entailment'
              end
              begin
                if t.positive_test?
                  action_graph.entail!
                  case result_graph
                  when RDF::Enumerable
                    # Add source triples to result to use equivalence
                    # FIXME: entailment test should be subgraph, considering BNode equivalence.
                    # Could be implemented in N3 as {G2 . {G1} => log:Success} or {G2} log:includes {G1}
                    action_graph.each {|s| result_graph << s}
                    expect(action_graph).to be_equivalent_graph(result_graph, t)
                  when false
                    expect(action_graph.lint.to_s).not_to produce('{}', t)
                  end
                else
                  skip "NegativeEntailment"
                end
              #rescue
              #  if t.action == false
              #    fail "don't know how to deal with false premise"
              #  elsif t.result == false
              #    fail "don't know how to deal with false result"
              #  else
              #    raise
              #  end
              ensure
                RDF::Vocabulary.remove(vocab) if vocab
              end
            end
          end
        end
      end
    end
  end
end unless ENV['CI']

# Figure out if there's a graph, and what URI to give it, then create an RDF::Vocabulary subclass
def extract_vocab(graph, ndx)
  vocab_stmt = graph.statements.detect do |s|
    %w(subClassOf subPropertyOf domain range).
    map {|t| RDF::RDFS[t.to_sym]}.
    include?(s.predicate)
  end

  if vocab_stmt
    vocab_subject = vocab_stmt.subject
    base = if vocab_subject.fragment
      vocab_subject = vocab_subject.dup
      vocab_subject.fragment = ""
      vocab_subject
    else
      vocab_subject.join("")
    end
    RDF::Vocabulary.from_graph(graph, url: base, class_name: "RDFMT#{ndx}")
  end
end