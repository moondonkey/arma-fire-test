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
  const { x, y, type } = req.body;

  if (x == null || y == null) {
    return res.status(400).json({ error: "x and y are required" });
  }

  const mission = {
    x: Number(x),
    y: Number(y),
    type: type || "HE",
    timestamp: Date.now(),
  };

  if (mission.type === "HE") {
    mission.count = Number(req.body.count) || 6;
    mission.radius = Number(req.body.radius) || 50;
    mission.interval = Number(req.body.interval) || 1.5;
    mission.zOffset = Number(req.body.zOffset) || 0;
  } else if (mission.type === "ILLUM") {
    mission.illumHeight = Number(req.body.illumHeight) || 350;
    mission.illumBrightness = Number(req.body.illumBrightness) || 12;
  }

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
