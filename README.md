# Mconnect

CLI to export endpoints from the MasteryConnect API to CSV

## Important

This gem was specifically created for Ingenium Schools and has custom decorators
to format the CSV's how they need them. I'm open sourcing this code just in case
someone that runs across it, can benefit from it.

## Installation

    $ gem install mconnect

## Usage

First things first, you need to setup a configuration file.

    $ mconnect config

It will ask you some questions and generate a configuration yaml. After this is
complete, you will need to authorize your client.

    $ mconnect auth

This will give you a URL to paste into your browser that will send you to a
login, then immediately after, an authorization page. It will be awaiting input
for your oauth verifier. This can be found as a parameter on the end of the URL
after you've been logged in and authorized. After you paste your oauth verifier
into the input and the program completes, your authorization file has been generated.

You are now free to run the get method in order to get a specific API endpoint
and export it to a CSV file. Use the '-e' to tell the program which endpoint you
want to export and '-o' to tell it where you want the data to go. You can see an
example below:

    $ mconnect get -e teachers -o ~/Desktop/teachers.csv

## Contributing

1. Fork it ( https://github.com/sao/mconnect/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
