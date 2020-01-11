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

# Runes
Runes is a tool to automatically and transparently encrypt and decrypt sensitive files on commits, clones & checkouts. Now you can keep your tokens in the repo safely.

![](assets/runes.png)

### Usage
You'll need two git hooks in your project, `pre-commit` & `post-checkout`. You can use the ones from the `runes/.githooks` folder and copy them over to the `.git/hooks` directory in your project.

Also you'll need keys, so generate them from your project root directory:
```Shell
creep/runes keygen
```

And a list of sensitive files to encrypt before commiting them to git:
```Shell
echo ".env" > .creep/.runes
echo "config/secrets.json" >> .creep/.runes
```

And you're set for keeping private data in git. Just go on adding files, commiting & pushing as usual, Runes will take care about the privacy. The files from the `.creep/.runes` list are now encrypted and decrypted as you go.
 
> :eggplant: The `.creep/runes.private.key` file is gitignored, take some care about it so it doesn't get lost or something, otherwise you won't ever read your precious files again, y'know.

### Configuration

|Parameter|Decription|Values|
|-|-|-|
|`CREEP_RUNES_LOG`|Controls the logging verbosity. Set it to `0` to disable logging.|0—3
|`CREEP_RUNES_OFF`|Disables Runes altogether.|1

### TODO:
* [ ] the `creep/runes [un]secure FILENAME` command to add/remove a file to `.creep/.runes`;
* [ ] `creep/runes install-hooks` to put the hook files in `.git/hooks`;

# Boss

A tool to orchestrate a set of repositories in a consistent manner. Provides a `git` proxy script to perform Git ops across all the involved projects. Basically and analog of [loop])()

### //TODO:
* A list of repos in the `.creep/.boss` file;
* it should support both `git submodule` mode & `ad-hoc` mode (when it creates folders & clones repos in there, the regular git workflow);
* `creep/boss add REPOURL|NAME` initializes a directory for a project and clones it if a repository URL is provided;
* `creep/boss update [PROJ1 PROJ2 ...]` should `git clone` (or `git pull`) all the projects (or only specified ones);
* `creep/boss git $@` a Git proxy script to execute Git ops across all the subprojects;
* `creep/boss x $@` executes a command across the subprojects;
* Should it include also some Docker-related stuff?
* And essentially be a cluster management tool?