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
/// Function length warning threshold passed as `--length`. This length means the whole NLoC of the declaration/function, including the signature, braces (specially the closing ones since they are in a newline), body, blank lines and comments. In contrast of the NLoC, which only counts true LoC, excluding blank lines and comments.
length: usize = 80,
/// Argument count warning threshold passed as `--arguments`.
arguments: usize = 7,
/// Use Lizard's modified cyclomatic complexity mode (`--modified`). This mode counts switch cases as a single point of complexity, this is recommended in terms of readability and maintainability. Once Lizard supports true cognitive complexity, this option will be reverted back to false as cognitive complexity is a metric intended to measure code readability and maintainability much better than what cyclomatic was ever intended to do.
///
/// Basically:
///
/// - Cyclomatic complexity is originally intended to measure the number of independent paths through a function, while
/// - Cognitive complexity is intended to measure how difficult a function is to understand, which case the modified flag helps to achieve that.
modified_ccn: bool = true,
/// Whether to enable verbose output (`--verbose`).
verbose: bool = false,
/// Whether to generate XML in cppncss style instead of the tabular output. Useful to generate report in Jenkins server.
xml: bool = false,
/// Whether to generate HTML output.
html: bool = false,
/// Whether to generate CSV output, as a transform of the default output.
csv: bool = false,
/// Whether to generate Checkstyle XML output for integration with Jenkins and other tools.
checkstyle: bool = false,
/// The number of working threads. Passed as `--working_threads`.
working_threads: usize = 1,
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

/// Lizard extensions.
pub const Extensions = enum {
    /// Ignore code in `else` branches
    cpre,
    /// Count word frequencies and generate a tag cloud
    word_count,
    /// Include global code as one function
    outside,
    /// Ignore code in assert statements
    ignore_assert,
    /// Count nested control structures
    ns,
};
