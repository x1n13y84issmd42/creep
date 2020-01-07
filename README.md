# creep
Creep, a Git's buddy.

A small toolkit for Git to ease a developer's everyday life.

### Usage
Add it as a git submodule to your project:
```Shell
git submodule add https://github.com/x1n13y84issmd42/creep.git

# When cloning a project which references a submodule:
git submodule init
git submodule update
```

Also make a directory for creep's stuff in the root of your project:
```Shell
mkdir .creep
```

## Runes
Runes is a tool to automatically and transparently encrypt and decrypt sensitive files on commits, clones & checkouts. Now you can keep your tokens in the repo safely.

![](assets/runes.png)

### Usage
You'll need two git hooks. A `pre-commit` one with the following contents:
```Shell
#!/bin/sh
creep/runes/pre-commit
```

and a `post-checkout` one:
```Shell
#!/bin/sh
creep/runes/post-checkout
```

Also you'll need keys:
```Shell
creep/runes/keygen
```

And a list of sensitive files to encrypt before commiting them to git:
```Shell
echo ".env" > .creep/.runes
```

And you're set for keeping private data in git. Just continue adding files, commiting & pushing as usual, Runes will take care about the privacy.

The `.creep/runes.private.key` file is gitignored, so take some care about it, so it won't get lost or something, otherwise you won't ever read your precious files again, y'know.
