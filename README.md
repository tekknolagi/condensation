Condensation
============

Condensation allows for maximisation of cloud storage capabilities by combining several popular cloud storage platforms, with the ability to distribute large files across platforms when needed.

##Getting started:

Run `ruby app.rb --configure` to add the accounts for `dropbox` and `onedrive`.

Finally, try uploading something with `ruby app.rb -u <file>`!

##App structure:

Condensation keeps a JSON database under `~/.condensation/db.json`, along with a database of API tokens for various services under `~/.condensation/api.json`.

####Initial configuration:
In the initial configuration, Condensation will request access to your accounts on Dropbox, OneDrive, Google Drive and Box. For each service, the app contacts an authentication server which handles the API keys. After configuration, your personal account tokens are stored in api.json so that this configuration need not be repeated.

(gotta work on this documentation)

##Features:

* Runs locally on a user's machine
* Upload files from the main script, Condensation will keep track of your files in the cloud, allowing for easy re-download at a later point
* Can save space by referencing one chunk for all files with that data in common

##Services supported:

* Dropbox
* Microsoft OneDrive
* Google Drive (not yet)
* Box (not yet)
