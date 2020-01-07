# creep
Creep, a Git's buddy.

A small toolkit for Git to ease a developer's everyday life.

### Usage
Add it as a git submodule to your project, then follow the configuration for each component below.

Also make a directory for creep's stuff in the root of your project:
```
mkdir .creep
```

## Runes
Runes is a tool to automatically encrypt and decrypt sensitive files upon commits, clones & checkouts. Now you can keep your tokens in the repo safely.

### Usage
You'll need two git hooks. A `pre-commit` one with the following contents:
```
#!/bin/sh
creep/runes/pre-commit
```

and a `post-checkout` one:

```
#!/bin/sh
creep/runes/post-checkout
```

Also you'll need keys.
```
creep/runes/keygen
```

And a list of sensitive files to encrypt before commiting them to git.

```
echo ".env" > .creep/.runes
```

And you're set for keeping private data in git.

The `.creep/runes.private.key` file is gitignored, so take some care about it, so it won't get lost or something, otherwise you won't ever read your precious files again, y'know.