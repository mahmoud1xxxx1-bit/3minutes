import http.server
import socketserver
import os

PORT = 8129

class NoCacheHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    protocol_version = 'HTTP/1.0'
    def end_headers(self):
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        super().end_headers()

os.chdir('build/web')
with http.server.ThreadingHTTPServer(('', PORT), NoCacheHTTPRequestHandler) as httpd:
    print(f'Serving at http://localhost:{PORT}')
    httpd.serve_forever()
