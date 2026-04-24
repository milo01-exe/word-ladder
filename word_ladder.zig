const std = @import("std");

pub fn main() !void {
}

const words = blk: {
    @setEvalBranchQuota(1_000_000);
    break :blk parseWordList(@embedFile("words.txt"));
};

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
