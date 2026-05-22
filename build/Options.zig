//! Lizard options.

/// Full command prefix used to invoke lizard. For example:
///
/// - `&.{"lizard"}`
/// - `&.{"uv", "run", "lizard"}`
command: []const []const u8 = &.{"lizard"},
/// The list of languages to analyze, passed as `--languages`. Default is `zig` since that's the important one. One can pass multiple languages as repeated `--languages` flags.
languages: []const []const u8 = &.{"zig"},
/// Cyclomatic complexity warning threshold passed as `--CCN`.
ccn: usize = 10,
/// Function length warning threshold passed as `--length`.
length: usize = 80,
/// Argument count warning threshold passed as `--arguments`.
arguments: usize = 7,
/// Use Lizard's modified cyclomatic complexity mode (`--modified`).
modified_ccn: bool = true,
/// The warning style.
warning_mode: WarningMode = .warnings_only,
/// Lizard extensions to enable. Each item is emitted as a repeated `--extension` flag.
extensions: []const []const u8 = &.{"NS"},
/// Considering src as the sanest default since that's what Zig defaults to on `zig init`.
paths: []const []const u8 = &.{"src"},
/// No excluded paths by default, since considering the source directory is usually enough to not include the tests, modules, etc.
excluded_paths: []const []const u8 = &.{},
/// The name of the step.
step_name: []const u8 = "lizard",
/// The description of the step.
step_description: []const u8 = "Run lizard checks.",
/// Lizard threshold settings. Each item is emitted as a repeated `--Threshold` flag.
thresholds: []const []const u8 = &.{},

/// Warning mode for Lizard.
pub const WarningMode = enum {
    /// Show lizard's default report, including the general summary.
    summary,
    /// Show only warnings using lizard's default Clang-style warning format.
    warnings_only,
    /// Show only warnings using Microsoft Visual Studio-style warning format.
    warnings_msvs,
};
