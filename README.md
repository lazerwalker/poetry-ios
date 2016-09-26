# Generative Poetry Walk

[![CI Status](http://img.shields.io/travis/lazerwalker/poetry-ios.svg?style=flat)](https://travis-ci.org/lazerwalker/poetry-ios)


This is a work-in-progress experiment for a generative location-based poetry walk. It combines a generative poetry engine (currently using [char-rnn](https://github.com/karpathy/char-rnn) running on a remote server) with speech synthesis, music synthesis and various sensor data as inputs.

More info coming soon.

## Installation

1. Clone this repo

2 `bundle install` (can skip if you already have both `cocoapods` and `cocoapods-keys` installed)

3. `bundle exec pod install` (can omit `bundle exec` if not using Bundler)

4. `cp Poetry/config.plist.example Poetry/config.plist`

5. Swap your server URL in for `serverRoot` value in the plist.

6. Open `Poetry.xcworkspace`.

Currently, this requires you to be running my poetry server, which isn't on GitHub yet (for relatively mundane reasons).

## License

This project is licensed under the MIT License. For more information, see the LICENSE file.


## Acknowledgements


### Open-Source Libraries
* IntentKit: https://github.com/intentkit/IntentKit
* SQLite.swift: https://github.com/stephencelis/SQLite.swift


### Pre-Trained Neural Networks
* NeuralSnap: https://github.com/rossgoodwin/neuralsnap


### Images
* Golden Gate Bridge: https://thenounproject.com/term/golden-gate-bridge/355437
* Person: https://thenounproject.com/term/person/117151/

### Sounds
* AMB Playground Kids Playing: http://freesound.org/people/conleec/sounds/159735/
* Morning Has Broken: http://freesound.org/people/acclivity/sounds/21199/
* Piccadilly Circus Ambience: http://freesound.org/people/habbis92/sounds/240233/
* Shore: http://freesound.org/people/xDimebagx/sounds/210249/
* Summer Evening In My Garden: http://freesound.org/people/acclivity/sounds/30832/
