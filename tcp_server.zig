const std = @import("std");

pub fn main() !void {
    const addr = std.net.Address.initIp4(
        .{ 127, 0, 0, 1 },
        8000
    );

    var tcp_server = try addr.listen(.{
        .reuse_address = true,
    });

    serve: while (true) {
        const conn = tcp_server.accept() catch |err| {
            std.log.err("accept: {}", .{err});
            continue :serve;
        };
        defer conn.stream.close();

        while (true) {
            var reader_buf: [1024]u8 = undefined;
            var stream_reader = conn.stream.reader(&reader_buf);
            const reader = &stream_reader.file_reader.interface;

            const msg = reader.takeDelimiterExclusive('\n') catch |err| {
                std.log.err("read: {}", .{err});
                continue :serve;
            };

            var writer_buf: [1024]u8 = undefined;
            var stream_writer = conn.stream.writer(&writer_buf);
            const writer = &stream_writer.interface;

            writer.print("You said: {s}\n", .{msg}) catch |err| {
                std.log.err("write: {}", .{err});
                continue :serve;
            };
            writer.flush() catch |err| {
                std.log.err("flush: {}", .{err});
                continue :serve;
            };
        }
    }
}
