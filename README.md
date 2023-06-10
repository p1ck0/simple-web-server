# simple-web-server
Multi-processed server that dynamically responds to multiple HTTP GET and POST requests

## Schema
```
socket(AF_INET, SOCK_STREAM, IPPROTO_IP) = 3
bind(3, {sa_family=AF_INET, sin_port=htons(<bind_port>), sin_addr=inet_addr("<bind_address>")}, 16) = 0
    - Bind to port 80
    - Bind to address 0.0.0.0
listen(3, 0) = 0
accept(3, NULL, NULL) = 4
fork() = <fork_result>
----- GET child -----
close(3) = 0
read(4, <read_request>, <read_request_count>) = <read_request_result>
open("<open_path>", O_RDONLY) = 3
read(3, <read_file>, <read_file_count>) = <read_file_result>
close(3) = 0
write(4, "HTTP/1.0 200 OK\r\n\r\n", 19) = 19
write(4, <write_file>, <write_file_count> = <write_file_result>
exit(0) = ?
----- /GET child -----
close(4) = 0
accept(3, NULL, NULL) = 4
fork() = <fork_result>
----- POST child -----
close(3) = 0
read(4, <read_request>, <read_request_count>) = <read_request_result>
open("<open_path>", O_WRONLY|O_CREAT, 0777) = 3
write(3, <write_file>, <write_file_count> = <write_file_result>
close(3) = 0
write(4, "HTTP/1.0 200 OK\r\n\r\n", 19) = 19
exit(0) = ?
----- /POST child -----
close(4) = 0
accept(3, NULL, NULL) = ?
```

## Buid
```bash
$ make build
$ make run
```

## Example

```bash
$ curl -i localhost/tmp/hello -d "hi"
HTTP/1.0 200 OK

$ curl -i localhost/tmp/hello
HTTP/1.0 200 OK

hi⏎

$ curl -i localhost/tmp/hello1
HTTP/1.0 404 Not Found
```
