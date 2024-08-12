# Problem description

This repo contains an example for a reproducible problem with `Minitar.pack` and
`Minitar.unpack`. It will apparently correctly create archives containing nested
filenames longer than 100 characters, but on extraction, those filenames will be
extracted _differently_ than the original name, duplicating the leading
directory. In simplified form, this means that a file `a/b/c/LONG` gets
extracted as `a/b/c/a/b/c/LONG`.

```diff
-k6hly56/mh/ri2pa1/04/5k8mnvwxe7hmvp1n932o4mn2b25gqrxfrbe4jfjbig6kzhphnsfkrtqruypfzl93u0ohlv9yyxcoxn6jg6iv5ml8e27jdqjiikyq3.js
+k6hly56/mh/ri2pa1/04/k6hly56/mh/ri2pa1/04/5k8mnvwxe7hmvp1n932o4mn2b25gqrxfrbe4jfjbig6kzhphnsfkrtqruypfzl93u0ohlv9yyxcoxn6jg6iv5ml8e27jdqjiikyq3.js
```

This appears to be related to _multiple_ issues in how `minitar` currently packs
and unpacks those files (these are theories, not proven facts), based on
comparing a `minitar` archive with a `gnutar` archive on a much-simplified
version of the test from the [original repo][original repo].

1. GNU Tar writes _all_ filenames with `/` at the end. Minitar does not.

2. For `gnutar cf ../foo.tar .`, all path entries are prefixed with `./`.
   Minitar does not.

3. On extraction, GNU tar appears to apply similar behaviours noted above to
   render the extracted files safe and ensure that root entries are treated as
   root entries and do not cause recursive expansion. Minitar does not.

The root cause of these issues and ultimate fix is as yet unclear. There are
additional unclear differences (the GNU tarball is ~10k whereas the Minitar
tarball is ~4k).

## How to Run

```bash
./run [--verbose] TEST_PATTERN
```

The `TEST_PATTERN` is a pattern that will match one of:

- files-00-all
- files-01-bad
- files-02-two
- files-03-one-nested
- files-04-one-flat

The tests can be run with the full name, the number, or partial name. These are
all the same:

```bash
./run file-02-two
./run 02
./run two
```

This uses inline Bundler, so Minitar will be installed automatically if it is
not already present.

## Comparing Against a Different Tar Program

Minitar 1 uses GNU tar extensions for long file name handling on both creation
and extraction; this will probably be dropped by Minitar 2 for creation and
replaced with the better-documented approaches from libarchive.

If the use of GNU tar extensions for creation can be implemented in a way that
does not compromise the licence or stability, it may be explored.

```bash
gnutar cf gnutar-archive.tar -C <TEST_DIR> .
```

## Old Notes by floj

This repo contains an example for a reproducible problem with minitar. Minitar
is perfectly able to create archives containing filenames longer than 100
characters. But when extracting such an archive, files with names longer than
100 characters are silently skipped.

### How to run

```sh
bundle install
bundle exec ruby problem.sh
```

### Notes

I stumbled about this problem while repackaging a Vue.js web application created
by Webpack. Depending on how you structure your components, the filenames
created could to be very long. The content of `tar_source` is actually a copy of
the file structure that caused the problem, but with names replaced with random
char sequences of the same length (file extensions are kept as they are) and
contents removed.

Doing the same with tar on the command line does not have this problem:

```sh
tar cf cmd_archive.tar -C tar_source .
mkdir cmd_tar_extracted
tar xf cmd_archive.tar -C cmd_tar_extracted .
diff <(cd tar_source && find . | sort) <( cd cmd_tar_extracted && find . | sort)
```

[original repo]: https://github.com/floj/minitar-lfn-problem
