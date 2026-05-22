const std = @import("std");

pub const Options = @import("build/Options.zig");

/// Adds a build step to run lizard with the given options.
pub fn addStep(
    /// The build to attach the step to.
    b: *std.Build,
    /// The options to configure the lizard step.
    options: Options,
) !*std.Build.Step {
    if (options.command.len == 0) {
        return error.InvalidCommand;
    }

    const exe = try b.findProgram(&.{options.command[0]}, &.{});

    const lizard = b.addSystemCommand(&.{exe});
    if (options.command.len > 1)
        lizard.addArgs(options.command[1..]);

    for (options.languages) |language|
        lizard.addArgs(&.{ "--languages", language });

    lizard.addArgs(&.{
        "--CCN",
        b.fmt("{d}", .{options.ccn}),
        "--length",
        b.fmt("{d}", .{options.length}),
        "--arguments",
        b.fmt("{d}", .{options.arguments}),
        "--working_threads",
        b.fmt("{d}", .{options.working_threads}),
    });

    if (options.verbose) lizard.addArg("--verbose");

    if (options.xml) lizard.addArg("--xml");
    if (options.csv) lizard.addArg("--csv");
    if (options.html) lizard.addArg("--html");
    if (options.modified_ccn) lizard.addArg("--modified");
    if (options.checkstyle) lizard.addArg("--checkstyle");

    switch (options.warning_mode) {
        .summary => {},
        .warnings_only => lizard.addArg("--warnings_only"),
        .warnings_msvs => lizard.addArg("--warning-msvs"),
    }

    for (options.extensions) |extension| lizard.addArgs(&.{ "--extension", extension });

    for (options.thresholds) |threshold| lizard.addArgs(&.{ "--Threshold", threshold });

    for (options.excluded_paths) |path| lizard.addArgs(&.{ "--exclude", path });

    lizard.addArgs(options.paths);

    const step = b.step(
        options.step_name,
        options.step_description,
    );
    step.dependOn(&lizard.step);

    return step;
}

/// Similar to `addStep`, but with options that can be overriden via build options from the CLI.
pub fn addStepWithBuildOptions(
    /// The build to attach the step to.
    b: *std.Build,
    /// The default options to use, which can be overridden via build options.
    options: Options,
) *std.Build.Step {
    return addStep(b, optionsFromBuild(b, options));
}

fn optionsFromBuild(b: *std.Build, options: Options) Options {
    return .{
        .command = b.option([]const u8, "lizard-path", "Executable name or path used to invoke lizard") orelse options.command,
        .languages = stringListOption(b, "languages", "Comma-separated list of languages to analyze", options.languages),
        .ccn = b.option(usize, "ccn", "Cyclomatic complexity warning threshold") orelse options.ccn,
        .length = b.option(usize, "length", "Function length warning threshold") orelse options.length,
        .arguments = b.option(usize, "arguments", "Argument count warning threshold") orelse options.arguments,
        .modified_ccn = b.option(bool, "modified", "Only analyze files changed from source control") orelse options.modified_ccn,
        .verbose = b.option(bool, "verbose", "Enable verbose output") orelse options.verbose,
        .xml = b.option(bool, "xml", "Generate XML output in cppncss style") orelse options.xml,
        .html = b.option(bool, "html", "Generate HTML output") orelse options.html,
        .csv = b.option(bool, "csv", "Generate CSV output") orelse options.csv,
        .checkstyle = b.option(bool, "checkstyle", "Generate Checkstyle XML output") orelse options.checkstyle,
        .working_threads = b.option(usize, "working-threads", "Number of working threads") orelse options.working_threads,
        .warning_mode = b.option(Options.WarningMode, "warning-mode", "Warning output mode") orelse options.warning_mode,
        .extensions = stringListOption(b, "extensions", "Comma-separated lizard extensions to enable", options.extensions),
        .paths = stringListOption(b, "paths", "Comma-separated paths to analyze", options.paths),
        .excluded_paths = stringListOption(b, "excluded-paths", "Comma-separated paths or patterns to exclude", options.excluded_paths),
        .step_name = options.step_name,
        .step_description = options.step_description,
        .thresholds = stringListOption(b, "thresholds", "Comma-separated lizard threshold settings", options.thresholds),
    };
}

fn stringListOption(
    b: *std.Build,
    name: []const u8,
    description: []const u8,
    default: []const []const u8,
) []const []const u8 {
    const value = b.option([]const u8, name, description) orelse return default;

    if (value.len == 0) return &.{};

    var max_items: usize = 1;

    for (value) |c| {
        if (c == ',') max_items += 1;
    }

    const items = b.allocator.alloc([]const u8, max_items) catch @panic("OOM");
    var item_count: usize = 0;
    var iter = std.mem.splitScalar(u8, value, ',');

    while (iter.next()) |raw_item| {
        const item = std.mem.trim(u8, raw_item, " \t\r\n");
        if (item.len == 0) continue;

        items[item_count] = item;
        item_count += 1;
    }

    return items[0..item_count];
}

pub fn build(b: *std.Build) !void {
    const check_step = b.step("check", "Run code quality checks");
    const max_threads = std.Thread.getCpuCount() catch 1;
    const lizzy_step = try addStep(b, .{
        .command = &.{ "uvx", "lizard" },
        .paths = &.{},
        .ccn = 20,
        .working_threads = max_threads,
    });
    check_step.dependOn(lizzy_step);

    const fmt = b.addFmt(.{
        .check = true,
        .paths = &.{"."},
    });
    check_step.dependOn(&fmt.step);
}
