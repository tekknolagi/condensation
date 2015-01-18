Condensation
============

Condensation allows for maximisation of cloud storage capabilities by combining several popular cloud storage platforms, with the ability to distribute large files across platforms when needed.

##Getting started:

First, install dependencies with `bundle install`. Install Ruby Shoes from [http://shoesrb.com/downloads/](their downloads page) if you want to run a UI.

Next, run `ruby app.rb --configure` for each service (Dropbox, OneDrive and Box), to setup the `~/.condensation` directory and authorize the program to access your cloud accounts.

Finally, try uploading something with `ruby app.rb --upload <file>`!

For a full list of command-line args, run `ruby app.rb --help`

##App structure:

Condensation keeps a JSON database under `~/.condensation/db.json`, along with a database of API tokens for various services under `~/.condensation/api.json`.

####Initial configuration:
In the initial configuration, Condensation will request access to your accounts on Dropbox, OneDrive, Google Drive and Box. For each service, the app contacts an authentication server which handles the API keys. After configuration, your personal account tokens are stored in api.json so that this configuration need not be repeated.

(gotta work on this documentation)

##Features:

* Runs locally on a user's machine
* Upload files from the main script, Condensation will keep track of your files in the cloud, allowing for easy re-download at a later point
* Can save space by referencing one chunk for all files with that data in common
* Interface graphically with the app in-browser (Not yet implemented)

##Services supported:

* Dropbox
* Microsoft OneDrive
* Box
