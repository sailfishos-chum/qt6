# Update support

To make sure that Qt and KF libraries are up to date, several scripts
and configuration files were made to simplify changing of the
versions.

## Configuration file format

There are three files describing packages that are handled by these
scripts:

- [packages.qt6](packages.qt6) - Qt6 packages;

- [packages.kf6](packages.kf6) - KDE Frameworks packages;

- [applications.obs](applications.obs) - List of applications and
  libraries that are using Qt6 or KF6 packages listed above.

Format is simple and consists of a list with one package per line. If
the package has different GitHub repository and OBS package names, put GitHub
name first then OBS package name.

If automatic update is not available for that package, add NOAUTO or
NOGIT keyword at the end of the line. Differences between keywords:

- NOGIT - automatic GitHub source repository is skipped, project
  _service update at OBS is automatic.

- NOAUTO - automatic update is skipped for GitHub sources and for
  _service at OBS.

Examples:

```
qtbase
qtwebengine NOAUTO
kf6-kirigami2 opt-kf6-kirigami2
qt6 NOGIT
```

Comments are not supported. Empty lines can be inserted to improve
readability.

For applications using these libraries, it is recommended to add the
OBS package names to `applications.obs`.


## To update

Update instructions for Qt6 or KF6:

- Clone this repository

- Change current directory to cloned repository directory

- Make sure that you don't have any `tmp` subfolder left from previous
  updates

- For Qt6, run after replacing a version:
  - `scripts/update-sources.sh --qt6 --version 6.7.2`

- For KF6, run after replacing a version:
  - `scripts/update-sources.sh --kf6 --version 6.6.0`

- Observe that the script runs till the end without errors. If there
  are errors, investigate and see what went wrong. You can rerun
  `update-sources.sh` script several times - it will push changes to
  the repository only if there are changes.

- If all went well, you have sources updated in GitHub. Go and check
  repositories, corresponding RPM SPEC files, and upstream commits
  pointed by the package.

- In corresponding repository ([Qt6](https://github.com/sailfishos-chum/qt6) or
  [KF6](https://github.com/sailfishos-chum/kf6)):
  - Set new version in SPEC;
  - Add a note in README regarding current Qt6 or KF6 version;
  - Tag the repository with the corresponding version.

- Clean up `tmp` subfolder

- For updating packages at OBS `sailfishos:chum:testing`, run
  - for Qt6: `scripts/update-obs-packages.sh --qt6 --testing`
  - for KF6: `scripts/update-obs-packages.sh --kf6 --testing`

- Wait till update is finished and test it

- If all is fine, update release project by replacing the last option
  of the script:
  - for Qt6: `scripts/update-obs-packages.sh --qt6 --release`
  - for KF6: `scripts/update-obs-packages.sh --kf6 --release`


## To change OBS targets

To add or remove Sailfish OS targets for libraries and applications,
use `scripts/update-obs-targets.sh`:

- To add target:
  - `scripts/update-obs-targets.sh --release --add 4.5.0.19`

- To delete target
  - `scripts/update-obs-targets.sh --release --del 4.5.0.19`
