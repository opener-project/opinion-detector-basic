Opinion Detector Basic
---------------------

This module implements a opinion detector for all the languages covered in the OpeNER project (English, Dutch, German, Italian,
Spanish and French). The language is determined by the "xml:lang" attribut in the input KAF file. Depending on the value of this attribute, the corresponding lexicon will be loaded. This module detects three elements of the opinions:

* Expression: the actual opinion expression
* Target: about what is the previous expression
* Holder: who is stating that expression

This module is based on a set of rules for extracting the opinion expressions first (taking into account polarity words and sentiment modifiers) and then other
rules to determine the targets and holders for those expressions. The input KAF file needs to be processed at least with the tokenizer, pos-tagger and polarity-tagger.

### Confused by some terminology?

This software is part of a larger collection of natural language processing tools known as "the OpeNER project". You can find more information about the project at [the OpeNER portal](http://opener-project.github.io). There you can also find references to terms like KAF (an XML standard to represent linguistic annotations in texts), component, cores, scenario's and pipelines.

Quick Use Example
-----------------

Installing the opinion-detector-basic can be done by executing:

    gem install opener-opinion-detector-basic

Please bare in mind that all components in OpeNER take KAF as an input and output KAF by default.

### Command line interface

The input KAF file has to be annotated with at least the term layer, with polarity information.  Correct input files for this module are the output KAF files from the polarity tagger module

To tag an input KAF file example.kaf with opinions you can run:

    $ cat example.with.polaritieskaf | core/opinion_detector_basic_multi.py > output.with.opinions.kaf

The output will the input KAF file extended with the opinion layer.

Excerpt of example output.

```
<opinions>
  <opinion oid="o1">
    <opinion_target>
      <!--hotel-->
      <span>
        <target id="t_6"/>
      </span>
    </opinion_target>
    <opinion_expression polarity="positive" strength="2">
      <!--heel mooi-->
      <span>
        <target id="t_4"/>
        <target id="t_5"/>
      </span>
    </opinion_expression>
  </opinion>
</opinions>
```

### Webservices

You can launch a webservice by executing:

    opinion-detector-basic-server

This will launch a mini webserver with the webservice. It defaults to port 9292, so you can access it at <http://localhost:9292>.

To launch it on a different port provide the `-p [port-number]` option like this:

    opinion-detector-basic-server -p 1234

It then launches at <http://localhost:1234>

Documentation on the Webservice is provided by surfing to the urls provided above. For more information on how to launch a webservice run the command with the ```-h``` option.

### Daemon

Last but not least the opinion detector basic comes shipped with a daemon that can read jobs (and write) jobs to and from Amazon SQS queues. For more information type:

    opinion-detector-basic-daemon -h


Description of dependencies
---------------------------

This component runs best if you run it in an environment suited for OpeNER components. You can find an installation guide and helper tools in the [OpeNER installer](https://github.com/opener-project/opener-installer) and an [installation guide on the Opener Website](http://opener-project.github.io/getting-started/how-to/local-installation.html)

At least you need the following system setup:

### Depenencies for normal use:

* Ruby 1.9.3 or newer
* Python 2.6
* lxml: library for processing xml in python

Domain Adaption
---------------

  TODO

Language Extension
------------------

  TODO


Where to go from here
---------------------

* [Check the project website](http://opener-project.github.io)
* [Checkout the webservice](http://opener.olery.com/opinion-detector-basic)

Report problem/Get help
-----------------------

If you encounter problems, please email <support@opener-project.eu> or leave an issue in the 
[issue tracker](https://github.com/opener-project/opinion-detector-basic/issues).


Contributing
------------

1. Fork it <http://github.com/opener-project/opinion-detector-basic/fork>
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
