# CompanionAI

<p>
    <img src="https://img.shields.io/badge/License-MIT-blue.svg" />
    <img src="https://github.com/Saik0s/AppDevUtils/workflows/Build%20&%20Test/badge.svg" />
    <a href="https://twitter.com/sa1k0s">
        <img src="https://img.shields.io/badge/Contact-@sa1k0s-lightgrey.svg?style=flat" alt="Twitter: @sa1k0s" />
    </a>
</p>


<p align="center">

Helpers and extensions for app development

</p>


## Installation

### Xcode Projects

Select `File` -> `Swift Packages` -> `Add Package Dependency` and enter `https://github.com/Saik0s/CompanionAI`.

### Swift Package Manager Projects

You can add `CompanionAI` as a package dependency in your `Package.swift` file:

```swift
let package = Package(
    //...
    dependencies: [
        .package(
            url: "https://github.com/Saik0s/CompanionAI",
            exact: "0.0.1"
        ),
    ],
    //...
)
```

From there, refer to `CompanionAI` as a "target dependency" in any of _your_ package's targets that need it.

```swift
targets: [
    .target(
        name: "YourLibrary",
        dependencies: [
          "CompanionAI",
        ],
        ...
    ),
    ...
]
```

Then simply `import CompanionAI` wherever you’d like to use it.

**📝 Note:** To make the library available to your entire project, you could also leverage the [functionality of the `@_exported` keyword](https://forums.swift.org/t/package-manager-exported-dependencies/11615) by placing the following line somewhere at the top level of your project:

```swift
@_exported import CompanionAI
```

## Usage

## 🗺 Roadmap

## 💻 Developing

### Requirements

- Xcode 14.0+

## 🏷 License

`CompanionAI` is available under the MIT license. See the [LICENSE file](./LICENSE) for more info.
