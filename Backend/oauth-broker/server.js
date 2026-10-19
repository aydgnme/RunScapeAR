const http = require("node:http");
const https = require("node:https");

const PORT = process.env.PORT || 3000;
const CLIENT_SECRET = process.env.STRAVA_CLIENT_SECRET;

if (!CLIENT_SECRET) {
  console.error("STRAVA_CLIENT_SECRET environment variable is required");
  process.exit(1);
}

const STRAVA_TOKEN_URL = "https://www.strava.com/oauth/token";

function parseBody(req) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    req.on("data", (chunk) => chunks.push(chunk));
    req.on("end", () => {
      try {
        resolve(JSON.parse(Buffer.concat(chunks).toString()));
      } catch {
        reject(new Error("Invalid JSON"));
      }
    });
    req.on("error", reject);
  });
}

function forwardToStrava(body) {
  return new Promise((resolve, reject) => {
    const payload = JSON.stringify(body);
    const options = {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Content-Length": Buffer.byteLength(payload),
      },
    };

    const req = https.request(STRAVA_TOKEN_URL, options, (res) => {
      const chunks = [];
      res.on("data", (chunk) => chunks.push(chunk));
      res.on("end", () => {
        resolve({
          statusCode: res.statusCode,
          body: Buffer.concat(chunks).toString(),
        });
      });
    });

    req.on("error", reject);
    req.write(payload);
    req.end();
  });
}

function cors(res) {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");
}

const server = http.createServer(async (req, res) => {
  cors(res);

  if (req.method === "OPTIONS") {
    res.writeHead(204);
    res.end();
    return;
  }

  if (req.method !== "POST") {
    res.writeHead(405, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ error: "Method not allowed" }));
    return;
  }

  const url = new URL(req.url, `http://localhost:${PORT}`);

  if (url.pathname === "/token") {
    try {
      const body = await parseBody(req);

      const stravaBody = {
        client_id: body.client_id,
        client_secret: CLIENT_SECRET,
        code: body.code,
        grant_type: "authorization_code",
      };

      const result = await forwardToStrava(stravaBody);

      res.writeHead(result.statusCode, { "Content-Type": "application/json" });
      res.end(result.body);
    } catch {
      res.writeHead(400, { "Content-Type": "application/json" });
      res.end(JSON.stringify({ error: "Bad request" }));
    }
    return;
  }

  if (url.pathname === "/refresh") {
    try {
      const body = await parseBody(req);

      const stravaBody = {
        client_id: body.client_id,
        client_secret: CLIENT_SECRET,
        refresh_token: body.refresh_token,
        grant_type: "refresh_token",
      };

      const result = await forwardToStrava(stravaBody);

      res.writeHead(result.statusCode, { "Content-Type": "application/json" });
      res.end(result.body);
    } catch {
      res.writeHead(400, { "Content-Type": "application/json" });
      res.end(JSON.stringify({ error: "Bad request" }));
    }
    return;
  }

  if (url.pathname === "/health") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ status: "ok" }));
    return;
  }

  res.writeHead(404, { "Content-Type": "application/json" });
  res.end(JSON.stringify({ error: "Not found" }));
});

server.listen(PORT, () => {
  console.log(`OAuth broker running on port ${PORT}`);
});
