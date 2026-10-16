from http.server import BaseHTTPRequestHandler, HTTPServer
import json


class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        length = int(self.headers.get("Content-Length", "0"))
        payload = self.rfile.read(length)
        try:
            data = json.loads(payload or b"{}")
            alerts = data.get("alerts", [])
            summary = [
                {
                    "status": alert.get("status"),
                    "alertname": alert.get("labels", {}).get("alertname"),
                    "severity": alert.get("labels", {}).get("severity"),
                    "summary": alert.get("annotations", {}).get("summary"),
                }
                for alert in alerts
            ]
            print(json.dumps({"receiver": data.get("receiver"), "alerts": summary}, ensure_ascii=False), flush=True)
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"ok\n")
        except (ValueError, TypeError) as exc:
            self.send_response(400)
            self.end_headers()
            self.wfile.write(str(exc).encode("utf-8"))

    def log_message(self, fmt, *args):
        print("alert-sink: " + fmt % args, flush=True)


HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
