# Rake scripts

This is a small collection of rake scripts which help keeping the Rakefile very short.

## Example

```ruby
require_relative 'rake/c'

# Set some compiler flags.
C.cflags = '-O3'

# Create a library which will be placed in ‘build/libsomelibrary.a’.
C.library 'somelibrary', [
  # It uses the files ‘src/somelibrary/bunch.c’, ‘src/somelibrary/of.c’ and
  # ‘src/somelibrary/files.c’.
  'bunch.c', 'of.c', 'files.c'
]

# Set some other compiler flags.
C.cflags = '-O3 -std=c99 -Wall -pedantic'

# Make ‘build/libtest.a’ from ‘src/test/test.c’.
C.library 'test', ['test.c']

# Create a program ‘build/test’.
C.program 'test', [
  # Use the file ‘src/test.c’, ...
  'test.c',
  # ... the two libraries above ...
  'libtest.a', 'libsomelibrary.a',
  # ... and the maths library.
  '-lm'
]
```
