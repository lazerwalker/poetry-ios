# Generative Poetry Walk

This is a work-in-progress experiment for a generative location-based poetry walk. It combines a generative poetry engine (currently using [char-rnn](https://github.com/karpathy/char-rnn) running on a remote server) with speech synthesis, music synthesis and various sensor data as inputs.

More info coming soon.

## Installation

1. Clone this repo

2a. (`gem install cocoapods cocoapods-keys`)

2b. `pod install`

3. `cp Poetry/config.plist.example Poetry/config.plist`

4. Swap your server URL in for `serverRoot` value in the plist.

5. Open `Poetry.xcworkspace`.

Currently, this requires you to be running my poetry server, which isn't on GitHub yet (for relatively mundane reasons).

## License

This project is licensed under the MIT License. For more information, see the LICENSE file.