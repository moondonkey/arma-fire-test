const express = require("express");
const path = require("path");

const app = express();
app.use(express.json());

// Pending fire missions queue
const pendingMissions = [];

// Serve static UI
app.use(express.static(path.join(__dirname, "public")));

// Submit a fire mission from the web UI
app.post("/api/fire", (req, res) => {
  const { x, y, count, radius, interval, zOffset } = req.body;

  if (x == null || y == null) {
    return res.status(400).json({ error: "x and y are required" });
  }

  const mission = {
    x: Number(x),
    y: Number(y),
    count: Number(count) || 6,
    radius: Number(radius) || 50,
    interval: Number(interval) || 1.5,
    zOffset: Number(zOffset) || 0,
    timestamp: Date.now(),
  };

  pendingMissions.push(mission);
  console.log(`Fire mission queued: ${JSON.stringify(mission)}`);
  res.json({ ok: true, mission });
});

// Bridge script polls this endpoint
app.get("/api/pending", (req, res) => {
  if (pendingMissions.length === 0) {
    return res.json({ mission: null });
  }
  const mission = pendingMissions.shift();
  console.log(`Fire mission dispatched: ${JSON.stringify(mission)}`);
  res.json({ mission });
});

// Health check
app.get("/api/health", (req, res) => {
  res.json({ status: "ok", pending: pendingMissions.length });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Arma fire test server running on port ${PORT}`);
});
