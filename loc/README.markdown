# LOC Added / Removed #

The goal of this directory is to compile a report of Lines of Code added and
removed for each released version of projects composing Puppet Enterprise.

The basic assumptions are:

 * Git
 * Only tagged (shipped) references matter
 * Lines of Code +/- for the entire release
 * Correlate to Features for the release
 * By Author

# Quick Start #

 1. If the totals are wrong for someone (e.g. Markus) make sure their email is
    in the mailmap to get a canonical identifier for them.
 2. Make sure the tags are up to date in `config/config.yaml` for the project
    you care about.
 3. run `rake run`
 4. The reports should be written to reports/

The CSV files are probably the most interesting to get started with.  For each
author, the CSV file gives a total for the lines of code added and removed for
each author during that release.

These CSV files are also setup in such a way that they should be easy to
combine across multiple projects.  For example, to easily figure out how many
lines I've removed across all time:

    rake run
    grep '^Jeff McCune' reports/*.csv | cut -d, -f4 \
      | awk '{ total += $1 } END { print total }'
    5437

# Adding Projects / Releases #

To add a new release to gather LOC metrics for, simply copy an existing section
from `config/config.yaml` to a new section.

NOTE: For metrics to be gathered, at least 2 tags must be listed in the
configuration file.  Also note, the array of tags to compute metrics for are an
ordered list.  The first tag will be the starting point, LOC +/- will be
computed for the commits between the first and second tag, then the second and
third tag, then the third and fourth tag, etc...

# Restarting #

To clean up and re-run everything:

    rake clean
    rake clobber
    rake run

# Updating Tags #

To update the list of tags in each of the locally cached Git repositories:

    rake synctags

If you add a new release to generate metrics for, this command will be
necessary.

EOF
