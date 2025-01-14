// Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.

use std::io::{ErrorKind, Read, Write};
use std::net::TcpStream;
use std::time::{Duration, Instant};
use std::{io, thread};

pub fn send_chunk(stream: &mut TcpStream, chunk: &[u8]) {
    stream
        .write(chunk)
        .expect(format!("Writing {} bytes", chunk.len()).as_str());
}

pub fn wait_for_chunk(stream: &mut TcpStream, timeout: &Duration) -> Result<Vec<u8>, io::Error> {
    let mut output: Vec<u8> = vec![];
    let mut buf: [u8; 65536] = [0; 65536];
    let mut begin = Instant::now();
    loop {
        let latency_so_far = Instant::now().duration_since(begin);
        if latency_so_far.ge(&timeout) {
            if output.is_empty() {
                return Err(io::Error::from(ErrorKind::TimedOut));
            } else {
                // We got exactly buflen bytes in one chunk, so it looked like more was coming.
                // But we waited the full timeout for the rest of the data and didn't receive it,
                // so here's what we have; we hope it's complete.
                eprintln!("Received exactly {} bytes, timed out after waiting {:?} for more; assuming completion", output.len(), timeout);
                return Ok(output);
            }
        }

        match stream.read(&mut buf) {
            Ok(n) if n == buf.len() => {
                begin = Instant::now();
                output.extend(buf.iter())
            }
            Ok(n) => {
                output.extend(buf[0..n].iter());
                return Ok(output);
            }
            Err(ref e) if e.kind() == ErrorKind::WouldBlock => {
                eprintln!("Couldn't read chunk; waiting for 500ms to retry");
                thread::sleep(Duration::from_millis(500))
            }
            Err(e) => return Err(e),
        }
    }
}

pub fn wait_for_shutdown(stream: &mut TcpStream, timeout: &Duration) -> Result<(), io::Error> {
    stream.set_read_timeout(Some(timeout.clone())).unwrap();
    let mut buf = [0u8; 1];
    match stream.peek(&mut buf) {
        Ok(0) => return Ok(()),
        Ok(_) => Err(io::Error::from(ErrorKind::Interrupted)),
        Err(ref e) if e.kind() == ErrorKind::WouldBlock => Err(io::Error::from(e.kind())),
        Err(ref e) if e.kind() == ErrorKind::ConnectionReset => Ok(()),
        Err(e) => Err(e),
    }
}
