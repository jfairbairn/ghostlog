Ghostlog, a stream interface to your workstreams
================================================

The plan
--------

A bunch of agents pull stuff from various sources:

 * Commits from Subversion, Mercurial and Git;
 * Emails from an IMAP server (either a particular folder or addressed to a
   particular recipient), or from a folder on the filesystem;
 * Status updates from Twitter, Yammer or some other system.
 
They extract out two types of thing:

1. A document that can be rendered as HTML markup, which might include links
   to
2. resources or assets that are embedded in, or referenced by, the document.

The example for mail would be to extract the text/html part of a MIME email,
walk through the content, pulling out all references to MIME-attached
images.

The documents go into ElasticSearch, tagged appropriately, and storing full
text. The resources go into the filesystem to be served by the web server.

Document schema
---------------

[Title]
Author
Date
Link
Content
Type
Source
Projects
[Thread]

TODO
----

 * Create index on start
 * Mail importer
 * SVN importer
 * Asset extractor
 * Project stream view
 * Project list page (home page)
 * Mercurial importer
 * Search interface