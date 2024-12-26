# Autohook Changelog


<!--
Added      for new features.
Changed    for changes in existing functionality.
Deprecated for soon-to-be removed features.
Removed    for now removed features.
Fixed      for any bug fixes.
Security   in case of vulnerabilities.
-->


## [Unreleased]


## [2.3.0] - 2021-02-22

### Added
- Contributors link to main executable.
- `AUTOHOOK_DEBUG` flag for debug output.
- Hook output.

### Changed
- Moved repo to Autohook org.
- Updated listed website to reflect said move

### Removed
- Author from main executable.
- "Say Thanks" badge from README.

### Fixed
- Bug with file names containing spaces.
- Bug with reinstallation.


## [2.2.1] - 2018-08-26

### Changed
- Removed `realpath` requirement from the project README.


## [2.2.0] - 2018-08-26

### Changed
- `autohook.sh` is now symlinked relatively, making the repo portable and deprecating the need for `realpath`.
- Hook script failure code gets reported at the end if it occurs.


## [2.1.1] - 2018-04-16

### Changed
- Updated documentation to reflect `realpath` dependency.


## [2.1.0] - 2018-01-22

### Changed
- Disabled script output by redirecting to /dev/null.
- Added missing period to the README tagline.


## [2.0.1] - 2018-01-17

### Changed
- Updated project tagline in README and autohook.sh.
- Updated README formatting.


## [2.0.0] - 2018-01-17

### Changed
Autohook is now, well, more auto. The new version is conceptually redesigned:
- _All_ your hooks are now run through Autohook, and it just does nothing when it finds nothing.
- Scripts are intended to be kept in `hooks/scripts/`.
- Each hook type gets its own directory (e.g., `hooks/post-checkout/`).
- Scripts are symlinked to inside appropriate directories based on when they should be run (e.g., `hooks/post-checkout/01-delete-pyc-files` would point to `hooks/scripts/delete-pyc-files`).
- Script symlinks are executed based on the globbing output `("$symlinks_dir"/*)`, so starting their names with numbers helps with maintaining order of execution.


## [1.0.2] - 2017-07-31

### Added
- Code of Conduct
- Contributing Guidelines
- GitHub issue/PR templates
- Changelog


## [1.0.1] - 2017-06-02

### Added
- SayThanks.io badge to README


## [1.0.0] - 2017-02-01

### Added
- Initial release


[Unreleased]: https://github.com/Autohook/Autohook/compare/2.3.0...HEAD
[2.3.0]: https://github.com/Autohook/Autohook/compare/2.2.1...2.3.0
[2.2.1]: https://github.com/Autohook/Autohook/compare/2.2.0...2.2.1
[2.2.0]: https://github.com/Autohook/Autohook/compare/2.1.1...2.2.0
[2.1.1]: https://github.com/Autohook/Autohook/compare/2.1.0...2.1.1
[2.1.0]: https://github.com/Autohook/Autohook/compare/2.0.1...2.1.0
[2.0.1]: https://github.com/Autohook/Autohook/compare/2.0.0...2.0.1
[2.0.0]: https://github.com/Autohook/Autohook/compare/1.0.2...2.0.0
[1.0.2]: https://github.com/Autohook/Autohook/compare/1.0.1...1.0.2
[1.0.1]: https://github.com/Autohook/Autohook/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/Autohook/Autohook/releases/tag/1.0.0
