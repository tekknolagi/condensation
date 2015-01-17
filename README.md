Condensation
============

Condensation allows for maximisation of cloud storage capabilities by combining several popular cloud storage platforms, with the ability to distribute large files across platforms when needed.

##Getting started:

Make a folder called `~/.condensation`, then add `api.json` and `db.json` as follows:

#### api.json

```js
{
  "dropbox": {},
  "onedrive": {}
}
```

#### db.json

```js
{
  "fn2ref": {},
  "chunk2ref": {}
}
```

##App structure:

Condensation keeps a JSON database under `~/.condensation/db.json`, along with a database of API tokens for various services under `~/.condensation/api.json`.

...

(gotta work on this documentation)

##Features:

* Runs locally on a user's machine
* Upload files from the main script, Condensation will keep track of your files in the cloud, allowing for easy re-download at a later point
* Can save space by referencing one chunk for all files with that data in common

##Services supported:

* Dropbox
* Google Drive (not yet)
* Microsoft OneDrive
* Box (not yet)
