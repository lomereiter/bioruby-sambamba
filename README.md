# bio-sambamba

[![Build Status](https://secure.travis-ci.org/lomereiter/bioruby-sambamba.png)](http://travis-ci.org/lomereiter/bioruby-sambamba)

Full description goes here

Note: this software is under active development!

## Installation

```sh
    rake build
    rake install
```

In order to use the gem, you also need <code>sambamba</code> tool installed.
For that, do the following:

* install [DMD compiler](http://dlang.org/download.html)
* install [Ragel](http://www.complang.org/ragel/) finite state machine compiler
* clone sambamba repository and compile the tool
```sh
    git clone https://github.com/lomereiter/sambamba.git
    cd sambamba/CLItools/
    make
```
* place the executable file <code>build/sambamba</code> to somewhere in your $PATH,
  for example:
```sh
    cp build/sambamba /usr/local/bin
```

## Usage

```ruby
    require 'bio-sambamba'
```

The API doc is online. For more code examples see the test files in
the source tree.
        
## Project home page

Information on the source tree, documentation, examples, issues and
how to contribute, see

  http://github.com/lomereiter/bioruby-sambamba

The BioRuby community is on IRC server: irc.freenode.org, channel: #bioruby.

## Cite

If you use this software, please cite one of
  
* [BioRuby: bioinformatics software for the Ruby programming language](http://dx.doi.org/10.1093/bioinformatics/btq475)
* [Biogem: an effective tool-based approach for scaling up open source software development in bioinformatics](http://dx.doi.org/10.1093/bioinformatics/bts080)

## Biogems.info

This Biogem is published at [#bio-sambamba](http://biogems.info/index.html)

## Copyright

Copyright (c) 2012 Artem Tarasov. See LICENSE.txt for further details.

