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

        handleConnection(conn) catch |err| {
            std.log.err("handleConnection: {}", .{err});
        };
    }
}

fn handleConnection(conn: std.net.Server.Connection) !void {
    var conn_reader_buf: [1024]u8 = undefined;
    var conn_writer_buf: [1024]u8 = undefined;
    var conn_reader = conn.stream.reader(&conn_reader_buf);
    var conn_writer = conn.stream.writer(&conn_writer_buf); 

    var http_server = std.http.Server.init(
        &conn_reader.file_reader.interface,
        &conn_writer.interface
    );

    var request = try http_server.receiveHead();
    if (request.head.method != .POST) {
        request.respond("", .{ .status = .bad_request }) catch {};
        return error.BadRequest;
    }

    errdefer request.respond("", .{
        .status = .internal_server_error
    }) catch {};

    var reader_buf: [1024]u8 = undefined;
    const reader = try request.readerExpectContinue(&reader_buf);
    const text = try reader.takeDelimiterExclusive(0);

    var body_writer_buf: [1024]u8 = undefined;
    var body_writer = try request.respondStreaming(&body_writer_buf, .{});
    const body = &body_writer.writer;

    try body.print("You said: {s}\n", .{text});
    try body.flush();
    
    try body_writer.end();
}
