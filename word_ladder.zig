const std = @import("std");

const InvalidWordError = error {
    BadLength,
    NotInWordList,
    NotWordLadder,
};

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var stdout_buffer: [1024]u8 = undefined;
    var stdin_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    const seed: u64 = @intCast(std.time.milliTimestamp());
    var pseudo_random_num_generator = std.Random.DefaultPrng.init(seed);
    const random = pseudo_random_num_generator.random();
    const start_index = random.intRangeLessThan(usize, 0, words.len);
    const starting_word = words[start_index];

    var ladder = std.ArrayList([4]u8).empty;
    defer ladder.deinit(allocator);

    try ladder.append(allocator, starting_word);

    try stdout.print("Let's make a word ladder! Say `end` to exit.\n", .{});
    try stdout.flush();

    while (true) {
        // reinitialize reader in order to reset buffer for new reads
        var stdin_reader = std.fs.File.stdin().reader(&stdin_buffer);
        const stdin = &stdin_reader.interface;

        const last_word = ladder.getLast();
        try stdout.print("The ladder is {d} words long. The last word was {s}.\n", .{ladder.items.len, last_word});

        try stdout.print("> ", .{});
        try stdout.flush();

        const input = try stdin.takeDelimiterExclusive('\n');

        if (std.mem.eql(u8, input, "end")) {
            try stdout.print("Exiting…\n", .{});
            break;
        }

        const word = validateWord(input, last_word) catch |e| {
            const msg: []const u8 = switch (e) {
                error.BadLength => "Hey, that's not four characters!",
                error.NotInWordList => "I don't think that's a word…",
                error.NotWordLadder => "That doesn't make a word ladder.",
            };
            
            try stdout.print("{s}\n", .{msg});
            continue;
        };

        try ladder.append(allocator, word);
    }

    try stdout.flush();
}

const words = blk: {
    @setEvalBranchQuota(1_000_000);
    break :blk parseWordList(@embedFile("words.txt"));
};

fn validateWord(input: []const u8, last_word: [4]u8) InvalidWordError![4]u8 {
    if (input.len != 4) {
        return error.BadLength;
    }

    const word = @as(*const [4]u8, @ptrCast(input.ptr)).*;

    for (words) |wordlist_word| {
        if (std.mem.eql(u8, &wordlist_word, &word)) {
            break;
        }
    } else {
        return error.NotInWordList;
    }

    var difference: u32 = 0;
    for (word, last_word) |char_a, char_b| {
        if (char_a != char_b) {
            difference += 1;
        }
    }

    if (difference != 1) {
        return error.NotWordLadder;
    }

    return word;
}

fn parseWordList(comptime wordlist: []const u8) [countWordList(wordlist)][4]u8 {
    var list: [countWordList(wordlist)][4]u8 = undefined;
    var i: usize = 0;

    var word_iter = std.mem.tokenizeScalar(u8, wordlist, '\n');
    while (word_iter.next()) |word| : (i += 1) {
        list[i] = @as(*const [word.len]u8, @ptrCast(word.ptr)).*;
    }

    return list;
}

fn countWordList(text: []const u8) usize {
    var count: usize = 0;
    var word_iter = std.mem.tokenizeScalar(u8, text, '\n');

    while (word_iter.next()) |_| {
        count += 1;
    }

    return count;
}
