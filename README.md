<div align="center">
  <a href="https://github.com/Saik0s/CompanionAI">
    <img src=".github/logo.png" width="80">
  </a>

  <h3 align="center">CompanionAI</h3>

  <p align="center">
    Empower yourself with any custom AI companion for a better life.
  </p>
</div>
<hr />

<div align="center">
<img src=".github/screenshot1.png" width="400">
</div>
<p>
    <img src="https://github.com/Saik0s/CompanionAI/actions/workflows/swift.yml/badge.svg" />
    <img src="https://img.shields.io/badge/License-MIT-blue.svg" />
    <img src="https://img.shields.io/badge/Platforms-macOS-3876D3.svg" />
    <a href="https://tuist.io">
        <img src="https://img.shields.io/badge/Powered%20by-Tuist-blue" alt="Tuist badge" />
    </a>
    <a href="https://twitter.com/sa1k0s">
        <img src="https://img.shields.io/badge/Contact-@sa1k0s-purple.svg?style=flat" alt="Twitter: @sa1k0s" />
    </a>
</p>


<p align="center">

CompanionAI is a chat application that allows users to communicate with a team of AI personas designed for specific tasks. These AI personas can assist with a variety of tasks, such as product management, data analysis, and more.

</p>

## Installation

Run `make build_release` and CompanionAI.app will be ready for use in the repository root folder.

After launch it will create a config file at path `~/Library/Application Support/CompanionAI/config.json`. You should set OpenAI API key in this file.

## 🗺 Roadmap

- Generate context from chat history that will be sent with every prompt

## 💻 Developing

### Requirements

- Xcode 14.0+
- [Tuist](https://github.com/tuist/tuist)

## 🏷 License

`CompanionAI` is available under the MIT license. See the [LICENSE file](./LICENSE) for more info.
