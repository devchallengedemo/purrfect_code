[![Dart](https://github.com/devchallengedemo/purrfect_code/actions/workflows/dart.yml/badge.svg)](https://github.com/devchallengedemo/purrfect_code/actions/workflows/dart.yml)

# Purrfect Code

A Sokoban Game you play by coding in JavaScript. Made by Google For Developers.

---

## Play the game 🎮

[Play directly](https://devchallengedemo.github.io/purrfect_code) in your desktop browser.

## Getting Started 🚀

To run the game use the launch configuration in VSCode/Android Studio or use the following commands:

```sh
$ flutter run -d chrome
```

_Purrfect Code works best in Chrome_

---

## Running Tests 🧪

To run all unit and widget tests use the following command:

```sh
$ flutter test --coverage --test-randomize-ordering-seed random
```

To view the generated coverage report you can use [lcov](https://github.com/linux-test-project/lcov).

```sh
# Generate Coverage Report
$ genhtml coverage/lcov.info -o coverage/

# Open Coverage Report
$ open coverage/index.html
```

---