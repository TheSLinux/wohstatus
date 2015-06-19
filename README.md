## Table of contents

* [Description](#description)
* [Getting started](#getting-started)
* [Adding new event](#adding-new-event)
* [Data format](#data-format)
* [Author. License](#author-license)

## Description

Generate almost beautiful and professional static status pages
from `YAML` data.

## Getting started

Make you have `Bash` and `Ruby` on your system.

There are already sample input data and sample output pages.

    $ ./compile.sh

The output will be written to `output` directory.
Open `status.html` from that directory to see.

You can see for an example http://icy.theslinux.org/wohstatus/status.html.

## Adding new event

Try the script `add.sh`. For example

    $ ./add.sh data/Testing/ down "Something went wrong"

New data will be appended to the file `data/Testing/2015.yaml`
(`2015` or the current year.) If you don't want to use current year
as output file, use `WOHSTATUS_OUTPUT`, as below

    $ WOHSTATUS_OUTPUT=testing ./add data/Testing/ down "Testing"

New data will be written to `data/Testing/testing.yaml`.

## Data format

It's easy. Please take a look at the sample data under `data/`.

Each service has its own directory under `data/` directory.
If there is a file `ignore` under the service directory,
that service will be ignored.

Each service directory contains a bunch of `.yaml` file.
All of them will be read and processed, so their names are not important.

Each `YAML` file may contain `settings` or `events` attribute, as below

    ---
    settings:
      name: Service name
      url: Link to service
    events:
      "timestamp 1": "A message"
      "timestamp 2":
        status: up|down|limited|info|...
        message: Your input message

A timestamp should be in `RFC-2822` format. You can get this
with `date -R` command.

A `status` is valid if there is an image of the same found under
`output/images`. For example, `lock` is valid status, because
there is a file `output/images/lock.png`.
(The program doesn't check if the image does exist, though.)

Though you can provide `settings` many times, the last one wins.
All you need is to put all settings under a private `settings.yaml` file.

## Author. License

The author is Anh K. Huynh.

This work is released under terms of a `MIT` license.

The icons (except `external.png`)
come from [StashBoard](https://github.com/twilio/stashboard/) project
and you may read [this ticket](https://github.com/twilio/stashboard/issues/76)
regarding license issue.
