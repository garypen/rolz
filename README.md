# rolz
Simple script to generate/post sorted initiative

```
  initiative.sh [-f <characters>] -r <room id> [<name init>, <name init>...]

Description

  Uses the rolz API to generatate initiative for the supplied participants

  The results are sorted and posted back to the rolz dice room.

Examples

  intiative.sh -f party.txt -r 12345678 orc -1  -- generates initiative
                                                -- for the contents of
                                                -- party.txt and orc

Options

  <name init>      Pairings of names and initiative adjustments.
                   init must be numeric and optionally preceded by a
                   minus sign.

  -f <characters>  File of character details.
                   Each line is a name and initiative separated by a
                   comma.

  -r <room id>     Room ID from rolz.org
                   e.g.: 12345678
```
