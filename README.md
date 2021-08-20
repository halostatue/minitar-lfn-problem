# Problem description

This repo contains an example for a reproducible problem with minitar.
Minitar is perfectly able to create archives containing filenames longer than 100 characters.
But when extracting such an archive, files with names longer than 100 characters are silently
skipped.

## How to run

```sh
bundle install
bundle exec ruby problem.sh
```

## Notes

I stumbled about this problem while repackaging a Vue.js web application created by Webpack.
Depending on how you structure your components, the filenames created could to be very long.
The content of `tar_source` is actually a copy of the file structure that caused the problem,
but with names replaced with random char sequences of the same length (file extensions are kept
as they are) and contents removed.

Doing the same with tar on the command line does not have this problem:

```sh
tar cf cmd_archive.tar -C tar_source .
mkdir cmd_tar_extracted
tar xf cmd_archive.tar -C cmd_tar_extracted .
diff <(cd tar_source && find . | sort) <( cd cmd_tar_extracted && find . | sort) 
```