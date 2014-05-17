# rdf-reasoner

Reasons over RDFS/OWL vocabularies to generate statements which are entailed
based on base RDFS/OWL rules along with vocabulary information. It can also be
used to ask specific questions, such as if a given object is consistent with
the vocabulary ruleset. This can be used to implement [SPARQL Entailment][] Regimes.

## Features

## Description

## Examples

## Documentation

### Principle Classes

## Dependencies

* [Ruby](http://ruby-lang.org/) (>= 1.9) or (>= 1.8.1 with [Backports][])
* [RDF.rb](http://rubygems.org/gems/rdf) (>= 1.0)

## Mailing List

* <http://lists.w3.org/Archives/Public/public-rdf-ruby/>

## Authors

* [Gregg Kellogg](http://github.com/gkellogg) - <http://greggkellogg.net/>
* [Arto Bendiken](http://github.com/bendiken) - <http://ar.to/>
* [Pius Uzamere](http://github.com/pius) - <http://pius.me/>

## Contributing

* Do your best to adhere to the existing coding conventions and idioms.
* Don't use hard tabs, and don't leave trailing whitespace on any line.
  Before committing, run `git diff --check` to make sure of this.
* Do document every method you add using [YARD][] annotations. Read the
  [tutorial][YARD-GS] or just look at the existing code for examples.
* Don't touch the `.gemspec`, `VERSION` or `AUTHORS` files. If you need to
  change them, do so on your private branch only.
* Do feel free to add yourself to the `CREDITS` file and the corresponding
  list in the the `README`. Alphabetical order applies.
* Do note that in order for us to merge any non-trivial changes (as a rule
  of thumb, additions larger than about 15 lines of code), we need an
  explicit [public domain dedication][PDD] on record from you.

## License

This is free and unencumbered public domain software. For more information,
see <http://unlicense.org/> or the accompanying {file:UNLICENSE} file.

[Ruby]:             http://ruby-lang.org/
[RDF]:              http://www.w3.org/RDF/
[YARD]:             http://yardoc.org/
[YARD-GS]:          http://rubydoc.info/docs/yard/file/docs/GettingStarted.md
[PDD]:              http://lists.w3.org/Archives/Public/public-rdf-ruby/2010May/0013.html
[SPARQL]:           http://en.wikipedia.org/wiki/SPARQL
[SPARQL Query]:     http://www.w3.org/TR/2013/REC-sparql11-query-20130321/
[SPARQL Entailment]:http://www.w3.org/TR/2013/REC-sparql11-reasoner-20130321/
[RDF 1.1]:          http://www.w3.org/TR/rdf11-concepts
[RDF.rb]:           http://rdf.rubyforge.org/
[Rack]:             http://rack.rubyforge.org/
