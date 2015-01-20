Condensation
============

Condensation allows for maximisation of cloud storage capabilities by combining several popular cloud storage platforms, with the ability to distribute large files across platforms when needed.

Note: This app is still under development, so frequent changes can happen often - **including changes to the database schemae**. If you `pull`, you may need to delete the databases (`rm ~/.condensation/db.json`), manually delete all condensation-related files in your clouds, and re-upload them. Check commit messages!

##Getting started:

Runs on: Ruby 2.2.0, Unix-like OSes (e.g. Linux, Mac OS X [with command-line tools installed], etc)

####Installing RVM
Install the RVM (Ruby Virtual Machine) first:
  * `gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3`
  * `\curl -sSL https://get.rvm.io | bash -s stable --ruby=2.2.0`

####Installing gems

Install dependencies with `bundle install`. 

####Configure authentication for cloud services

Next, run `ruby app.rb --configure` for each service (Dropbox, OneDrive and Box), to setup the `~/.condensation` directory and authorize the program to access your cloud accounts.

###Usage

Once you're all set up, try uploading something with `ruby app.rb --upload <file>`! 
Keep in mind that, in order to download or delete a file, you must pass its SHA-1 hash rather than its filename (`ruby app.rb --SHA <filename>` to look that up). This means you cannot upload identical files, even if their filenames are different.

For a full list of command-line args, run `ruby app.rb --help`

##App structure:

Condensation keeps a JSON database under `~/.condensation/db.json`, along with a database of API tokens for various services under `~/.condensation/api.json`.

####Initial configuration:
In the initial configuration, Condensation will request access to your accounts on Dropbox, OneDrive, Google Drive and Box. For each service, the app contacts an authentication server which handles the API keys. After configuration, your personal account tokens are stored in api.json so that this configuration need not be repeated.

##Features:

* Runs locally on a user's machine
* Upload/Download files - Condensation will keep track of your files in the cloud, allowing for easy re-download at a later point
* Chunk deduplication - Can save space by referencing one chunk for all files with that data in common
* Delete files - Condensation makes sure to only delete chunks unique to the file being deleted
* Interface graphically with the app in-browser [Not yet implemented]

##Services supported:

* Dropbox (Free 2GB+)
* Microsoft OneDrive (Free 15GB)
* Box (Free 10GB)

For at least 37GB free cloud storage with your favourite providers!
