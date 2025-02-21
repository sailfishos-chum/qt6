# Qt6 meta package for Sailfish OS

**Current packaged version: 6.8.3**

## Dependencies

As Qt6 is using different location when compared to Qt5, we can use 
regular tools to handle dependencies. There is no need to specify them
all manually, as was needed by opt-qt515.

## Adding packages, applications

To simplify handling of the packages while building and on device, use
prefixes `qt6` and `kf6` for Qt6 and KF6 packages. That would allow users, 
if they wish, to remove all packages simply by uninstalling all `qt6*`  
and `kf6` packages.

For applications, no need to add prefixes. If application has been packaged
for Qt515, add new branch with Qt6. When ready, we can switch Qt6 to the
main branch and keep Qt515 version, if needed, in separate qt515 branch.

When adding packages, replicate the same approach in defining Qt or KF
version using macros at the top of SPEC files (`qt_version` and
`kf6_version`). Those are needed if you have somewhere requirements with
corresponding Qt or KF version.

In addition, add the library to [packages.qt6](packages.qt6) or 
[packages.kf6](packages.kf6) files. 

For packages and libraries from KPIM or KDE Applications which use common
versioning scheme (usually YY.MM.R, for year, month, and a counter),
[packages.kde](packages.kde) is handled in the same way. The macro name is
`kde_version` for these.

By using these macros and having library added into packages files, it
will be possible to update the libraries automatically on the next Qt
or KF version bump.

If you develop an application using these Qt or KF libraries, consider
adding it to [applications.obs](applications.obs). This will make it
possible to add or remove OBS build targets for applications together
with the other Qt / KF libraries. We expect that the support for SFOS
versions will change in time and it makes sense to automate that
aspect as well.

See [updates README](updates.md) for details and format description of
the files.
