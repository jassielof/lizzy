const std = @import("std");

pub const Options = @import("build/Options.zig");

/// Adds a build step to run lizard with the given options.
pub fn addStep(
    /// The build to attach the step to.
    b: *std.Build,
    /// The options to configure the lizard step.
    options: Options,
) *std.Build.Step {
    const lizard = b.addSystemCommand(&.{options.lizard_path});
    lizard.addArgs(&.{
        "--languages",
        "zig",
        "--CCN",
        b.fmt("{d}", .{options.ccn}),
        "--length",
        b.fmt("{d}", .{options.length}),
        "--arguments",
        b.fmt("{d}", .{options.arguments}),
    });

    if (options.modified_ccn) lizard.addArg("--modified");

    switch (options.warning_mode) {
        .summary => {},
        .warnings_only => lizard.addArg("--warnings_only"),
        .warnings_msvs => lizard.addArg("--warning-msvs"),
    }

    for (options.extensions) |extension| {
        lizard.addArg("--extension");
        lizard.addArg(extension);
    }

    for (options.thresholds) |threshold| {
        lizard.addArg("--Threshold");
        lizard.addArg(threshold);
    }

    for (options.excluded_paths) |path| {
        lizard.addArg("--exclude");
        lizard.addArg(path);
    }

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
        .lizard_path = b.option([]const u8, "lizard-path", "Executable name or path used to invoke lizard") orelse options.lizard_path,
        .ccn = b.option(usize, "ccn", "Cyclomatic complexity warning threshold") orelse options.ccn,
        .length = b.option(usize, "length", "Function length warning threshold") orelse options.length,
        .arguments = b.option(usize, "arguments", "Argument count warning threshold") orelse options.arguments,
        .modified_ccn = b.option(bool, "modified", "Only analyze files changed from source control") orelse options.modified_ccn,
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

pub fn build(b: *std.Build) void {
    _ = b;
}
