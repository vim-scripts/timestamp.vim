This is a mirror of http://www.vim.org/scripts/script.php?script_id=923

When a file is written, and the filename matches |timestamp_automask|, this plugin will search the first and last |timestamp_modelines| lines of your file. If it finds the regexp |timestamp_regexp| then it will replace it with a timestamp. The timestamp is computed by first doing a |token_substitution| on |timestamp_rep| and passing the result to |strftime()|.

The plugin tries to stay out of your way, and make the change as transparent as possible. Your search (and all other) history is unaltered, however you might find an extra mark in your jumplist.

All the default variables and actions can be changed by buffer / global vim variables. See |timestamp_examples for two simple examples.

By default, this plugin will timestamp ANY file that matches the regexp |timestamp_regexp| in the first and last 'modelines' (default 5) lines of your file. The default value of |timestamp_regexp| will EITHER match 'TIMESTAMP' or a time (in the format of strftime("%c")) FOLLOWED by a 'Last changed:' or 'Last modified:'. For instance, if you create a new file and want to stamp it with a creation date and a last modified date, make the first few lines: >

    Created:            TIMESTAMP
    Last Modified:      TIMESTAMP

When you first write the file, these lines will change to: >

    Created:            Thu 26 Feb 2004 03:15:54 PM CST
    Last Modified:      Thu 26 Feb 2004 03:15:55 PM CST

On subsequent writes of the file, the first line will remain unchanged and the second will be stamped with the time of writing.

NOTE: If you find that on subsequent writes of the file, the second line is also unchanged, it is probably because the time returned by strftime is NOT is the format above. [Look closely and see if there is a leading 0 or timezone missing]. If you are using version 1.11 and higher and still have this problem, please report it to me. As a temporary fix, you can put the line >

    let timestamp_regexp = '\v\C%(<Last %([cC]hanged?|[Mm]odified):\s+)@<=.*$'

in your .vimrc. This however has the disadvantage of eating all the text after the colon in any timestamp line.

Read the complete htmlised documentation at http://math.stanford.edu/~gautam/opensource/xterm16/timestamp-doc.html
