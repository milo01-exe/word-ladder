const std = @import("std");
const Ladder = @import("word_ladder.zig");

pub fn main() !void {
    const addr = std.net.Address.initIp4(
        .{ 127, 0, 0, 1 },
        8000
    );

    var tcp_server = try addr.listen(.{
        .reuse_address = true,
    });

    const seed: u64 = @intCast(std.time.milliTimestamp());
    var pseudo_random_num_generator = std.Random.DefaultPrng.init(seed);
    const random = pseudo_random_num_generator.random();

    serve: while (true) {
        const conn = tcp_server.accept() catch |err| {
            std.log.err("accept: {}", .{err});
            continue :serve;
        };
        defer conn.stream.close();

        handleConnection(random, conn) catch |err| {
            std.log.err("handleConnection: {}", .{err});
        };
    }
}

fn handleConnection(random: std.Random, conn: std.net.Server.Connection) !void {
    var conn_reader_buf: [1024]u8 = undefined;
    var conn_writer_buf: [1024]u8 = undefined;
    var conn_reader = conn.stream.reader(&conn_reader_buf);
    var conn_writer = conn.stream.writer(&conn_writer_buf); 

    var http_server = std.http.Server.init(
        &conn_reader.file_reader.interface,
        &conn_writer.interface
    );

    var request = try http_server.receiveHead();
    errdefer request.respond("", .{
        .status = .internal_server_error
    }) catch {};

    switch (request.head.method) {
        .GET => {
            if (std.mem.eql(u8, request.head.target, "/")) {
                try request.respond(
                    @embedFile("ladder.html"),
                    .{ .extra_headers = &.{ .{ .name = "Content-Type", .value = "text/html" } } }
                );
            }

            if (std.mem.eql(u8, request.head.target, "/first")) {
                const words = Ladder.words;
                const start_index = random.intRangeLessThan(usize, 0, words.len);
                const start = words[start_index];
                try request.respond(&start, .{});
            }
        },
        .POST => {
            if (std.mem.eql(u8, request.head.target, "/ladder")) {
                var reader_buf: [1024]u8 = undefined;
                const reader = try request.readerExpectContinue(&reader_buf);
                const text = try reader.takeDelimiterExclusive(0);

                Ladder.validateLadder(text) catch |err| {
                    try request.respond(@errorName(err), .{ .status = .bad_request });
                    return;
                };

                try request.respond("", .{});
            } else {
                try request.respond("", .{ .status = .not_found });
            }
        },
        else => try request.respond("", .{ .status = .not_found })
    }
}
