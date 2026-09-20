import http.server
import socketserver
import mimetypes
import os

mimetypes.init()
mimetypes.add_type('application/javascript', '.js')
mimetypes.add_type('text/css', '.css')
mimetypes.add_type('text/html', '.html')

class NoCacheHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        super().end_headers()

port = 8125
os.chdir('build/web')
print(f'Serving on {port}')
with http.server.ThreadingHTTPServer(('', port), NoCacheHTTPRequestHandler) as httpd:
    httpd.serve_forever()
